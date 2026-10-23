## Arranque de la aplicación

La aplicación tiene tres servicios:

- Vue se sirve desde `frontend/`.
- La API Express consulta SQL Server mediante `dbo.sp_rag_configuracion`.
- Caddy publica la aplicación y enruta las llamadas de Ollama y Express.

### 1. Configurar la API

Desde `backend/`, instala las dependencias:

```powershell
npm install
Copy-Item .env.example .env
```

Edita `.env` con las credenciales de `DesktopConfigDB`. El archivo `.env` no
debe incluirse en Git.

### 2. Arrancar los servicios

Arranca Ollama en el puerto `11434` y asegúrate de tener disponibles los
modelos configurados en SQL Server. Después, inicia la API:

```powershell
cd backend
npm start
```

Finalmente inicia Caddy usando el `Caddyfile` de la raíz. La aplicación estará
disponible en `https://localhost:8443`.

### 3. Flujo de una consulta

El navegador llama a `POST /api/rag`. Caddy reenvía esa ruta a Express en el
puerto `3000`. Express valida la entrada y ejecuta
`dbo.sp_rag_configuracion` con parámetros contra `DesktopConfigDB`. SQL Server
realiza la búsqueda híbrida y llama a Ollama a través de Caddy en
`/api/chat`. Express devuelve el resultado JSON que consume `frontend/app.js`.

## Documentación de la integración

La guía completa de configuración, arquitectura, problemas encontrados,
soluciones y finalidad de los archivos está en
[`docs/guia-integracion-aplicacion.md`](docs/guia-integracion-aplicacion.md).
