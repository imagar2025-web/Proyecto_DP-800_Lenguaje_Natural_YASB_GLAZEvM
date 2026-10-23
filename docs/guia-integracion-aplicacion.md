# Integración de la aplicación con SQL Server, Ollama y el frontend

## 1. Objetivo del sistema

El proyecto permite escribir una petición en lenguaje natural, buscar configuraciones de YASB y GlazeWM en SQL Server y mostrar una explicación generada por Ollama.

El flujo completo es:

```text
Navegador
    |
    v
Caddy (https://localhost:8443)
    |------------------------------|
    v                              v
Frontend                    Express (localhost:3000)
                                   |
                                   v
                            SQL Server / DesktopConfigDB
                                   |
                                   v
                         Ollama mediante Caddy
```

Caddy actúa como punto de entrada único:

- Los archivos del frontend se sirven desde `frontend/`.
- `/api/ejemplos` se reenvía a Express.
- `/api/rag` se reenvía a Express.
- `/api/chat` y `/api/embed` se reenvían a Ollama.

## 2. Motivo de la separación por componentes

### Backend

El backend se implementó con Node.js, Express y el paquete `mssql`. Su responsabilidad es:

1. Recibir peticiones HTTP del frontend.
2. Validar la pregunta y la herramienta seleccionada.
3. Conectarse a SQL Server usando variables de entorno.
4. Ejecutar el procedimiento almacenado `dbo.sp_rag_configuracion`.
5. Devolver una respuesta JSON al navegador.

El backend evita que el navegador se conecte directamente a SQL Server y centraliza la validación, las credenciales y el control de errores.

### Usuario específico de base de datos

Se creó `api_desktop_config` para que la aplicación no utilice una cuenta administradora. El principio aplicado es el de mínimo privilegio:

| Permiso | Motivo |
|---|---|
| `SELECT` sobre `dbo.peticion_ejemplo` | Cargar los ejemplos que aparecen en el frontend. |
| `EXECUTE` sobre `dbo.sp_rag_configuracion` | Ejecutar el endpoint RAG desde Express. |
| `EXECUTE` sobre el modelo externo `ollama_nomic` | Permitir que el procedimiento genere embeddings. |
| `EXECUTE ANY EXTERNAL ENDPOINT` | Permitir las llamadas REST externas de SQL Server hacia Ollama/Caddy. |

No se concedieron `db_owner`, `db_datareader` ni `db_datawriter`, porque darían más acceso del necesario.

### Frontend

El frontend es la interfaz de usuario. Se mantiene separado del backend para que:

- El usuario pueda introducir preguntas sin conocer SQL.
- Las respuestas se muestren en tarjetas legibles.
- Los ejemplos se carguen desde la base de datos.
- Los bloques YAML y CSS puedan copiarse directamente.
- La aplicación se pueda publicar mediante Caddy con una única URL.

## 3. Configuración realizada

### 3.1. Base de datos y procedimientos

La base de datos utilizada es `DesktopConfigDB`. El procedimiento principal es:

```text
dbo.sp_rag_configuracion
```

Este procedimiento:

1. Valida la pregunta.
2. Llama a `dbo.sp_buscar_hibrido`.
3. Realiza la búsqueda vectorial y de texto completo.
4. Genera el contexto para Ollama.
5. Devuelve la explicación y las configuraciones encontradas.

La búsqueda híbrida utiliza el modelo externo:

```text
ollama_nomic
```

Configuración del modelo:

```sql
CREATE EXTERNAL MODEL [ollama_nomic]
WITH (
    LOCATION = 'https://localhost:8443/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL = 'nomic-embed-text'
);
```

El usuario de la API debe tener permiso de ejecución sobre ese modelo:

```sql
USE DesktopConfigDB;
GO

GRANT EXECUTE
ON EXTERNAL MODEL::[ollama_nomic]
TO [api_desktop_config];
GO
```

### 3.2. Usuario de la aplicación

