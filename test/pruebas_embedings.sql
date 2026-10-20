USE DesktopConfigDB;
GO

-- Permitir que SQL Server llame a endpoints REST
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
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

