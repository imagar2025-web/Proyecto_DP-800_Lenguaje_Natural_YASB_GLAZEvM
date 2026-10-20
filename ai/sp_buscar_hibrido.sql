CREATE OR ALTER PROCEDURE dbo.sp_buscar_hibrido
    -- texto del usuario a buscar
    @texto          NVARCHAR(1000),
    -- herramienta que se va a buscar
    @herramienta    NVARCHAR(50) = NULL,
    -- Ajustes que se iran afinando por la recuperación
    @top            INT   = 5,
    @distancia_max  FLOAT = NULL      -- umbral opcional (pendiente de decidir)
AS
BEGIN
    SET NOCOUNT ON;

    IF @texto IS NULL OR LEN(LTRIM(RTRIM(@texto))) = 0
        THROW 50001, N'La petición no puede estar vacía.', 1;
    IF @top IS NULL OR @top < 1 SET @top = 1;
    IF @top > 20                SET @top = 20;

    DECLARE @inicio DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @n INT = 20;     -- candidatos de cada búsqueda
    DECLARE @k INT = 60;     -- constante de la fusión por rangos (RRF)

    DECLARE @v VECTOR(768) =
        AI_GENERATE_EMBEDDINGS((N'search_query: ' + @texto) USE MODEL ollama_nomic);

    DECLARE @r TABLE (
        configuracion_id INT, herramienta NVARCHAR(50), titulo NVARCHAR(150),
        descripcion NVARCHAR(1000), codigo_yaml NVARCHAR(MAX), codigo_css NVARCHAR(MAX),
        distancia FLOAT, rk_vector INT, rk_fulltext INT, puntuacion FLOAT);

    WITH sem AS (
        SELECT TOP (@n) c.configuracion_id,
               ROW_NUMBER() OVER (ORDER BY VECTOR_DISTANCE('cosine', c.embedding, @v)) AS rk
        FROM dbo.configuracion c
        JOIN dbo.herramienta h ON h.herramienta_id = c.herramienta_id
        WHERE c.activo = 1 AND c.embedding IS NOT NULL
          AND (@herramienta IS NULL OR h.nombre = @herramienta)
        ORDER BY VECTOR_DISTANCE('cosine', c.embedding, @v)
    ),
    lex AS (
        SELECT TOP (@n) f.[KEY] AS configuracion_id,
               ROW_NUMBER() OVER (ORDER BY f.[RANK] DESC) AS rk
        FROM FREETEXTTABLE(dbo.configuracion, (titulo, descripcion), @texto, LANGUAGE 3082) f
        JOIN dbo.configuracion c ON c.configuracion_id = f.[KEY]
        JOIN dbo.herramienta h ON h.herramienta_id = c.herramienta_id
        WHERE c.activo = 1 AND (@herramienta IS NULL OR h.nombre = @herramienta)
        ORDER BY f.[RANK] DESC
    ),
    fusion AS (
        SELECT COALESCE(s.configuracion_id, l.configuracion_id) AS configuracion_id,
               s.rk AS rk_vector, l.rk AS rk_fulltext,
               COALESCE(1.0 / (@k + s.rk), 0) + COALESCE(1.0 / (@k + l.rk), 0) AS puntuacion
        FROM sem s
        FULL OUTER JOIN lex l ON l.configuracion_id = s.configuracion_id
    )
    INSERT INTO @r
    SELECT TOP (@top)
           c.configuracion_id, h.nombre, c.titulo, c.descripcion, c.codigo_yaml, c.codigo_css,
           VECTOR_DISTANCE('cosine', c.embedding, @v),
           f.rk_vector, f.rk_fulltext, f.puntuacion
    FROM fusion f
    JOIN dbo.configuracion c ON c.configuracion_id = f.configuracion_id
    JOIN dbo.herramienta h   ON h.herramienta_id   = c.herramienta_id
    WHERE @distancia_max IS NULL
       OR VECTOR_DISTANCE('cosine', c.embedding, @v) <= @distancia_max
    ORDER BY f.puntuacion DESC;

    INSERT INTO dbo.consulta_log (texto_usuario, configuracion_id, distancia, duracion_ms)
    SELECT TOP (1) @texto, configuracion_id, distancia,
           DATEDIFF(MILLISECOND, @inicio, SYSUTCDATETIME())
    FROM @r ORDER BY puntuacion DESC;

    SELECT * FROM @r ORDER BY puntuacion DESC;
END;
GO