/*  Crear el login a nivel de servidor */
USE master;


GO
CREATE LOGIN api_desktop_config
    WITH PASSWORD = 'TU_CONTRASENA_SEGURA', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;


GO
/*  Crear el usuario dentro de la base de datos */
USE DesktopConfigDB;


GO
CREATE USER api_desktop_config FOR LOGIN api_desktop_config;


GO
/*  Crear un rol específico para la API */
CREATE ROLE rol_api_desktop_config;


GO
ALTER ROLE rol_api_desktop_config ADD MEMBER api_desktop_config;


GO
/*  Permitir cargar los ejemplos */
GRANT SELECT
    ON OBJECT::dbo.peticion_ejemplo TO rol_api_desktop_config;


GO
/*  Permitir ejecutar el endpoint RAG */
GRANT EXECUTE
    ON OBJECT::dbo.sp_rag_configuracion TO rol_api_desktop_config;


GO
/*  Necesario para la llamada de SQL Server a Ollama/REST */
USE master;


GO
GRANT EXECUTE ANY EXTERNAL ENDPOINT TO api_desktop_config;