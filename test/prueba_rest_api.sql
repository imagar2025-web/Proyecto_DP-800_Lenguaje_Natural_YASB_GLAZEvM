DECLARE @payload AS NVARCHAR (MAX) = N'{"model":"llama3.2","stream":false,"messages":[{"role":"user","content":"responde solo: hola"}]}';

DECLARE @resp AS NVARCHAR (MAX), @ret AS INT;

EXECUTE @ret = sp_invoke_external_rest_endpoint @url = N'https://localhost:8443/api/chat', @method = 'POST', @headers = N'{"Content-Type":"application/json"}', @payload = @payload, @timeout = 120, @response = @resp OUTPUT;

SELECT @ret AS codigo,
       JSON_VALUE(@resp, '$.result.message.content') AS respuesta,
       @resp AS respuesta_completa;