El login se creó a nivel de servidor y el usuario correspondiente dentro de `DesktopConfigDB`. La autenticación SQL Server tuvo que habilitarse junto con la autenticación de Windows:

```text
SQL Server and Windows Authentication mode
```

Después de cambiar esta opción se reinició el servicio de SQL Server.

El usuario se creó mediante:

```sql
CREATE LOGIN [api_desktop_config]
WITH PASSWORD = 'CONTRASEÑA_SEGURA';
```

Y dentro de la base de datos:

```sql
USE DesktopConfigDB;
GO

CREATE USER [api_desktop_config]
FOR LOGIN [api_desktop_config];
GO
```

El script del repositorio relacionado es [`sql/creacion_usuario_endpoint.sql`](../sql/creacion_usuario_endpoint.sql).

### 3.3. Variables de entorno

El backend lee la configuración desde [`backend/.env`](../backend/.env):

```env
PORT=3000
DB_SERVER=localhost
DB_PORT=1433
DB_NAME=DesktopConfigDB
DB_USER=api_desktop_config
DB_PASSWORD=CONTRASEÑA_SEGURA
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=true
```

El archivo `.env` no debe incluirse en Git ni en la memoria con la contraseña real. Si una contraseña real se comparte accidentalmente, debe cambiarse.

### 3.4. Arranque de los servicios

El orden de arranque utilizado es:

1. SQL Server.
2. Ollama.
3. Caddy.
4. Express.
5. Navegador.

Backend:

```powershell
cd backend
npm install
npm start
```

Caddy:

```powershell
caddy run --config Caddyfile
```

URL final:

```text
https://localhost:8443
```

## 4. Problemas encontrados y soluciones

| Problema | Causa | Solución aplicada |
|---|---|---|
| `Login failed for user 'api_desktop_config'` | SQL Server solo permitía Windows Authentication, o la contraseña del `.env` no coincidía con la del login. | Se activó `SQL Server and Windows Authentication mode`, se reinició SQL Server, se habilitó el login y se sincronizó la contraseña con `backend/.env`. |
| La contraseña parecía no cargarse | El comando de prueba se ejecutó desde la raíz, donde Node no encontraba los módulos instalados en `backend/node_modules`. | Se ejecutaron las pruebas desde la carpeta `backend`, que contiene `package.json`, `.env` y `node_modules`. |
| `Cannot find package 'dotenv'` | Node resolvía los paquetes desde la raíz del proyecto y no desde `backend`. | Se cambió el directorio actual a `backend` antes de ejecutar el script de prueba o `npm start`. |
| `GET /api/ejemplos` no funcionaba inicialmente | La API todavía no tenía una conexión SQL válida. | Una vez corregidas las credenciales, el endpoint empezó a devolver las filas de `dbo.peticion_ejemplo`. |
| `Cannot find the external model 'ollama_nomic'` | El modelo externo no existía en `DesktopConfigDB` o el usuario no tenía permiso para utilizarlo. | Se creó `ollama_nomic` y se concedió `GRANT EXECUTE ON EXTERNAL MODEL::[ollama_nomic]`. |
| Permiso `REFERENCES` incorrecto para el modelo | `REFERENCES` no es el permiso de uso de `AI_GENERATE_EMBEDDINGS`. | Se sustituyó por `GRANT EXECUTE ON EXTERNAL MODEL::[ollama_nomic]`. |
| El endpoint RAG devolvía HTTP 500 | El procedimiento fallaba al intentar generar embeddings antes de encontrar el modelo externo. | Se revisó el error de Express, se creó el modelo y se concedieron los permisos necesarios. |
| El frontend no cargaba los ejemplos mediante la URL pública | Caddy debía reenviar `/api/ejemplos` a Express. | Se configuró `Caddyfile` con `reverse_proxy localhost:3000` para `/api/ejemplos` y `/api/rag`. |
| El frontend no mostraba el CSS actualizado | El navegador conservaba una versión anterior en caché. | Se recargó con `Ctrl + Shift + R`, se deshabilitó la caché desde DevTools o se abrió una ventana privada. |
| La aplicación mostraba una advertencia HTTPS | Caddy usa un certificado interno para desarrollo local. | Se continuó hacia `https://localhost:8443` desde la opción avanzada del navegador. |

