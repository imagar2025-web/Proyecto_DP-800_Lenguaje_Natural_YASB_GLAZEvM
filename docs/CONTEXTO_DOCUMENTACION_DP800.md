# Contexto y siguientes pasos: documentación del mini-proyecto DP-800

> Este archivo es el **contexto base** para la IA que me ayudará a terminar la documentación.
> El desarrollo (BD, RAG, API y frontend) ya está hecho. Lo que falta es **documentarlo**.

---

## 1. Quién soy y cómo quiero que trabajes

- Soy Ivan, estudiante (DAW / máster de datos) en España. Escribo en español.
- Entrego un **mini-proyecto de Bases de Datos Vectoriales (DP-800)** con SQL Server 2025 en local.
- Entregables finales: **repositorio GitHub, README, PDF, PowerPoint y scripts SQL**.
- La memoria la redacto en **Notion** (página de 12 secciones) y después se pasa a PDF/README.
- Estilo deseado: español claro y técnico, en primera persona del plural o impersonal, con tablas, bloques de código y capturas. Sin relleno ni frases grandilocuentes.

**Reglas de trabajo:**
1. Trabaja **una sección cada vez** y espera mi confirmación antes de pasar a la siguiente.
2. **No inventes código, resultados, versiones ni salidas de consola.** Si te falta algo, pídemelo.
3. Cuando una sección necesite evidencia visual, **déjame un hueco de captura** (formato más abajo) y pídemela.
4. Entrega cada sección en **Markdown listo para pegar en Notion** (títulos `##`, tablas, bloques ```sql / ```js / ```yaml).
5. Si detectas incoherencias entre código y documentación, avísame en vez de corregirlas en silencio.

---

## 2. El proyecto en resumen

**Nombre:** Asistente de configuraciones de escritorio con SQL Server 2025
**Nivel:** 3 · **Módulo:** Big Data

**Objetivo:** un sistema RAG que, a partir de peticiones en lenguaje natural (por ejemplo, "quiero una barra con el clima y estilo oscuro"), recupera de una base de datos vectorial la configuración más adecuada para personalizar Windows con **YASB** (barra, YAML + CSS) y **GlazeWM** (gestor de ventanas tiling, YAML, incluidos atajos de teclado).

**Stack (todo en local):**

| Capa | Tecnología |
|---|---|
| Base de datos | SQL Server 2025 (tipo `VECTOR`), T-SQL, SSMS |
| Embeddings y LLM | Ollama (`nomic-embed-text`, 768 dimensiones) |
| Proxy HTTPS | Caddy delante de Ollama (SQL Server exige HTTPS para modelos externos) |
| Backend | Node.js + Express |
| Frontend | HTML + Vue, con contenedores semánticos (SEO) |
| Control de versiones | Git / GitHub + Markdown |

**Repositorio:** `github.com/imagar2025-web/Proyecto_DP-800_Lenguaje_Natural_YASB_GLAZEvM`
Carpetas: `ai`, `docs`, `presentacion`, `sql`, `test`, `Caddyfile`. El `README.md` y `docs/proyecto.md` siguen **provisionales**.

---

## 3. Qué se ha hecho técnicamente (resumen para contextualizar)

1. **Modelo de datos** (`DesktopConfigDB`): tablas `herramienta`, `categoria`, `configuracion` (con `embedding VECTOR(768)`, `codigo_yaml`, `codigo_css`), `configuracion_categoria` (N:M), `peticion_ejemplo` y `consulta_log`. Datos semilla de herramientas y categorías.
2. **Carga del catálogo** a partir de mis propios `config.yaml` y `styles.css` de YASB y el `config.yaml` de GlazeWM, en fragmentos por widget y por atajo.
3. **Integración con Ollama desde SQL Server:** `CREATE EXTERNAL MODEL` apuntando a Ollama a través de Caddy (HTTPS) y generación de embeddings con `AI_GENERATE_EMBEDDINGS` **dentro de la base de datos**.
4. **Búsqueda híbrida** (semántica con distancia coseno + Full-Text) en el procedimiento `sp_buscar_hibrido`.
5. **RAG en la base de datos:** `sp_rag_configuracion` llama a `sp_buscar_hibrido` mediante `INSERT … EXEC` y devuelve el contexto para el LLM (opción A elegida).
6. **API Express** que ejecuta el procedimiento RAG.
7. **Frontend Vue** que muestra el resultado (descripción, YAML y CSS) y registra la consulta.

> Los nombres exactos, firmas y código real deben tomarse de los archivos que te adjunte, no de este resumen.

### Problema real ya resuelto (para la sección "Problemas encontrados")

- **Síntoma:** en la instancia nueva de SQL Server, `AI_GENERATE_EMBEDDINGS` fallaba con `Msg 31608` (HRESULT `0x80070008`).
- **Causa:** SQL Server no confiaba en el certificado HTTPS de Caddy.
- **Solución:** arrancar Caddy con `caddy start` desde la carpeta del proyecto, ejecutar `caddy trust` y registrar la CA de Caddy con `certutil -addstore -f Root <ruta_CA>`.
- Hay que explicarlo también como **mini guía de arranque** (Ollama + Caddy + certificado).

---

## 4. Estado de la documentación (Notion, 12 secciones)

| Sección | Estado |
|---|---|
| Portada | Hecha |
| Objetivo | Hecha |
| Caso de uso | Hecha |
| Paso 0: entorno (tabla de versiones + capturas) | Hecha |
| Arquitectura | Hecha |
| Modelo de datos (con diagrama) | Hecha |
| **Funcionalidades** | **Pendiente** |
| **Código** (SQL, API, frontend) | **Pendiente** |
| **Seguridad y optimización** | **Pendiente** |
| **Uso de IA** (embeddings, LLM, RAG) | **Pendiente** |
| **Capturas / resultados** | **Pendiente** |
| **Problemas encontrados** | **Pendiente** |
| **Conclusiones** | **Pendiente** |

Después de la memoria: **README, PDF, PowerPoint y revisión de scripts SQL** en el repo.

---

## 5. Qué debes hacer, paso a paso

### Paso A: Revisar el material
Lee todo lo que te adjunte (scripts SQL, `server.js`, archivos Vue, texto de Notion ya escrito). Dime en una lista corta qué has entendido y qué te falta antes de redactar.

### Paso B: Redactar las secciones pendientes, en este orden

1. **Funcionalidades**: qué puede hacer el usuario (buscar por lenguaje natural, ver YAML/CSS, atajos de GlazeWM, peticiones de ejemplo, registro de consultas). Tabla de funcionalidades con descripción y componente que la implementa.
2. **Código**: explicación de los scripts por bloques (modelo, carga, modelo externo y embeddings, búsqueda híbrida, RAG, API, frontend). Cada bloque: propósito, fragmento clave y explicación breve.
3. **Uso de IA**: qué hace el embedding, cómo se calcula la distancia coseno, cómo se combina con Full-Text, cómo se construye el contexto del RAG y qué papel tiene el LLM.
4. **Seguridad y optimización**: consultas parametrizadas, validación de entrada, permisos mínimos, `consulta_log`, índices, límite de resultados, límites de la búsqueda vectorial. Basado solo en lo que realmente hay en el código.
5. **Capturas / resultados**: pruebas con peticiones reales y resultados obtenidos.
6. **Problemas encontrados**: incluye el error `Msg 31608` y la mini guía de arranque; pídeme los demás problemas que haya tenido.
7. **Conclusiones**: lo logrado, limitaciones y mejoras futuras.

### Paso C: Entregables finales
1. `README.md` del repo (descripción, requisitos, instalación, ejecución, estructura de carpetas, capturas clave).
2. Revisar `docs/proyecto.md` para que coincida con la memoria.
3. Guion/estructura del **PowerPoint**.
4. Lista de comprobación del **PDF** y de los **scripts SQL** (orden de ejecución numerado).

---

## 6. Huecos para capturas

En cada punto donde haga falta evidencia, escribe **exactamente** este bloque y **detente a pedírmela**:

```
> 📷 **[CAPTURA X-N]** — Qué debe verse: ... | Dónde sacarla: ... | Pie de figura: ...
```

Lista mínima de capturas a pedirme (puedes añadir más):

| Código | Contenido |
|---|---|
| C-01 | SSMS: tablas creadas en `DesktopConfigDB` (resultado de la comprobación final del script del modelo) |
| C-02 | Contenido de `configuracion` tras la carga del catálogo (YAML/CSS por fragmento) |
| C-03 | Ollama en ejecución con `nomic-embed-text` descargado (`ollama list`) |
| C-04 | Caddy arrancado y certificado instalado como CA raíz |
| C-05 | `CREATE EXTERNAL MODEL` ejecutado correctamente |
| C-06 | Columna `embedding` rellenada (consulta de comprobación) |
| C-07 | Índice y catálogo Full-Text creados |
| C-08 | Resultado de `sp_buscar_hibrido` para una petición de ejemplo |
| C-09 | Resultado de `sp_rag_configuracion` |
| C-10 | Error `Msg 31608` y su solución (antes/después) |
| C-11 | Prueba del endpoint de la API (navegador, curl o Postman) |
| C-12 | Pantalla de inicio del frontend con peticiones de ejemplo |
| C-13 | Resultado en el frontend con YAML y CSS mostrados |
| C-14 | Tabla `consulta_log` con registros |
| C-15 | Repositorio en GitHub con la estructura de carpetas |

---

## 7. Formato de salida de cada sección

- Título `##` con el número y nombre de la sección.
- Texto breve, tablas cuando se comparen cosas, bloques de código con lenguaje indicado.
- Los huecos de captura en el formato de la sección 6.
- Al final de cada sección: una línea **"Pendiente de mi parte:"** con lo que necesitas que te dé (capturas, código, datos).
