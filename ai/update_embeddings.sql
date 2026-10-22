UPDATE dbo.configuracion
SET    embedding = AI_GENERATE_EMBEDDINGS((N'search_document: ' + titulo + N'. ' + descripcion) USE MODEL ollama_nomic)
WHERE  activo = 1
       AND embedding IS NULL;