## 5. Archivos principales y finalidad

| Archivo | Función |
|---|---|
| [`backend/server.js`](../backend/server.js) | Servidor Express, validación de entradas, conexión `mssql`, rutas `/api/ejemplos` y `/api/rag`, y gestión de errores. |
| [`backend/package.json`](../backend/package.json) | Dependencias y comandos del backend (`express`, `mssql`, `dotenv`, `npm start`). |
| [`backend/.env`](../backend/.env) | Configuración local de SQL Server y del puerto de Express. Contiene secretos y no debe publicarse. |
| [`frontend/index.html`](../frontend/index.html) | Estructura de la interfaz, formulario, selector de herramienta, resultados y botones de copia. |
| [`frontend/app.js`](../frontend/app.js) | Lógica Vue: carga de ejemplos, envío de preguntas, gestión de estados y copia de código. |
| [`frontend/css/style.css`](../frontend/css/style.css) | Estilo visual responsive: tema oscuro, tarjetas, formularios, estados y bloques de código. |
| [`Caddyfile`](../Caddyfile) | Punto de entrada HTTPS local, servidor de archivos y proxy hacia Express y Ollama. |
| [`sql/modelo_datos.sql`](../sql/modelo_datos.sql) | Creación de `DesktopConfigDB`, tablas, relaciones, índices y datos iniciales. |
| [`sql/creacion_usuario_endpoint.sql`](../sql/creacion_usuario_endpoint.sql) | Creación del login, usuario, rol y permisos iniciales de la API. |
| [`test/Prueba_permisos_usuarios.sql`](../test/Prueba_permisos_usuarios.sql) | Comprobación de permisos del usuario `api_desktop_config`. |
| [`ai/sp_buscar_hibrido.sql`](../ai/sp_buscar_hibrido.sql) | Búsqueda combinada vectorial y de texto completo. También registra la consulta. |
| [`ai/sp_rag_configuracion.sql`](../ai/sp_rag_configuracion.sql) | Procedimiento principal RAG: recuperación, contexto para Ollama y respuesta JSON. |
| [`test/pruebas_embedings.sql`](../test/pruebas_embedings.sql) | Habilitación de endpoints REST, creación del modelo externo y prueba de embeddings. |
| [`README.md`](../README.md) | Instrucciones resumidas para instalar, arrancar y entender el flujo del proyecto. |

## 6. Comprobaciones finales

### Comprobar la conexión de la API

```powershell
cd backend
npm run check
npm start
```

### Comprobar ejemplos

```powershell
curl.exe -k https://localhost:8443/api/ejemplos
```

La respuesta debe ser un JSON con filas de `peticion_ejemplo`.

### Comprobar RAG

```powershell
$body = @{
  pregunta = "Quiero una barra con reloj"
  herramienta = "YASB"
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "https://localhost:8443/api/rag" `
  -Method Post `
  -ContentType "application/json" `
  -Body $body
```

La respuesta esperada contiene:

```json
{
  "llm_ok": true,
  "explicacion": "...",
  "configuraciones": [],
  "error": null
}
```

La dirección de uso de la aplicación es:

```text
https://localhost:8443
```

## 7. Resumen para la memoria

La integración se resolvió separando responsabilidades: el frontend gestiona la interacción, Express actúa como API intermedia, SQL Server ejecuta la búsqueda híbrida y Ollama genera embeddings y explicaciones. Se creó un usuario específico para la API con permisos mínimos, evitando el uso de una cuenta administradora. Caddy unifica el acceso HTTPS local y enruta tanto la aplicación como las llamadas hacia Ollama. Durante la puesta en marcha se resolvieron problemas de autenticación SQL, carga de variables de entorno, creación y permisos del modelo externo y caché del navegador.
