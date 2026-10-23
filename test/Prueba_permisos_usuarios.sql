USE DesktopConfigDB;


GO
-- Debe salir uno con la correcta creación del usuarios, rol, login ect
EXECUTE AS USER = 'api_desktop_config';

SELECT HAS_PERMS_BY_NAME(N'dbo.peticion_ejemplo', N'OBJECT', N'SELECT') AS puede_leer_ejemplos;

SELECT HAS_PERMS_BY_NAME(N'dbo.sp_rag_configuracion', N'OBJECT', N'EXECUTE') AS puede_ejecutar_rag;

REVERT;