IF DB_ID(N'DesktopConfigDB') IS NULL
    CREATE DATABASE DesktopConfigDB;


GO
USE DesktopConfigDB;


GO
/* Herramientas soportadas (YASB, GlazeWM) */
CREATE TABLE dbo.herramienta (
    herramienta_id INT            IDENTITY (1, 1) CONSTRAINT PK_herramienta PRIMARY KEY,
    nombre         NVARCHAR (50)  NOT NULL CONSTRAINT UQ_herramienta_nombre UNIQUE,
    descripcion    NVARCHAR (300) NULL
);

/*Categorias / etiquetas (barra, clima, notificaciones, tema...) */
CREATE TABLE dbo.categoria (
    categoria_id INT           IDENTITY (1, 1) CONSTRAINT PK_categoria PRIMARY KEY,
    nombre       NVARCHAR (50) NOT NULL CONSTRAINT UQ_categoria_nombre UNIQUE
);

/* Catalogo de configuraciones (tabla principal del RAG) */
CREATE TABLE dbo.configuracion (
    configuracion_id INT             IDENTITY (1, 1) CONSTRAINT PK_configuracion PRIMARY KEY,
    herramienta_id   INT             NOT NULL CONSTRAINT FK_configuracion_herramienta FOREIGN KEY REFERENCES dbo.herramienta (herramienta_id),
    titulo           NVARCHAR (150)  NOT NULL,
    descripcion      NVARCHAR (1000) NOT NULL, -- texto en lenguaje natural
    codigo_yaml      NVARCHAR (MAX)  NULL, -- config.yaml
    codigo_css       NVARCHAR (MAX)  NULL, -- styles.css (YASB)
    fecha_creacion   DATETIME2 (0)   CONSTRAINT DF_configuracion_fecha DEFAULT SYSUTCDATETIME() NOT NULL,
    activo           BIT             CONSTRAINT DF_configuracion_activo DEFAULT 1 NOT NULL,
    embedding        VECTOR(768)     NULL, -- proxima carga de datos
    CONSTRAINT CK_configuracion_codigo CHECK (codigo_yaml IS NOT NULL
                                              OR codigo_css IS NOT NULL)
);

/* Relacion N:M configuracion <-> categoria */
CREATE TABLE dbo.configuracion_categoria (
    configuracion_id INT NOT NULL CONSTRAINT FK_cc_configuracion FOREIGN KEY REFERENCES dbo.configuracion (configuracion_id) ON DELETE CASCADE,
    categoria_id     INT NOT NULL CONSTRAINT FK_cc_categoria FOREIGN KEY REFERENCES dbo.categoria (categoria_id),
    CONSTRAINT PK_configuracion_categoria PRIMARY KEY (configuracion_id, categoria_id)
);

/* Ejemplos de peticiones que se muestran al inicio de la app */
CREATE TABLE dbo.peticion_ejemplo (
    peticion_id      INT            IDENTITY (1, 1) CONSTRAINT PK_peticion_ejemplo PRIMARY KEY,
    texto            NVARCHAR (300) NOT NULL,
    configuracion_id INT            NULL CONSTRAINT FK_peticion_configuracion FOREIGN KEY REFERENCES dbo.configuracion (configuracion_id)
);

/* Registro de consultas para seguridad y optimizaciones futuras */
CREATE TABLE dbo.consulta_log (
    consulta_id      BIGINT          IDENTITY (1, 1) CONSTRAINT PK_consulta_log PRIMARY KEY,
    texto_usuario    NVARCHAR (1000) NOT NULL,
    fecha            DATETIME2 (0)   CONSTRAINT DF_consulta_fecha DEFAULT SYSUTCDATETIME() NOT NULL,
    configuracion_id INT             NULL CONSTRAINT FK_consulta_configuracion FOREIGN KEY REFERENCES dbo.configuracion (configuracion_id),
    distancia        FLOAT           NULL, -- distancia coseno del mejor resultado
    duracion_ms      INT             NULL
);

/* Indices de apoyo para filtros habituales */
CREATE INDEX IX_configuracion_herramienta
    ON dbo.configuracion(herramienta_id, activo);

CREATE INDEX IX_cc_categoria
    ON dbo.configuracion_categoria(categoria_id);


GO
/* seed de los datos*/
INSERT  INTO dbo.herramienta (
    nombre,
    descripcion
)
VALUES                       (N'YASB', N'Barra superior personalizable para Windows (YAML + CSS)'),
                             (N'GlazeWM', N'Gestor de ventanas tiling para Windows (YAML)');

INSERT  INTO dbo.categoria (
    nombre
)
VALUES                     (N'barra'),
                           (N'clima'),
                           (N'notificaciones'),
                           (N'tema'),
                           (N'atajos'),
                           (N'espacios de trabajo');


GO
/* Comprobacion */
SELECT   t.name AS tabla
FROM     sys.tables AS t
ORDER BY t.name;