const { createApp, ref, computed, onMounted } = Vue;

// Pon esto en false cuando la API Express esté lista
const USAR_DATOS_DE_PRUEBA = false;
const API_BASE = '/api';
const MAX_CARACTERES = 500;

const EJEMPLOS_PRUEBA = [
  { peticion_id: 1, texto: 'Dame una barra con el clima de mi ciudad y un gestor de notificaciones' },
  { peticion_id: 2, texto: 'Necesito atajos de teclado para moverme entre ventanas' }
];

const RESPUESTA_PRUEBA = {
  llm_ok: true,
  explicacion: 'Texto de prueba: aquí irá la explicación que genera el modelo.',
  configuraciones: [{
    configuracion_id: 1,
    herramienta: 'YASB',
    titulo: 'Widget de clima en la barra con tarjeta de previsión',
    descripcion: 'Muestra el tiempo de tu ciudad en la barra con una tarjeta de previsión.',
    codigo_yaml: 'widgets:\n  weather:\n    type: "yasb.weather.WeatherWidget"',
    codigo_css: '.weather-card {\n  background-color: rgba(17, 17, 27, 0.5);\n}',
    distancia: 0.214,
    puntuacion: 0.033
  }]
};

createApp({
  setup() {
    const pregunta = ref('');
    const herramienta = ref('');
    const ejemplos = ref([]);
    const cargando = ref(false);
    const error = ref('');
    const resultado = ref(null);
    const copiado = ref('');

    const restantes = computed(() => MAX_CARACTERES - pregunta.value.length);

    async function cargarEjemplos() {
      try {
        if (USAR_DATOS_DE_PRUEBA) {
          ejemplos.value = EJEMPLOS_PRUEBA;
          return;
        }
        const resp = await fetch(`${API_BASE}/ejemplos`);
        if (!resp.ok) throw new Error();
        ejemplos.value = await resp.json();
      } catch {
        ejemplos.value = []; // sin ejemplos, la app sigue funcionando
      }
    }

    async function consultar() {
      const texto = pregunta.value.trim();
      if (!texto || cargando.value) return;

      cargando.value = true;
      error.value = '';
      resultado.value = null;

      try {
        let datos;
        if (USAR_DATOS_DE_PRUEBA) {
          await new Promise((r) => setTimeout(r, 600));
          datos = RESPUESTA_PRUEBA;
        } else {
          const resp = await fetch(`${API_BASE}/rag`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ pregunta: texto, herramienta: herramienta.value || null })
          });
          if (!resp.ok) throw new Error('el servidor respondió con el error ' + resp.status);
          datos = await resp.json();
        }

        // SQL Server devuelve "configuraciones" como texto JSON: se admite texto o lista
        const configs = typeof datos.configuraciones === 'string'
          ? JSON.parse(datos.configuraciones || '[]')
          : (datos.configuraciones || []);

        resultado.value = {
          llm_ok: !!datos.llm_ok,
          explicacion: datos.explicacion || '',
          configuraciones: configs
        };
      } catch (e) {
        error.value = 'No se ha podido completar la consulta: ' + e.message;
      } finally {
        cargando.value = false;
      }
    }

    function usarEjemplo(texto) {
      pregunta.value = texto;
      consultar();
    }

    function limpiar() {
      pregunta.value = '';
      herramienta.value = '';
      error.value = '';
      resultado.value = null;
    }

    async function copiar(texto, clave) {
      try {
        await navigator.clipboard.writeText(texto);
        copiado.value = clave;
        setTimeout(() => { if (copiado.value === clave) copiado.value = ''; }, 2000);
      } catch {
        copiado.value = '';
      }
    }

    onMounted(cargarEjemplos);

    return { pregunta, herramienta, ejemplos, cargando, error, resultado,
             copiado, restantes, consultar, usarEjemplo, limpiar, copiar };
  }
}).mount('#app');