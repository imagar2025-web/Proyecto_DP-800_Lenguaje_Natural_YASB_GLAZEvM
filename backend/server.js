import 'dotenv/config';
import express from 'express';
import sql from 'mssql';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const port = Number(process.env.PORT || 3000);

const sqlConfig = {
  server: process.env.DB_SERVER || 'localhost',
  port: Number(process.env.DB_PORT || 1433),
  database: process.env.DB_NAME || 'DesktopConfigDB',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: process.env.DB_ENCRYPT !== 'false',
    trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true'
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

if (!sqlConfig.user || !sqlConfig.password) {
  console.warn('DB_USER y DB_PASSWORD no están configuradas; las consultas SQL fallarán.');
}

app.use(express.json({ limit: '32kb' }));
app.use(express.static(path.resolve(__dirname, '..', 'frontend')));

async function getPool() {
  return sql.connect(sqlConfig);
}

app.get('/api/ejemplos', async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT peticion_id, texto
      FROM dbo.peticion_ejemplo
      ORDER BY peticion_id;
    `);

    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

app.post('/api/rag', async (req, res, next) => {
  try {
    const { pregunta, herramienta = null } = req.body ?? {};

    if (typeof pregunta !== 'string' || !pregunta.trim()) {
      return res.status(400).json({
        error: 'La pregunta es obligatoria.'
      });
    }

    if (pregunta.trim().length > 500) {
      return res.status(400).json({
        error: 'La pregunta no puede superar los 500 caracteres.'
      });
    }

    if (herramienta !== null && herramienta !== '' &&
        !['YASB', 'GlazeWM'].includes(herramienta)) {
      return res.status(400).json({
        error: 'La herramienta debe ser YASB, GlazeWM o null.'
      });
    }

    const pool = await getPool();
    const result = await pool
      .request()
      .input('pregunta', sql.NVarChar(500), pregunta.trim())
      .input('herramienta', sql.NVarChar(50), herramienta || null)
      .execute('dbo.sp_rag_configuracion');

    const row = result.recordset[0];
    if (!row) {
      return res.status(502).json({
        error: 'El procedimiento RAG no devolvió ningún resultado.'
      });
    }

    let configuraciones = [];
    if (row.configuraciones) {
      try {
        configuraciones = typeof row.configuraciones === 'string'
          ? JSON.parse(row.configuraciones)
          : row.configuraciones;
      } catch (error) {
        error.message = 'La respuesta de configuraciones no es JSON válido.';
        return next(error);
      }
    }

    res.json({
      llm_ok: Boolean(row.llm_ok),
      explicacion: row.explicacion || '',
      configuraciones: Array.isArray(configuraciones) ? configuraciones : [],
      error: row.error || null
    });
  } catch (error) {
    next(error);
  }
});

app.use((error, req, res, next) => {
  console.error('Error de API:', error);
  if (res.headersSent) {
    return next(error);
  }

  res.status(500).json({
    error: 'Error interno del servidor.'
  });
});

const server = app.listen(port, () => {
  console.log(`API disponible en http://localhost:${port}`);
});

async function closeServer(signal) {
  console.log(`${signal}: cerrando API...`);
  server.close(async () => {
    try {
      await sql.close();
      process.exit(0);
    } catch (error) {
      console.error('No se pudo cerrar SQL Server:', error);
      process.exit(1);
    }
  });
}

process.once('SIGINT', () => closeServer('SIGINT'));
process.once('SIGTERM', () => closeServer('SIGTERM'));
