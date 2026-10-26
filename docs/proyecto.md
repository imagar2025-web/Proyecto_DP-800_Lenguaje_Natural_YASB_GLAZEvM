# Proyecto.md

# Asistente de configuraciones de escritorio con SQL Server 2025

> Nivel del proyecto:  3
> 

## 1. Portada

- Autor: Iván Martín García
- Asignatura: Modulo Big Data
- Fecha: 17_10_2026
- Repositorio: [enlace a GitHub](https://github.com/imagar2025-web/Proyecto_DP-800_Lenguaje_Natural_YASB_GLAZEvM)

## 2. Objetivo del proyecto

Este proyecto va a construir una solución típica de la personalización mas hardcore empleada en sistemas como linux pero adaptada a windows potenciando las herramientas ya creadas para esta tarea que son YASB y GlazeWM con un RAG para que nos ayuden con las configuraciones en base a lo que quiera conseguir el usuario. Al principio se mostrara el catalogo o ejemplos de peticiones.

Bloques cubiertos de la DP-800

- Diseño y desarrollo de la base de datos
- Desarrollo SQL asistido por IA
- Seguridad de SQL Server
- Optimización de consultas
- Modelos y embeddings
- Intelligent Search
- RAG

**Nivel elegido:** El nivel elegido de la dificultad del proyecto será del nivel 3 puesto a que bajo criterio propio la veo una solución más real y un caso practico que puedo emplear a nivel personal

**Entorno:** **SQL Server 2025 + T-SQL + SSMS** como núcleo, **Ollama** (embeddings y LLM) + **Copilot**  como IA, **Node.js + Express + HTML/CSS/JS** como interfaz, y **Git/GitHub + Markdown** para documentar y entregar. Todo se podrá realizar en local el proyecto

## 3. Caso de uso

El problema de la personalización en Windows como ya se conoce es bastante limitada en comparación a su sistema hermano como puede ser Linux con su capacidad total de acceso al código, facilitando así la personalización, y la complejidad de los gestores personalizados de Windows es una barrera para el usuario que quiere acercarse a estas personalizaciones.

El usuario objetivo de esta aplicación como ya bien se ha mencionado antes sería usuarios que estén interesados en personalizar sus escritorios de Windows pero sin tener mucha idea de lo que es el código persé.

El empleo de la aplicación / solución sería el siguiente una consulta a la base de datos en un lenguaje natural como podría ser “Dame una barra de tarea personalizada que refleje el tiempo en mi ciudad nombre X y un gestor de notificaciones. A continuación la repuesta que devolvería el sistema seria el código que tendría simplemente que copiar y pegar en el archivo de personalización el usuario final.

La búsqueda vectorial es la solución idónea para solucionar este problema puesto a que una búsqueda por similitudes sintácticas no sería suficiente puesto a que un usuario puede especificar algo de diferentes formas, por lo que la búsqueda semántica dada por los vectores no ayudara a devolver los parecidos mas probables para nuestro usuario final.

### Preparación del entorno y tecnologías

Instalamos el siguiente banco de tecnologías

- SQL SERVER
    
    ![SQL_version.png](img/SQL_version.png)
    
- Git Y OLLAMA
    
    ![git_ollama_version.png](img/git_ollama_version.png)
    
- Prueba de OLLAMA en funcionamiento

## Pruebas del modelo

### Prueba de Ollama y modelos

Comando:

```
ollama run llama3.2 "responde solo: hola"
ollama list
```

![pruebas_modelo.png](img/pruebas_modelo.png)

Resultado: modelos nomic-embed-text y llama3.2 instalados. Respuesta del modelo llama 3.2 = “hola”

Estructura del repositorio:

![estructura_repo.png](img/estructura_repo.png)

**Versiones usadas:**

| Herramienta | Versión |
| --- | --- |
| SQL Server | 2025 |
| SSMS | 22 |
| Git | 2.53 |
| Ollama | 0.40.5 |
| Modelos probados | llama 3.2 - nomic-embed-text |

## Sección 4: Arquitectura

**Componentes**

- **Vue** es la interfaz: ejemplos de peticiones, caja de texto y el YAML/CSS devuelto con botón de copiar.
- **Express** solo recibe la petición de Vue y ejecuta un procedimiento almacenado. Vue no puede hablar directamente con SQL Server, y así la lógica no queda repartida.
- **SQL Server** hace el trabajo de IA:
    - genera el embedding de la petición;
    - hace la búsqueda híbrida (full-text + vectorial);
    - construye el prompt con las configuraciones recuperadas;
    - llama al LLM y registra la consulta en `consulta_log`.
- **Ollama** corre en local y solo sirve los modelos.
- **Caddy**: es el proxy HTTPS entre SQL Server y Ollama, y explica por qué hace falta.
- **Git/GitHub + Markdown:** documentación y entrega.

**Flujo de consulta:**
Vue → Express → procedimiento almacenado → embedding de la petición → búsqueda → prompt → LLM → respuesta → `consulta_log` 

### Qué hace y qué NO hace cada pieza

**Vue (interfaz)**

- Hace: mostrar los ejemplos de peticiones, recoger la petición del usuario y presentar el YAML/CSS devuelto con un botón para copiarlo.
- No hace: hablar directamente con la base de datos ni tomar decisiones sobre qué configuración se devuelve.

**Express (API)**

- Hace: recibir la petición de Vue, ejecutar el procedimiento almacenado correspondiente y devolver su resultado.
- No hace: ninguna lógica de IA, ni generar embeddings, ni buscar, ni construir el prompt. Toda esa lógica vive en SQL Server y la API es solo un puente.

**SQL Server (procedimientos almacenados)**

- Hace: generar el embedding de la petición, buscar las configuraciones más parecidas (búsqueda semántica y full-text), construir el prompt con lo recuperado, llamar al LLM y registrar cada consulta en `consulta_log`.
- No hace: generar los modelos de lenguaje. Los llama a través de un endpoint externo.

**Caddy (proxy HTTPS)**

- Hace: recibir las llamadas HTTPS de SQL Server y reenviarlas a Ollama por HTTP, porque SQL Server solo acepta endpoints HTTPS.
- No hace: ninguna transformación de los datos. Solo hace de intermediario.

**Ollama (modelos)**

- Hace: servir `nomic-embed-text` (embeddings de 768 dimensiones) y `llama3.2` (redacción de la respuesta).
- No hace: guardar datos ni decidir qué se recupera.

**Reglas que se mantienen en todo el sistema**

- **El código sale siempre del catálogo.** El YAML y el CSS que recibe el usuario provienen de la tabla `configuracion`, nunca de lo que escriba el LLM.
- **El LLM no inventa configuraciones.** Solo recibe las ya recuperadas y se limita a explicarlas o a adaptarlas, por ejemplo cambiando la ciudad.
- **El usuario de la aplicación no accede a las tablas.** Solo ejecuta los procedimientos almacenados.

### Pendiente de confirmar

**Decisiones ya cerradas**

- Los embeddings se generan dentro de SQL Server con un modelo externo, no desde Node.
- Los embeddings se calculan sobre `titulo + descripcion`, no sobre el código.
- La búsqueda vectorial es exacta con `VECTOR_DISTANCE` (distancia coseno), sin índice vectorial, por el tamaño del catálogo.
- El número de resultados es un parámetro del procedimiento (`@top`), con un límite máximo de 20.

**Decisiones abiertas**

- **Umbral de distancia:** a partir de qué distancia se considera que no hay ninguna configuración parecida. Se fijará probando peticiones sin relación con el catálogo.
- **Peticiones compuestas:** si una petición como “barra con clima y notificaciones” devuelve una sola configuración o combina varias.
- **Peso de la búsqueda híbrida:** cómo combinar el resultado full-text con el vectorial, y si uno tiene más peso.
- **Llamada al LLM:** si se hace desde SQL Server o si el procedimiento devuelve el contexto y es Express quien llama a Ollama. Depende de lo que funcione con el endpoint HTTPS.
- **Cómo se presenta el resultado:** si se devuelve solo el código o también la explicación generada por el LLM.

## Sección 5: Modelo de datos

![image.png](img/image.png)

### Qué contiene cada tabla

- **`herramienta`**: YASB y GlazeWM. Separarla te permite filtrar por herramienta antes de la búsqueda vectorial.
- **`categoria`** y **`configuracion_categoria`**: etiquetas como barra, clima o notificaciones. Es una relación N:M porque una configuración puede tener varias (por ejemplo, una barra con clima y notificaciones).
- **`configuracion`**: es la tabla principal del RAG.
    - Guarda el título, la descripción en lenguaje natural, el código y el embedding.
    - El código está separado en `codigo_yaml` y `codigo_css`, porque YASB usa los dos archivos y GlazeWM solo YAML. Un `CHECK` obliga a que haya al menos uno.
    - `embedding` es `VECTOR(768)`, que es la dimensión de `nomic-embed-text`.
- **`peticion_ejemplo`**: los ejemplos que se muestran al arrancar la app, como pone en tu objetivo.
- **`consulta_log`**: guarda cada consulta, su distancia y su duración. Te servirá para las secciones de seguridad y optimización.

### Decisiones para el proyecto

- Para el texto del embeding lo razonable es concatenar `titulo + descripcion`, no el código. Los usuarios buscan en lenguaje natural, así que conviene que el vector represente eso.
- El índice vectorial no lo he incluido a propósito. En SQL Server 2025 es una función en preview, y con un catálogo pequeño vale la búsqueda exacta con `VECTOR_DISTANCE`.
- **Seguridad:** más adelante conviene crear un usuario de aplicación con permisos mínimos (solo `EXECUTE` de los `SP`) y no usar un usuario de administrador total de la base de datos desde vue.js.

Carga de datos para la ingesta del modelo y futuro RAG 

Se han proporcionado una serie de datos de ejemplo en la tabla de configuraciones con sus relaciones asociadas, dichas configuraciones tanto de YASB y GLAZE WM han sido sacadas de las configuraciones personalizadas propias y se agregaran la mayoría de los wignes y configuraciones posibles para una amplia personalización de cualquier usuario. Esta con el scrip de la carga de datos de ejemplo

Comprobaciones de la carga de los datos de ejemplo

![image.png](img/image%201.png)

## 6. Funcionalidades implementadas

De momento con los archivos (enlace de los nombre)

- carga del catalogo
- modelo de los datos
- Prueba de generación de embeding
- verificación de los embedings

## 7. Consultas o código más importante

Se han realizados unas pruebas previas posterior a la conexión del modelo con SQL Server 25. El `CREATE EXTERNAL MODEL`, la llamada de prueba a `AI_GENERATE_EMBEDDINGS` 

```sql
USE DesktopConfigDB;
GO
-- Registrar el modelo de embeddings (Ollama a través de Caddy)
CREATE EXTERNAL MODEL ollama_nomic
WITH (
    LOCATION   = 'https://localhost:8443/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL      = 'nomic-embed-text'
);
GO

--Probar que genera un vector
SELECT AI_GENERATE_EMBEDDINGS(N'prueba' USE MODEL ollama_nomic);
GO

```

![image.png](img/image%202.png)

## 8. Seguridad y/o optimización

Los secreto se han sacado fuera del catalogo y se han superpuestos por Nombres como `TU_API_KEY` 

Permitir la llamada rest de los endpoints para SQL Server

```sql
USE DesktopConfigDB;
GO

-- Permitir que SQL Server llame a endpoints REST
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO
```

## 9. Funcionamiento de la parte de IA

Un embedding es una lista de números (un Vector) que representa el significado de un texto a nivel matematico, el cual se emplea para poder realizar búsquedas a nivel semantico.

### **9.1 Texto vectorizado**

Los textos que se van a vectorizar van a ser el titulo y la descripción que es lo mas cercano al lenguaje natural que van a querer preguntar los usuarios.

### 9.2 Por qué `nomic-embed-text` da 768 dimensiones

El numero del vector creado se rige mas que nada por el modelo usado puesto a que si estos no coincidieran daría directamente un error.

### 9.3 Modelo externo

el modelo externo que ejecutara el proyecto en nuestro SQL Server es justo por que SQL Server no se encarga de cargar el modelo solo registra la url del endpoint para conectarse al modelo directamente, Así cuando generamos una llamda del método de `AI_GENERATE_EMBEDDINGS` guarda la base de datos el vector por una petición invocada por este método 

Con los embeddings ya generados, el siguiente paso es la búsqueda semántica

## 10. Capturas de resultados

## 11. Problemas encontrados

| Paso | Problema | Causa | Solución |
| --- | --- | --- | --- |
| 0/2 | `caddy trust` rechazaba la conexión al puerto 2019 | Se ejecutó antes de arrancar Caddy, y la API interna solo existe con Caddy en marcha | `caddy start` y después `caddy trust` como administrador |
| 2 | `curl` fallaba con `CRYPT_E_NO_REVOCATION_CHECK` | Windows no podía comprobar la revocación del certificado local | `curl.exe --ssl-no-revoke` |
| 2 | Msg 31608 al llamar a `AI_GENERATE_EMBEDDINGS` | SQL Server no confiaba en el certificado de Caddy | Importarlo en el almacén del equipo y reiniciar el servicio de SQL Server |
| 1 | Claves de API y token de GitHub en texto plano en la config | Archivos personales subidos tal cual | Sustituidos por marcadores en el catálogo y revocadas |
| 1 | `'6x'` en `outer_gap` de GlazeWM | Error de escritura | Corregido a `'6px'` |
| 2 | Msg 31608 con HRESULT 0x80072efd | Caddy u Ollama no estaban en ejecución, así que SQL Server no podía conectar con el endpoint | Arrancar ambos y comprobar con `curl` antes de usar el modelo |

## 12. Conclusiones

*(al final del proyecto)*