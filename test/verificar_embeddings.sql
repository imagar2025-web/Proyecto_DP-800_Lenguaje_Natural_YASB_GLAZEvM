USE DesktopConfigDB;
GO

/* Cuantas filas tienen embedding */
SELECT COUNT(*) AS total,
       SUM(CASE WHEN embedding IS NOT NULL THEN 1 ELSE 0 END) AS con_embedding
FROM dbo.configuracion;

/* Dimensiones del vector (debe ser 768) */
SELECT TOP 5 configuracion_id, titulo,
       VECTORPROPERTY(embedding, 'Dimensions') AS dimensiones
FROM dbo.configuracion
WHERE embedding IS NOT NULL;

/* Ejemplo de un vector */
SELECT TOP 1 titulo, embedding FROM dbo.configuracion WHERE embedding IS NOT NULL;

/* Prueba rapida de sentido: configuraciones mas cercanas a la del clima */
DECLARE @ref VECTOR(768);

SELECT TOP (1) @ref = embedding
FROM dbo.configuracion
WHERE embedding IS NOT NULL
  AND titulo LIKE N'Widget de clima%'
ORDER BY configuracion_id;

SELECT TOP 5 titulo,
       VECTOR_DISTANCE('cosine', embedding, @ref) AS distancia
FROM dbo.configuracion
WHERE embedding IS NOT NULL
  AND @ref IS NOT NULL
ORDER BY distancia;
GO
