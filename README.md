# Asistente de configuraciones de escritorio

Proyecto de Bases de Datos Vectoriales (DP-800) que recomienda configuraciones
de **YASB** y **GlazeWM** a partir de peticiones escritas en lenguaje natural.
La solución utiliza SQL Server 2025 como núcleo de búsqueda y RAG, Ollama
como servicio local de modelos, Caddy como proxy HTTPS y una aplicación web
con Express y Vue.

> La memoria técnica completa está en
> [docs/Proyecto.md](docs/Proyecto.md).

## Índice

- [Objetivo](#objetivo)
- [Arquitectura](#arquitectura)
- [Tecnologías](#tecnologías)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Requisitos](#requisitos)
- [Reproducción](#reproducción)
- [Orden de ejecución SQL](#orden-de-ejecución-sql)
- [Uso de la aplicación](#uso-de-la-aplicación)
- [API](#api)
- [Pruebas](#pruebas)
- [Seguridad y datos sensibles](#seguridad-y-datos-sensibles)
- [Limitaciones conocidas](#limitaciones-conocidas)

## Objetivo

El usuario puede escribir una petición como:

> Dame una barra con el clima de mi ciudad y un gestor de notificaciones.

El sistema transforma la petición en un embedding, combina búsqueda vectorial
y Full-Text, recupera configuraciones del catálogo y solicita a `llama3.2` una
explicación breve. El YAML y el CSS que se muestran proceden del catálogo
almacenado en SQL Server.

## Arquitectura

```text
Navegador
    |
    v
Caddy (HTTPS localhost:8443)
    |------------------------------|
    v                              v
Frontend                      Express (localhost:3000)
                                      |
                                      v
                              SQL Server / DesktopConfigDB
                                      |
                                      v
                              Ollama (localhost:11434)
```

- Caddy sirve el frontend y reenvía `/api/ejemplos` y `/api/rag` a Express.
- Caddy reenvía `/api/embed` y `/api/chat` a Ollama.
- Express valida la entrada y ejecuta `dbo.sp_rag_configuracion`.
- SQL Server genera embeddings, realiza la recuperación híbrida, llama al LLM
  y registra la consulta.

## Tecnologías

| Componente | Tecnología |
|---|---|
| Base de datos | SQL Server 2025, T-SQL y SSMS |
| Embeddings | Ollama con `nomic-embed-text` (768 dimensiones) |
| Modelo generativo | Ollama con `llama3.2` |
| Proxy HTTPS | Caddy con certificado interno |
| Backend | Node.js, Express, `mssql` y `dotenv` |
| Frontend | HTML, CSS, JavaScript y Vue 3 |
| Control de versiones | Git y GitHub |

El frontend carga Vue 3 desde jsDelivr en
[frontend/index.html](frontend/index.html). Por tanto, la primera ejecución
necesita acceso a ese recurso o una modificación para servir Vue localmente.

## Estructura del repositorio

```text
ai/          Modelo externo, embeddings, Full-Text, búsqueda y RAG
backend/     API Express y configuración de dependencias
docs/        Memoria y capturas
frontend/    Interfaz web
presentacion/ Espacio reservado para la presentación
sql/         Modelo, catálogo y permisos de la aplicación
test/        Pruebas SQL
Caddyfile    Enrutamiento HTTPS local
```

Archivos principales:

| Archivo | Responsabilidad |
|---|---|
| [sql/modelo_datos.sql](sql/modelo_datos.sql) | Crea `DesktopConfigDB`, tablas, relaciones, índices y datos base. |
| [sql/carga_catalogo.sql](sql/carga_catalogo.sql) | Inserta configuraciones, categorías y peticiones de ejemplo. |
| [sql/creacion_usuario_endpoint.sql](sql/creacion_usuario_endpoint.sql) | Crea el login, usuario y rol de la API. |
| [ai/update_embeddings.sql](ai/update_embeddings.sql) | Genera embeddings para las configuraciones activas. |
| [ai/cargar_texto_completo_index.sql](ai/cargar_texto_completo_index.sql) | Crea el catálogo e índice Full-Text. |
| [ai/sp_buscar_hibrido.sql](ai/sp_buscar_hibrido.sql) | Combina búsqueda vectorial y Full-Text. |
| [ai/sp_rag_configuracion.sql](ai/sp_rag_configuracion.sql) | Orquesta recuperación, contexto y llamada al LLM. |
| [backend/server.js](backend/server.js) | Expone la API HTTP. |
| [frontend/app.js](frontend/app.js) | Gestiona consultas, resultados y copia de código. |
| [Caddyfile](Caddyfile) | Sirve el frontend y enruta las APIs. |

## Requisitos

- Windows con SQL Server 2025 y el componente de Full-Text instalado.
- Node.js y npm.
- Ollama.
- Caddy.
- Un modelo `nomic-embed-text` y un modelo `llama3.2` descargados en Ollama.
- Permisos para crear una base de datos, login y usuario en SQL Server.

Comprobar los modelos de Ollama:

```powershell
ollama list
```

El repositorio no incluye credenciales. El archivo
[backend/.env.example](backend/.env.example) sirve como plantilla y el archivo
local `backend/.env` debe permanecer fuera de Git.

## Reproducción

### 1. Preparar SQL Server

Ejecutar en SSMS, en el orden indicado en
[Orden de ejecución SQL](#orden-de-ejecución-sql). El script del usuario de
la aplicación contiene una contraseña de ejemplo que debe sustituirse por una
contraseña local segura antes de ejecutarlo.

También debe habilitarse la configuración de SQL Server que permite llamadas a
endpoints REST externos:

```sql
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
```

### 2. Registrar el modelo de embeddings

En `DesktopConfigDB`, ejecutar:

```sql
CREATE EXTERNAL MODEL ollama_nomic
WITH (
    LOCATION   = 'https://localhost:8443/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL      = 'nomic-embed-text'
);
```

El repositorio no contiene actualmente un script separado para este bloque;
la instrucción también aparece en [docs/Proyecto.md](docs/Proyecto.md).

### 3. Arrancar Ollama y confiar en Caddy

Comprobar que Ollama está disponible y que los modelos requeridos están
instalados. Después, desde la raíz del proyecto, arrancar Caddy con:

```powershell
caddy start --config Caddyfile
```

En la primera ejecución del certificado interno, seguir el procedimiento de
confianza de Caddy para el equipo local. SQL Server debe confiar en esa CA
para poder llamar al endpoint HTTPS.

### 4. Configurar y arrancar Express

Copiar la plantilla:

```powershell
Copy-Item backend\.env.example backend\.env
```

Completar `backend\.env` con los datos locales de SQL Server. No copiar esos
valores en el repositorio ni en capturas.

Instalar dependencias y arrancar:

```powershell
Set-Location backend
npm install
npm start
```

La API escucha por defecto en `http://localhost:3000`.

### 5. Abrir la aplicación

Con Caddy en ejecución, abrir:

```text
https://localhost:8443
```

El puerto `http://localhost:3000` permite comprobar Express directamente,
mientras que la URL de Caddy reproduce el flujo completo con frontend y proxy.

## Orden de ejecución SQL

1. [sql/modelo_datos.sql](sql/modelo_datos.sql)
2. [sql/carga_catalogo.sql](sql/carga_catalogo.sql)
3. Configuración de `external rest endpoint enabled`.
4. Registro manual de `ollama_nomic` mostrado en la sección anterior.
5. [ai/cargar_texto_completo_index.sql](ai/cargar_texto_completo_index.sql)
6. [ai/update_embeddings.sql](ai/update_embeddings.sql)
7. [ai/sp_buscar_hibrido.sql](ai/sp_buscar_hibrido.sql)
8. [ai/sp_rag_configuracion.sql](ai/sp_rag_configuracion.sql)
9. [sql/creacion_usuario_endpoint.sql](sql/creacion_usuario_endpoint.sql)
10. Pruebas de [test/](test/).

Si el modelo externo se crea después de los procedimientos, estos pueden
seguir compilándose, pero las pruebas que generen embeddings necesitan que el
modelo exista y que el endpoint HTTPS sea accesible.

## Uso de la aplicación

1. Introducir una petición de hasta 500 caracteres.
2. Elegir `Cualquiera`, `YASB` o `GlazeWM`.
3. Pulsar **Obtener configuración** o seleccionar un ejemplo.
4. Revisar la explicación y las configuraciones recuperadas.
5. Copiar `config.yaml` o `styles.css` con el botón correspondiente.

La pantalla inicial está documentada en
[docs/img/C-12.png](docs/img/C-12.png) y un resultado real en
[docs/img/C-13.png](docs/img/C-13.png).

## API

### `GET /api/ejemplos`

Devuelve las peticiones de `dbo.peticion_ejemplo`.

### `POST /api/rag`

Ejemplo de cuerpo:

```json
{
  "pregunta": "Necesito atajos para moverme entre ventanas",
  "herramienta": "GlazeWM"
}
```

`pregunta` es obligatoria y no puede superar 500 caracteres. `herramienta`
puede ser `null`, `YASB` o `GlazeWM`.

## Pruebas

Los scripts de [test/](test/) cubren:

- Generación y verificación de embeddings.
- Pruebas del procedimiento RAG.
- Búsqueda híbrida.
- Llamada REST desde SQL Server a Ollama.
- Permisos del usuario de la aplicación.

Ejemplos de ejecución:

```sql
EXECUTE dbo.sp_rag_configuracion
    N'Dame una barra con el clima de mi ciudad y un gestor de notificaciones';

EXECUTE dbo.sp_rag_configuracion
    N'atajos para mover ventanas',
    @herramienta = N'GlazeWM';
```

Para comprobar la sintaxis de Node:

```powershell
Set-Location backend
npm run check
```

## Seguridad y datos sensibles

- Las credenciales de SQL Server se leen desde variables de entorno.
- El frontend no se conecta directamente a SQL Server.
- Express utiliza consultas parametrizadas para ejecutar el procedimiento.
- El usuario de aplicación tiene permisos específicos mediante un rol.
- El código YAML y CSS se devuelve desde el catálogo, no se genera desde el
  texto producido por el LLM.
- Los tokens, claves y contraseñas deben sustituirse por marcadores como
  `TU_API_KEY` en el catálogo y nunca deben publicarse.
- Si una credencial real se ha expuesto, debe revocarse y sustituirse.

## Limitaciones conocidas

- La búsqueda vectorial es exacta mediante `VECTOR_DISTANCE`; no se ha
  incluido un índice vectorial porque el catálogo es reducido.
- El umbral de distancia se puede proporcionar al procedimiento, pero no se
  ha fijado un valor global.
- El resultado depende de que Ollama, Caddy, SQL Server y Express estén
  disponibles.
- La explicación del LLM puede fallar; en ese caso el procedimiento devuelve
  las configuraciones recuperadas con un mensaje alternativo.
- Vue se carga actualmente desde CDN.

## Documentación

- [Memoria técnica](docs/Proyecto.md)
- [Scripts SQL](sql/)
- [Scripts de IA](ai/)
- [Pruebas](test/)
