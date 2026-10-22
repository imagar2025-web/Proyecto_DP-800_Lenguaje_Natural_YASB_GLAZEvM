USE DesktopConfigDB;


GO
-- Debe devolver 1
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS fulltext_instalado;

CREATE FULLTEXT CATALOG ftc_configuracion
    AS DEFAULT;

CREATE FULLTEXT INDEX ON dbo.configuracion
    (titulo LANGUAGE 3082, descripcion LANGUAGE 3082)
    KEY INDEX -- 3082 = español
PK_configuracion
    ON ftc_configuracion
    WITH CHANGE_TRACKING AUTO;