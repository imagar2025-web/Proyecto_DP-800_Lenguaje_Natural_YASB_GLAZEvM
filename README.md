# README

## Stack completo del proyecto

Todo corre en local sobre Windows 11. Lo he dividido por tipo de trabajo, para que veas qué usas en cada paso.

### Base de datos (el núcleo del proyecto)

| Herramienta | Uso | Pasos |
| --- | --- | --- |
| **SQL Server 2025** (edición Developer) | Tablas, vectores, procedimientos, seguridad, índices | 1 a 9 |
| **T-SQL** | Todos los scripts de `database/` y `ai/` | 1 a 9 |
| **SSMS 22** | Ejecutar scripts, planes de ejecución, diagrama de la BD, capturas | 1 a 9 |
| **Tipo `VECTOR`, `VECTOR_DISTANCE`, `AI_GENERATE_EMBEDDINGS`, `CREATE EXTERNAL MODEL`** | Embeddings y búsqueda vectorial dentro de SQL Server | 6 a 8 |

### IA local

| Herramienta | Uso |
| --- | --- |
| **Ollama** | Sirve los dos modelos en `localhost` |
| **Modelo de embeddings** (candidatos: `nomic-embed-text` o `all-minilm`) | Convierte las descripciones y las consultas en vectores. Decide cuál en el paso 6 y fija la dimensión |
| **LLM ligero** (candidatos: Llama 3.2 3B, Phi-3, Llama 3 8B si tu equipo lo aguanta) | Explica el snippet recuperado |
| **Proxy HTTPS local** (por ejemplo, Caddy) | Probablemente necesario para que SQL Server llame a Ollama. Compruébalo en el paso 6 |

Plan B si el proxy se complica: generar los embeddings con un script y guardarlos en la columna `VECTOR`.

### Aplicación web (última capa)

| Capa | Herramienta |
| --- | --- |
| Backend | **Node.js + Express** |
| Conexión a SQL Server | **`mssql`** |
| Secretos | **`dotenv`** (`.env` fuera de Git, más un `.env.example`) |
| Llamada al LLM | **API HTTP de Ollama** con `fetch` |
| Frontend | **HTML + CSS + JavaScript** (Vue 3 solo si te sobra tiempo) |
| Resaltado de código | **highlight.js** o **Prism**, instalado con npm |
| Validar YAML | **js-yaml** |
| Vista previa del CSS | **Shadow DOM** o iframe con `sandbox` |

### Preparación del dataset

| Herramienta | Uso |
| --- | --- |
| **Tus configs de GlazeWM y YASB** | Fuente de los snippets |
| **CSV o JSON** (`wm, categoria, descripcion, codigo`) | Formato intermedio |
| **Un script en Node** (o Python, si lo prefieres) | Convierte ese CSV en `03_insert_data.sql` |

No necesitas Python para nada más: la vectorización se hace en SQL Server.

### Control de versiones y entregables

| Herramienta | Uso |
| --- | --- |
| **Git + GitHub** | Repositorio y reproducibilidad |
| **VS Code** | Editar `.sql`, `.md` y la app |
| **Markdown** | `README.md` y `docs/proyecto.md` |
| **Extensión “Markdown PDF” de VS Code** o **Pandoc** | Exportar `proyecto.md` a PDF |
| **Mermaid**, **draw.io** o el diagrama de SSMS | Diagrama de arquitectura y diagrama entidad-relación |
| **PowerPoint** | La presentación |
| **Herramienta de capturas** (Recortes de Windows) | Evidencias de ejecución |

### IA como asistente (Bloque B, opcional)

Cualquier asistente que ya uses (GitHub Copilot o un chat). Lo importante no es la herramienta, sino documentar el prompt, la respuesta, qué aceptaste, qué corregiste y cómo lo verificaste.

### Qué se ejecuta en local

| Componente | Cómo se arranca |
| --- | --- |
| SQL Server 2025 | Servicio de Windows |
| Ollama | Servicio en segundo plano (`localhost:11434`) |
| Proxy HTTPS (si hace falta) | Una terminal |
| Backend Express | Una terminal con `node server.js` |
| Frontend | Lo sirve el propio Express; lo abres en el navegador |

La única salida a internet es la instalación inicial (instaladores, modelos de Ollama y paquetes npm) y subir el repositorio a GitHub. En la demo no cargues nada desde CDN.