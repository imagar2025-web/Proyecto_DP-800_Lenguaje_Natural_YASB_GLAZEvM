/* =====================================================================
   Paso 1 (carga): Catalogo inicial de configuraciones
   Origen: configuraciones propias de YASB (config.yaml + styles.css) y GlazeWM.
   - Las claves y datos personales tienen por marcadores (TU_API_KEY,
     TU_TOKEN_DE_GITHUB, TU_CIUDAD).
   - Ejecutar UNA sola vez, despues de 01_modelo_datos.sql.
   ===================================================================== */
USE DesktopConfigDB;


GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

/* Categorias nuevas (las 6 iniciales ya existen) */
INSERT INTO dbo.categoria (
  nombre
)
SELECT N'atajos'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'atajos');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'audio'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'audio');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'barra'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'barra');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'clima'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'clima');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'desarrollo'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'desarrollo');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'espacios de trabajo'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'espacios de trabajo');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'multimedia'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'multimedia');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'notificaciones'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'notificaciones');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'productividad'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'productividad');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'rendimiento'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'rendimiento');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'tema'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'tema');

INSERT INTO dbo.categoria (
  nombre
)
SELECT N'ventanas'
WHERE  NOT EXISTS (SELECT 1
                   FROM   dbo.categoria
                   WHERE  nombre = N'ventanas');

DECLARE @id AS INT;

/* Estructura de la barra superior de YASB */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Estructura de la barra superior de YASB', N'Barra superior a todo el ancho con efecto de desenfoque y esquinas redondeadas. Coloca el gestor de ventanas, el pomodoro y la ventana activa a la izquierda, el reloj en el centro y el estado del sistema a la derecha. Sirve como base para montar una barra de tareas personalizada en Windows.', N'bars:
  primary-bar:
    enabled: true
    screens: ["primary"]
    class_name: "yasb-bar"
    alignment:
      position: "top"
      center: false
    animation:
      enabled: true
      duration: 1000
    blur_effect:
      enabled: true
      acrylic: false
      dark_mode: true
      round_corners: true
      round_corners_type: "normal"
      border_color: "System"
    window_flags:
      always_on_top: false
      windows_app_bar: true
    dimensions:
      width: "100%"
      height: 32
    padding:
      top: 6
      left: 6
      bottom: 0
      right: 6
    widgets:
      left: [
        "glazewm_tiling_direction",
        "glazewm_workspaces", 
        "pomodoro",       
        "active_window"
      ]
      center: [
        "clock"
      ]
      right: [
        # "cava",
        "vscode",
        "github",
        "systray",
        "media",
        "weather",
        "microphone",
        "volume",
        "cpu",
        "memory",
        "notifications",
        #"wallpapers",
        "power_menu",
        ]', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'barra');

/* Tema base de la barra: fondo oscuro y acentos dorados */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Tema base de la barra: fondo oscuro y acentos dorados', N'Estilos CSS generales de la barra: fuente JetBrainsMono, fondo gris oscuro, texto dorado y márgenes de los widgets. Cámbialo para dar otro color o tipografía a toda la barra.', NULL, N'* {
	font-size: 12px;
	color: #e7b467;
	/* color: #cdd6f4; */
	font-weight: 500;
	font-family: "JetBrainsMono NFP";
	margin: 0;
	padding: 0;
}
.yasb-bar {
	padding: 0 8px;
	margin: 0;
    /* background-color: #1e1e2e; */
    background-color: #363436;
    /* border-radius: 10px; */
    

}
.widget {
	padding: 0 10px;
	margin: 0;
}
.widget .label {
	padding: 2px 2px 1px 2px;
 
}
.widget .label.alt {
	padding: 1px 8px 1px 8px;
}
 .clock-widget .label {
    padding-left:8px;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'tema', N'barra');

/* Widget de clima en la barra con tarjeta de previsión */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Widget de clima en la barra con tarjeta de previsión', N'Muestra el tiempo de tu ciudad en la barra con icono y temperatura, y una tarjeta desplegable con la previsión por horas. Hay que poner tu clave de API del servicio de clima y el nombre de tu ciudad. Para quien pide el clima, la temperatura o el tiempo en la barra de tareas.', N'widgets:
  weather:
    type: "yasb.weather.WeatherWidget"
    options:
      label: "<span>{icon}</span> {temp}"
      label_alt: "{location}: Min {min_temp}, Max {max_temp}, Hum {humidity}%"
      api_key: "TU_API_KEY"  # <--- PEGA AQUÍ TU CLAVE ENTRE COMILLAS
      update_interval: 600
      hide_decimal: true
      location: "TU_CIUDAD, ES"
      callbacks:
        on_left: "toggle_card"
      icons:
        sunnyDay: "\ue30d"
        clearNight: "\ue32b"
        cloudyDay: "\ue312"
        cloudyNight: "\ue311"
        rainyDay: "\ue308"
        rainyNight: "\ue333"
        #snowyIcyDay: "\ue30a"
        #snowyIcyNight: "\ue335"
        blizzardDay: "\udb83\udf36"
        blizzardNight: "\udb83\udf36"
        foggyDay: "\ue303"
        foggyNight: "\ue346"
        thunderstormDay: "\ue30f"
        thunderstormNight: "\ue338"
        default: "\uebaa"
      weather_card:
        blur: True
        round_corners: True
        round_corners_type: "normal"
        border_color: "System"
        alignment: "right"
        direction: "down"
        icon_size: 64
        show_hourly_forecast: True
        time_format: "24h"
        hourly_point_spacing: 76
        hourly_icon_size: 32
        icon_smoothing: true
        temp_line_width: 2
        current_line_color: "#8EAEE8"
        current_line_width: 1
        current_line_style: "dot"
      label_shadow:
        enabled: true
        color: "black"
        radius: 3
        offset: [ 1, 1 ]', N'/* WEATHER WIDGET */
.weather-card {
    background-color: rgba(17, 17, 27, 0.5);
}
.weather-card-today {
    border: 1px solid #282936;
    border-radius: 8px;
    background-color:  #06020310;
}
.weather-card-today .label {
    font-size: 12px;
}
.weather-card-today .label.location {
    font-size: 24px;
    font-weight: 700;
}
.weather-card-today .label.alert {
    font-size: 12px;
    font-weight: 700;
    background-color: rgba(247, 199, 42, 0.05);
    border: 1px solid rgba(247, 209, 42, 0.1);
    color: rgba(196, 181, 162, 0.85);
    border-radius: 6px;
    padding: 5px 0;
}
.weather-card-day {
    border: 1px solid #45475a;
    border-radius: 8px;
    background-color:  rgba(17, 17, 27, 0.2);
}

.weather-card-day.active {
    background-color: rgba(40, 40, 60, 0.6);
    border: 1px solid rgba(50, 50, 75, 1);
}

.weather-card-day:hover {
    background-color: rgba(40, 40, 60, 0.6);
}

.weather-card-day .label {
    font-size: 12px;
}

.weather-card .hourly-container {
    border: 1px solid #282936;
    background-color: #3c5fa0;
    border-radius: 8px;
    min-height: 150px;
}

.weather-card .hourly-data {
    /* font-family: ''Segoe UI'';*/
    /* color: cyan;*/ /* <- Font color */
    background-color: #FAE93F; /* <- Curve color */
    font-size: 12px;
    font-weight: bold;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'clima', N'barra');

/* Reloj en la barra con calendario desplegable */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Reloj en la barra con calendario desplegable', N'Reloj en el centro de la barra que al pulsarlo abre un calendario con día, mes y fecha grande. Para quien quiere ver la hora y consultar el calendario desde la barra.', N'widgets:
  clock:
    type: "yasb.clock.ClockWidget"
    options:
      label: "{%I:%M:%S}"
      label_alt: "{%I:%M:%S}"
      timezones: []
      callbacks:
        on_left: "toggle_calendar"', N'.calendar {
    background-color: rgba(17, 17, 27, 0.4);
}
.calendar .calendar-table,
.calendar .calendar-table::item {
    background-color: rgba(17, 17, 27, 0);
    /* color: rgba(162, 177, 196, 0.85); */
    
    color: #e8e5e1;
    font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
    border: none;
    outline: none;  
}
.calendar .calendar-table::item:selected {
    color: #e7b467;
    background-color: #292a2ba8;
    border-radius: 10px;
}
.calendar .day-label {
    margin-top: 20px;
}
.calendar .day-label,
.calendar .month-label,
.calendar .date-label,
.calendar .week-label,
.calendar .holiday-label {
    font-family: ''Segoe UI'';
    font-size: 16px;
    color: #9a6e2c;
    font-weight: 700;
    min-width: 180px;
    max-width: 180px;
}
.calendar .week-label,
.calendar .holiday-label {
    font-size: 12px;
    font-weight: 600;
    color: rgba(85, 85, 86, 0.85);
}
.calendar .holiday-label {
    color: rgba(114, 117, 122, 0.85);
    font-weight: 700;
}
.calendar .month-label {
    font-weight: normal;
}
.calendar .date-label {
    font-size: 88px;
    font-weight: 900;
    color: rgb(186, 178, 178);
    margin-top: -20px;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'barra');

/* Reproductor multimedia en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Reproductor multimedia en la barra', N'Muestra la canción que suena (título o artista) con botones de control y un menú con la carátula y la barra de progreso. Colores distintos según el reproductor: Spotify, Firefox, Edge o Chrome.', N'widgets:
  media:
      type: "yasb.media.MediaWidget"
      options:
        label: "<span>\uf001</span> {title}"
        label_alt: "<span>\uf001</span> {artist}"
        callbacks:
          on_left: "toggle_media_menu"
          on_middle: "do_nothing"
          on_right: "do_nothing"
        max_field_size:
          label: 50
          label_alt: 24
        show_thumbnail: false
        controls_only: false
        controls_left: true
        hide_empty: true
        thumbnail_alpha: 250
        thumbnail_padding: 8
        thumbnail_corner_radius: 0
        icons:
          prev_track: ""
          next_track: ""
          play: ""
          pause: ""', N'.media-widget {
	padding: 0;
	margin: 0;
}
.media-widget .label {
	color: #f19408;
    padding: 0px;
	padding-right: 4px;
}
.media-menu {
    min-width: 420px;
    max-width: 420px;
    background-color: rgba(31, 39, 49, 0.5);
}
.media-menu .title,
.media-menu .artist,
.media-menu .source {
    font-size: 14px;
    font-weight: 600;
    margin-left: 10px;
    font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
}
.media-menu .artist {
    font-size: 13px;
    color: #6c7086;
    margin-top: 0px;
    margin-bottom: 8px;
}
.media-menu .source {
    font-size: 11px;
    color: #000;
    font-weight: normal;
    border-radius: 3px;
    background-color: #bac2de;
    padding: 2px 4px;

}
/* The source class name is the same as what you see in the media widget; just replace spaces with dashes and convert it to lowercase. 
Example: "Windows Media" becomes "windows-media" */
/* Colores segun el reproductor */
.media-menu .source.firefox {
    background-color: #ff583b;
    color: #ffffff;
}
.media-menu .source.spotify {
    background-color: #199143;
    color: #ffffff;
}
.media-menu .source.edge {
    background-color: #0078d4;
    color: #ffffff;
}
.media-menu .source.chrome {
    background-color: #b9c21b;
    color: #ffffff;
}
.media-menu .source.windows-media {
    background-color: #0078d4;
    color: #ffffff;
}


.media-menu .btn {
    font-family: "Segoe Fluent Icons";
    font-size: 14px;
    font-weight: 400;
    margin: 10px 2px 0px 2px;
    min-width: 40px;
    max-width: 40px;
    min-height: 40px;
    max-height: 40px;
    border-radius: 20px;
}
.media-menu .btn.prev {
    margin-left: 10px;
}
.media-menu .btn:hover {
    color: white;
    background-color: rgba(255, 255, 255, 0.1);
}
.media-menu .btn.play {
    background-color: rgba(255, 255, 255, 0.1);
    font-size: 20px
}
.media-menu .btn.disabled:hover,
.media-menu .btn.disabled {
    color: #4e525c;
    background-color: rgba(0, 0, 0, 0);
}

.media-menu .playback-time {
    font-size: 13px;
    font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
    /* LETRAS MEDIA */
    color: #e7b467;
    margin-top: 20px;
    min-width: 100px;
}
.media-menu .progress-slider {
    height: 10px;
    margin: 5px 4px;
    border-radius: 3px;
}
.media-menu .progress-slider::groove {
    background: transparent;
    height: 2px;
    border-radius: 3px;
    background: rgba(255, 255, 255, 0.1);

}
.media-menu .progress-slider::groove:hover {
    background: transparent;
    height: 6px;
    border-radius: 3px;
    background: rgba(255, 255, 255, 0.2);
}
.media-menu .progress-slider::sub-page {
    background: white;
    border-radius: 3px;
    height: 4px;
}
 /* Hide media widget buttons */
.media-widget .btn {
	padding: 0;
	margin: 0 -6px;
    padding-left: 4px;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'multimedia', N'barra');

/* Temporizador Pomodoro en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Temporizador Pomodoro en la barra', N'Temporizador Pomodoro en la barra con sesiones de trabajo de 25 minutos y descansos de 5 y 15. Incluye menú con círculo de progreso y avisos con sonido. Para estudiar o trabajar por intervalos.', N'widgets:
  pomodoro:
    type: "yasb.pomodoro.PomodoroWidget"
    options:
      label: "<span>{icon}</span> {remaining}"
      label_alt: "<span>{icon}</span> {session}/{total_sessions} - {status}"
      work_duration: 25
      break_duration: 5
      long_break_duration: 15
      long_break_interval: 4
      auto_start_breaks: true
      auto_start_work: true
      sound_notification: true
      show_notification: true
      hide_on_break: false
      session_target: 8
      icons:
        work: "\uf252"
        break: "\uf253"
        paused: "\uf254"
      container_padding:
        top: 0
        left: 12
        bottom: 0
        right: 12
      menu:
        blur: true
        round_corners: true
        round_corners_type: "normal"
        border_color: "System"
        alignment: "right"
        direction: "down"
        offset_top: 6
        offset_left: 0
        circle_background_color: "#09ffffff"
        circle_work_progress_color: "#88c0d0"
        circle_break_progress_color: "#a3be8c"
        circle_thickness: 8
        circle_size: 160
      callbacks:
        on_left: "toggle_menu"
        on_middle: "reset_timer"
        on_right: "toggle_label"
      label_shadow:
        enabled: true
        color: "black"
        radius: 3
        offset: [ 1, 1 ]', N'.pomodoro-widget {
    padding: 0 0 0 0;
}
.pomodoro-widget .icon {
    font-size: 12px;
    padding-right: 4px;
}
.pomodoro-widget .label.paused,
.pomodoro-widget .icon.paused {
    color: #7d7e8b;
}
.pomodoro-widget .label.work,
.pomodoro-widget .icon.work {
    color: #bababa;
    /* CAMBIO  */
}
.pomodoro-widget .label.break,
.pomodoro-widget .icon.break {
    color: #e64af4c1;
}
/* Pomodoro menu styling */
.pomodoro-menu {
    background-color: rgba(17, 17, 27, 0.2);
    border-radius: 8px;
}
.pomodoro-menu .header {
    font-size: 16px;
    font-weight: 600;
    max-height: 0px;
    color: #ffffff;
}
.pomodoro-menu .status {
    font-size: 18px;
    font-weight: 600;
    color: #cdd6f4;
}
.pomodoro-menu .session {
    font-size: 12px;
    color: #a6adc8;
}
.pomodoro-menu .button {
    background-color: #3f4053;
    color: #cdd6f4;
    border: none;
    border-radius: 4px;
    padding: 6px 12px;
}
.pomodoro-menu .button.start {
    background-color: #3f4053;
}
.pomodoro-menu .button.reset {
    background-color: #3f4053;
}
.pomodoro-menu .button:hover {
    background-color: rgba(255, 255, 255, 0.158);
}
.pomodoro-menu .button.pause {
    background-color: #e64af4c1;
    color: #1e1e2e;
}
.pomodoro-menu .button:pressed {
    background-color: #5a5b6e;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'productividad', N'barra');

/* Monitor de CPU y memoria RAM en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Monitor de CPU y memoria RAM en la barra', N'Uso de CPU y de memoria RAM en la barra, con umbrales de color (bajo, medio, alto) y modo alternativo con histograma. Para vigilar el rendimiento del equipo de un vistazo.', N'widgets:
  cpu:
    type: "yasb.cpu.CpuWidget"
    options:
      label: "<span>\uf4bc</span> {info[percent][total]}"
      label_alt: "<span>\uf437</span> {info[histograms][cpu_percent]}"
      update_interval: 2000
      cpu_thresholds:
        low: 25
        medium: 50
        high: 90
      histogram_icons:
        - "\u2581" # 0%
        - "\u2581" # 10%
        - "\u2582" # 20%
        - "\u2583" # 30%
        - "\u2584" # 40%
        - "\u2585" # 50%
        - "\u2586" # 60%
        - "\u2587" # 70%
        - "\u2588" # 80%+
      histogram_num_columns: 8
      callbacks:
        on_right: "exec cmd /c Taskmgr"
      label_shadow:
        enabled: true
        color: "black"
        radius: 3
        offset: [ 1, 1 ]
  memory:
    type: "yasb.memory.MemoryWidget"
    options:
      label: "<span>\uf4bc</span> {virtual_mem_percent}"
      label_alt: "<span>\uf4bc</span> VIRT: {virtual_mem_percent}% SWAP: {swap_mem_percent}%"
      update_interval: 5000
      callbacks:
        on_left: "toggle_label"
        on_middle: "do_nothing"
        on_right: "do_nothing"
      memory_thresholds:
        low: 25
        medium: 50
        high: 90
      histogram_icons:
        - "\u2581" # 0%
        - "\u2581" # 10%
        - "\u2582" # 20%
        - "\u2583" # 30%
        - "\u2584" # 40%
        - "\u2585" # 50%
        - "\u2586" # 60%
        - "\u2587" # 70%
        - "\u2588" # 80%+
      label_shadow:
        enabled: true
        color: "black"
        radius: 3
        offset: [ 1, 1 ]', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'rendimiento', N'barra');

/* Control de volumen y micrófono en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Control de volumen y micrófono en la barra', N'Iconos de volumen y micrófono en la barra: clic para silenciar y clic derecho para abrir los ajustes de sonido de Windows.', N'widgets:
  volume:
    type: "yasb.volume.VolumeWidget"
    options:
      label: "<span>{icon}</span> {level}"
      label_alt: "{volume}"
      tooltip: false
      volume_icons:
        - "\ueee8"
        - "\uf026"
        - "\uf027"
        - "\uf027"
        - "\uf028"
      callbacks:
        on_left: "toggle_mute"
        on_right: "exec cmd.exe /c start ms-settings:sound"
  microphone:
    type: "yasb.microphone.MicrophoneWidget"
    options:
      label: "<span>{icon}</span> {level}"
      label_alt: "<span>{icon}</span> {level}%"
      icons:
        normal: "\udb80\udf6c"
        muted: "\udb80\udf6d"
      callbacks:
        on_left: "toggle_mute"
        on_middle: "toggle_label"
        on_right: "exec cmd.exe /c start ms-settings:sound"', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'audio', N'barra');

/* Notificaciones en la barra con contador */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Notificaciones en la barra con contador', N'Widget que muestra el número de notificaciones pendientes y se oculta cuando no hay ninguna. Gestor sencillo de avisos para la barra de tareas.', N'widgets:
  notifications:
    type: "yasb.notifications.NotificationsWidget"
    options:
      label: "<span>\uf476</span> {count}"
      label_alt: "{count} notifications"
      hide_empty: true
      tooltip: false
      callbacks:
        on_left: "toggle_notification"
        on_right: "do_nothing"
        on_middle: "toggle_label"', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'notificaciones', N'barra');

/* Notificaciones de GitHub en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Notificaciones de GitHub en la barra', N'Muestra en la barra las notificaciones no leídas de GitHub, con punto de aviso y un menú con pull requests, issues y releases. Necesita un token personal de GitHub, que debes poner tú.', N'widgets:
  github:
    type: "yasb.github.GithubWidget"
    options:
      label: "<span>\ueba1</span>"
      label_alt: "Notifications {data}" # {data} return number of unread notification
      token: TU_TOKEN_DE_GITHUB # GitHub Personal access tokens (classic) https://github.com/settings/tokens
      max_notification: 30 # Max number of notification displaying in menu max: 50
      notification_dot:
        enabled: True
        corner: "bottom_left" # Can be "top_left", "top_right", "bottom_left", "bottom_right"
        color: "red" # Can be hex color or string
        margin: [ 1, 1 ] # x and y margin for the dot
      only_unread: false # Show only unread or all notifications; 
      show_comment_count: false # Summarize comment totals for issues, PRs, and discussions
      reason_filters: [] # e.g. [''mention'', ''assign''] to limit notifications by reason
      max_field_size: 54 # Max characters in title before truncation.
      update_interval: 300 # Check for new notification in seconds
      menu:
        blur: True # Enable blur effect for the menu
        round_corners: True # Enable round corners for the menu (this option is not supported on Windows 10)
        round_corners_type: "normal" # Set the type of round corners for the menu (normal, small) (this option is not supported on Windows 10)
        border_color: "System" # Set the border color for the menu (this option is not supported on Windows 10)
        alignment: "right"
        direction: "down"
        show_categories: false
        categories_order: ["PullRequest", "Issue", "CheckSuite", "Release", "Discussion"]
      label_shadow:
        enabled: True
        color: "black"
        radius: 3
        offset: [ 1, 1 ]', N'.github-menu    {
    background-color:  rgba(17, 17, 27, 0.2);
    max-height: 500px;
    min-height: 500px;
    min-width: 420px;
}
.github-menu .header {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    font-size: 15px;
    font-weight: 400;
    font-family: ''Segoe UI'';
    padding: 8px;
    color: white;
    background-color: rgba(17, 17, 27, 0.75);
}
.github-menu .footer {
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    padding: 4px 8px 6px 8px;
    background-color: rgba(17, 17, 27, 0.75);
}
.github-menu .footer .label{
    font-size: 12px;
    font-family: ''Segoe UI'';
    color: #9399b2;
}
.github-menu .contents {
    background-color:  rgba(17, 17, 27, 0.2);
}
.github-menu .contents .item {
    min-height: 40px;
    padding: 6px 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.075);
}
.github-menu .contents .item:hover {
    background-color: rgba(255, 255, 255, 0.05);
    border-bottom: 1px solid rgba(255, 255, 255, 0);
}
.github-menu .contents .item .title,
.github-menu .contents .item .description {
    color: #9399b2;
    font-family: Segoe UI;
}
.github-menu .contents .item .title {
    font-size: 14px;
    font-weight: 600; 
}
.github-menu .contents .item .description {
    font-size: 12px;
    font-weight: 500
}
.github-menu .contents .item.new .title,
.github-menu .contents .item.new .description {
    color: #ffffff
}
.github-menu .contents .item .icon {
    font-size: 16px;
    padding-right: 0;
    padding-left: 8px;
    padding-right: 4px;
    color: #9399b2;
}
.github-menu .contents .item.new .icon {
    color: #3fb950;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'notificaciones', N'desarrollo', N'barra');

/* Accesos rápidos a proyectos recientes de VS Code */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Accesos rápidos a proyectos recientes de VS Code', N'Botón en la barra que abre un menú con las carpetas y proyectos recientes de VS Code (o de otro editor con línea de comandos) para abrirlos con un clic.', N'widgets:
  vscode:
    type: "yasb.vscode.VSCodeWidget"
    options:
      label: "<span>\udb82\ude1e</span>"
      label_alt: "<span>\udb82\ude1e</span> recents"
      menu_title: "<span style=''font-weight:bold''>VScode</span> recents"
      max_field_size: 50
      folder_icon: "\uf114"
      file_icon: "\uf016"
      truncate_to_root_dir: false
      hide_folder_icon: false
      hide_file_icon: false
      max_number_of_folders: 30
      max_number_of_files: 0 # set to 0 if you only want folders
      modified_date_format: "Date modified: %Y-%m-%d %H:%M"
      cli_command: "code" # or "codium" or "windsurf" or any other CLI command to open the workspace
      menu:
        blur: true
        round_corners: true
        round_corners_type: "small"
        alignment: ''center''
        offset_top: 0', N'.vscode-widget .widget-container .icon {
    color: #fe41fb;
}

.vscode-menu {
    max-height: 500px;
    min-width: 300px;
}

.vscode-menu .header {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    font-size: 15px;
    font-weight: 400;
    padding: 8px;
    color: #cdd6f4;
    background-color: rgba(17, 17, 27, 0.4);
}

.vscode-menu .contents {
    background-color: rgba(17, 17, 27, 0.4);
}

.vscode-menu .contents .item {
    min-height: 30px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.075);
}

.vscode-menu .contents .item .title {
    font-size: 12px;
    margin-right: 5px;
}

.vscode-menu .contents .item .modified-date {
    font-size: 11px;
    margin-right: 5px;
    color: #797e91;
}

.vscode-menu .contents .item .folder-icon {
    font-size: 16px;
    margin-left: 8px;
    color: #f2cdcd;
}

.vscode-menu .contents .item .file-icon {
    font-size: 16px;
    margin-left: 8px;
    color: #cba6f7;
}

.vscode-menu .contents .item:hover {
    background-color: #45475a;
    border-bottom: 1px solid rgba(255, 255, 255, 0);
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'desarrollo', N'barra');

/* Bandeja del sistema (systray) en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Bandeja del sistema (systray) en la barra', N'Iconos de la bandeja del sistema dentro de la barra, con zona de iconos fijados, popup para el resto y arrastrar y soltar.', N'widgets:
  systray:
    type: "yasb.systray.SystrayWidget"
    options:
      class_name: "systray"
      label_collapsed: "▼"
      label_expanded: "▶"
      label_position: "right"
      icon_size: 16
      pin_click_modifier: "alt"
      show_in_popup: true
      icons_per_row: 4
      popup:
        blur: true
        round_corners: true
        round_corners_type: "normal"
        border_color: None
        alignment: "center"
        direction: "down"
        offset_top: 6
        offset_left: 0', N'.systray {
    background: transparent;
    border: none;
    margin: 0;
}
.systray .unpinned-container {
    background: transparent;
}
.systray .pinned-container {
    background: transparent;
}
.systray .button {
    border-radius: 4px;
    padding: 2px;
    /* Transition compatible con QtCSS de yasb 2.0 */
    transition: background-color 200ms ease;
}

.systray .button:hover {
    background: rgba(255, 255, 255, 0.2);
}

/* Icon being dragged, we already apply some transparency to it so you don''t need to use it */
.systray .button.dragging {}

.systray .button.drag-over {
     background: rgba(255, 255, 255, 0.4);
     transition: background-color 200ms ease;
}

.systray .pinned-container.drop-target {
    background: rgba(255, 255, 255, 0.1);
    transition: background-color 200ms ease;
}
.systray .unpinned-visibility-btn {
    border-radius: 4px;
    height: 20px;
    width: 16px;
    border: none;
    outline: none;
    transition: background-color 200ms ease;
}

.systray .unpinned-visibility-btn:checked {
    background: transparent;
}

.systray .unpinned-visibility-btn:hover {
    background: rgba(255, 255, 255, 0.1);
}

/* Popup styles (when show_in_popup is true) */

/* The icon the drag is hovering over (drop target icon) */
.systray-popup .button.drag-over {
    background-color: rgba(255, 255, 255, 0.2);
    transition: background-color 200ms ease;
}

/* Icon being dragged, we already apply some transparency to it so you don''t need to use it */
.systray-popup .button.dragging {}

.systray .pinned-container.pinned-container.drop-target {
    background-color: rgba(255, 255, 255, 0.1);
}

/* POPUP PRINCIPAL - Con transición suave al aparecer */
.systray-popup {
    background-color: rgba(48, 48, 48, 0.6);
    padding: 4px;
    /* Transición suave al mostrarse - compatible con yasb 2.0 */
    transition: opacity 300ms ease;
}

/* Botones del popup con transiciones smooth */
.systray-popup .button {
    padding: 10px;
    margin: 0;
    border: 0;
    border-radius: 6px;
    transition: background-color 200ms ease;
}

.systray-popup .button:hover {
    background-color: rgba(255, 255, 255, 0.05);
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'barra');

/* Menú de apagado personalizado */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Menú de apagado personalizado', N'Botón de apagado que abre un menú a pantalla con opciones de apagar, reiniciar, cerrar sesión, hibernar y suspender, con textos y estilos propios y el tiempo encendido del equipo.', N'widgets:
  power_menu:
    type: "yasb.power_menu.PowerMenuWidget"
    options:
      label: "\uf011"
      uptime: True
      blur: False
      blur_background: True
      animation_duration: 200
      button_row: 5
      buttons:
        shutdown: ["\uf011", "Rage Quit"]
        restart: ["\uead2", "Oops, Reboot"]
        signout: ["\udb80\udf43", "Dip Out"]
        hibernate: ["\uf28e", "Bear Mode"]
        sleep: ["\u23fe", "Nap Time"]
        cancel: ["", "Nah, Im Good "]', N'/*POWER MENU WIDGET*/
/* Uptime text */
.uptime {
	font-size: 14px;
	margin-bottom: 10px;
	color: rgba(191, 202, 219, 0.726);
	font-weight: 600;
	font-family: "JetBrainsMono NFP";
}
.power-menu-widget .label {
	color: #e6900f;
	font-size: 16px;
}
.power-menu-popup .button {
	padding: 0;
	width: 160px;
	height: 240px;
	border-radius: 4px;
	background-color: rgba(41, 42, 58, 0.75);
	font-family: "JetBrainsMono NFP";
	color: white;
	border: 4px solid rgba(255, 255, 255, 0);
 
}
.power-menu-popup .button.hover {
	background-color: #363436;
	border: 4px solid #363436;
}
.power-menu-popup .button .label {
	margin-bottom: 8px;
	font-size: 16px;
	font-weight: 600;
	color: rgba(255, 255, 255, 0.6);
	font-family: "JetBrainsMono NFP";
}
.power-menu-popup .button .icon {
	font-size: 64px;
	padding-top: 54px;
	color: #e7b467;
}
.power-menu-popup .button.cancel {
    height: 20px !important; /* Much thinner than the 240px of other buttons */
    width: 100%; /* Full width to span across */
    padding-top: 10px;
    padding-bottom: 10px;
}

.power-menu-popup .button.cancel .icon {
    font-size: 24px !important; /* Smaller icon for the thinner button */
    padding-top: 0px !important; /* Remove the large top padding */
    color: rgba(231, 0, 0, 0.55);
}

.power-menu-popup .button.cancel .label {
    margin-bottom: 0px !important; /* Remove bottom margin */
    color: #6f6d6f;
    /* cambio */
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'barra');

/* Ventana activa en la barra */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Ventana activa en la barra', N'Muestra el título y el icono de la ventana en primer plano, con longitud máxima y puntos suspensivos.', N'widgets:
  active_window:
    type: "yasb.active_window.ActiveWindowWidget"
    options:
      label: "{win[title]}"
      label_alt: "[class_name=''{win[class_name]}'' exe=''{win[process][name]}'' hwnd={win[hwnd]}]"
      label_no_window: ""
      label_icon: true
      label_icon_size: 14
      max_length: 46
      max_length_ellipsis: "..."
      monitor_exclusive: true', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'barra');

/* Integración de YASB con GlazeWM: espacios de trabajo y dirección de tiling */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'YASB'), N'Integración de YASB con GlazeWM: espacios de trabajo y dirección de tiling', N'Widgets de la barra para GlazeWM: puntos que indican los espacios de trabajo vacíos, con ventanas y activo, y un botón que muestra y cambia la dirección de colocación de ventanas. Se conecta con GlazeWM por websocket.', N'widgets:
  glazewm_workspaces:
    type: "glazewm.workspaces.GlazewmWorkspacesWidget"
    options:
      # Offline behavior (matching komorebi''s label_offline and hide_if_offline)
      offline_label: "GlazeWM Offline"
      hide_if_offline: true
      
      # Workspace display labels (matching komorebi''s label_workspace_btn and label_workspace_active_btn)
      populated_label: "\udb85\udcfc"
      empty_label: "\udb85\udcfc"
      active_populated_label: "\udb85\udcfb"
      active_empty_label: "\udb85\udcfb"
      
      # Workspace management (matching komorebi''s hide_empty_workspaces)
      hide_empty_workspaces: false
      
      # Server connection
      glazewm_server_uri: "ws://localhost:6123"
      
      # Additional GlazeWM-specific options (keeping defaults)
      enable_scroll_switching: true
      reverse_scroll_direction: true
      container_padding:
        top: 0
        left: 0
        bottom: 0
        right: 0
  glazewm_tiling_direction:
    type: "glazewm.tiling_direction.GlazewmTilingDirectionWidget"
    options:
      horizontal_label: "\udb81\udce1"
      vertical_label: "\udb81\udce2"
      btn_shadow:
        enabled: true
        color: "black"
        radius: 3
        offset: [ 1, 1 ]', N'.glazewm-workspaces {
    margin: 0;
}

.glazewm-workspaces .ws-btn {
    font-size: 18px;
    background-color: transparent;
    border: none;
    padding: 0 2px 0 2px;
    margin: 0;
    color: #95a0ad;
}

.glazewm-workspaces .ws-btn.active_populated {
    color: #6f6d6f;
}

.glazewm-workspaces .ws-btn.active_empty {
    color: #174896;
}

.glazewm-workspaces .ws-btn.populated {
    color: #e7b467;
}

.glazewm-workspaces .ws-btn.empty {
    color: #95a0ad;
}

.glazewm-workspaces .ws-btn:hover,
.glazewm-workspaces .ws-btn.populated:hover,
.glazewm-workspaces .ws-btn.empty:hover {
    color: #e7b467;
}

.glazewm-tiling-direction {
    background-color: transparent;
    padding: 0;
    margin: 0;
}

.glazewm-tiling-direction .btn {
    font-size: 18px;
    width: 14px;
    padding: 0 4px 0 4px;
    color: #e7b467;
    border: none;
}

.glazewm-tiling-direction .btn:hover {
    background-color: #727272;
}');

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'espacios de trabajo', N'barra');

/* Aspecto de GlazeWM: huecos, bordes y transparencia */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Aspecto de GlazeWM: huecos, bordes y transparencia', N'Huecos entre ventanas, borde de color en la ventana enfocada y transparencia en las que no tienen el foco. También ajustes generales: ocultar ventanas al cambiar de espacio y salto del cursor entre monitores.', N'general:
  # Commands to run when the WM has started. This is useful for running a
  # script or launching another application.
  # Example: The below command launches Zebar.
  startup_commands: []

  # Commands to run just before the WM is shutdown.
  # Example: The below command kills Zebar.
  shutdown_commands: []

  # Commands to run after the WM config is reloaded.
  config_reload_commands: []

  # Whether to automatically focus windows underneath the cursor.
  focus_follows_cursor: false

  # Whether to switch back and forth between the previously focused
  # workspace when focusing the current workspace.
  toggle_workspace_on_refocus: false

  cursor_jump:
    # Whether to automatically move the cursor on the specified trigger.
    enabled: true

    # Trigger for cursor jump:
    # - ''monitor_focus'': Jump when focus changes between monitors.
    # - ''window_focus'': Jump when focus changes between windows.
    trigger: ''monitor_focus''

  # How windows should be hidden when switching workspaces.
  # - ''cloak'': Recommended. Hides windows with no animation.
  # - ''hide'': Legacy method (v3.5 and earlier) that has a brief animation,
  # but has stability issues with some apps.
  hide_method: ''cloak''

  # Affects which windows get shown in the native Windows taskbar. Has no
  # effect if `hide_method: ''hide''`.
  # - ''true'': Show all windows (regardless of workspace).
  # - ''false'': Only show windows from the currently shown workspaces.
  show_all_in_taskbar: false

gaps:
  # Whether to scale the gaps with the DPI of the monitor.
  scale_with_dpi: true

  # Gap between adjacent windows.
  inner_gap: ''10px''

  # Gap between windows and the screen edge.
  outer_gap:
    top: ''6px''
    right: ''6px''
    bottom: ''6px''
    left: ''6px''

window_effects:
  # Visual effects to apply to the focused window.
  focused_window:
    # Highlight the window with a colored border.
    # ** Exclusive to Windows 11 due to API limitations.
    border:
      enabled: true
      color: ''#8dbcff''

    # Remove the title bar from the window''s frame. Note that this can
    # cause rendering issues for some applications.
    hide_title_bar:
      enabled: false

    # Change the corner style of the window''s frame.
    # ** Exclusive to Windows 11 due to API limitations.
    corner_style:
      enabled: false
      # Allowed values: ''square'', ''rounded'', ''small_rounded''.
      style: ''square''

    # Change the transparency of the window.
    transparency:
      enabled: false
      # Can be something like ''95%'' or ''0.95'' for slightly transparent windows.
      # ''0'' or ''0%'' is fully transparent (and, by consequence, unfocusable).
      opacity: ''90%''

  # Visual effects to apply to non-focused windows.
  other_windows:
    border:
      enabled: true
      color: ''#a1a1a1''
    hide_title_bar:
      enabled: false
    corner_style:
      enabled: false
      style: ''square''
    transparency:
      enabled: true
      opacity: ''60%''', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'tema', N'ventanas');

/* Comportamiento de las ventanas nuevas en GlazeWM */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Comportamiento de las ventanas nuevas en GlazeWM', N'Define si las ventanas nuevas se abren en mosaico (tiling) o flotantes, y cómo se centran las flotantes o se maximizan las de pantalla completa.', N'window_behavior:
  # New windows are created in this state whenever possible.
  # Allowed values: ''tiling'', ''floating''.
  initial_state: ''tiling''

  # Sets the default options for when a new window is created. This also
  # changes the defaults for when the state change commands, like
  # `set-floating`, are used without any flags.
  state_defaults:
    floating:
      # Whether to center floating windows by default.
      centered: true

      # Whether to show floating windows as always on top.
      shown_on_top: false

    fullscreen:
      # Maximize the window if possible. If the window doesn''t have a
      # maximize button, then it''ll be fullscreen''ed normally instead.
      maximized: false

      # Whether to show fullscreen windows as always on top.
      shown_on_top: false', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'ventanas');

/* Nueve espacios de trabajo en GlazeWM */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Nueve espacios de trabajo en GlazeWM', N'Definición de nueve espacios de trabajo numerados del 1 al 9, para organizar las ventanas por escritorios.', N'workspaces:
  - name: ''1''
  - name: ''2''
  - name: ''3''
  - name: ''4''
  - name: ''5''
  - name: ''6''
  - name: ''7''
  - name: ''8''
  - name: ''9''', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'espacios de trabajo');

/* Reglas para ignorar ventanas en GlazeWM */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Reglas para ignorar ventanas en GlazeWM', N'Reglas para que GlazeWM no gestione ciertas ventanas: la barra Zebar, el picture-in-picture de los navegadores y ventanas auxiliares de PowerToys, Lively y Office.', N'window_rules:
  - commands: [''ignore'']
    match:
      # Ignores any Zebar windows.
      - window_process: { equals: ''zebar'' }

      # Ignores picture-in-picture windows for browsers.
      - window_title: { regex: ''[Pp]icture.in.[Pp]icture'' }
        window_class: { regex: ''Chrome_WidgetWin_1|MozillaDialogClass'' }

      # Ignore rules for various 3rd-party apps.
      - window_process: { equals: ''PowerToys'' }
        window_class: { regex: ''HwndWrapper\[PowerToys\.PowerAccent.*?\]'' }
      - window_process: { equals: ''PowerToys'' }
        window_title: { regex: ''.*? - Peek'' }
      - window_process: { equals: ''Lively'' }
        window_class: { regex: ''HwndWrapper'' }
      - window_process: { equals: ''EXCEL'' }
        window_class: { not_regex: ''XLMAIN'' }
      - window_process: { equals: ''WINWORD'' }
        window_class: { not_regex: ''OpusApp'' }
      - window_process: { equals: ''POWERPNT'' }
        window_class: { not_regex: ''PPTFrameClass'' }', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'ventanas');

/* Atajos para mover el foco y las ventanas con el teclado */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Atajos para mover el foco y las ventanas con el teclado', N'Atajos de teclado para cambiar el foco entre ventanas con alt+h/j/k/l o las flechas, y para mover la ventana enfocada con alt+shift. Navegación estilo Vim.', N'keybindings:
  # Shift focus in a given direction.
  - commands: [''focus --direction left'']
    bindings: [''alt+h'', ''alt+left'']
  - commands: [''focus --direction right'']
    bindings: [''alt+l'', ''alt+right'']
  - commands: [''focus --direction up'']
    bindings: [''alt+k'', ''alt+up'']
  - commands: [''focus --direction down'']
    bindings: [''alt+j'', ''alt+down'']

  # Move focused window in a given direction.
  - commands: [''move --direction left'']
    bindings: [''alt+shift+h'', ''alt+shift+left'']
  - commands: [''move --direction right'']
    bindings: [''alt+shift+l'', ''alt+shift+right'']
  - commands: [''move --direction up'']
    bindings: [''alt+shift+k'', ''alt+shift+up'']
  - commands: [''move --direction down'']
    bindings: [''alt+shift+j'', ''alt+shift+down'']', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'atajos', N'ventanas');

/* Atajos para redimensionar ventanas, con modo resize */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Atajos para redimensionar ventanas, con modo resize', N'Atajos para cambiar el ancho y el alto de la ventana enfocada (alt+u/i/o/p) y un modo de redimensión con alt+r que usa HJKL o las flechas.', N'binding_modes:
  # When enabled, the focused window can be resized via arrow keys or HJKL.
  - name: ''resize''
    keybindings:
      - commands: [''resize --width -2%'']
        bindings: [''h'', ''left'']
      - commands: [''resize --width +2%'']
        bindings: [''l'', ''right'']
      - commands: [''resize --height +2%'']
        bindings: [''k'', ''up'']
      - commands: [''resize --height -2%'']
        bindings: [''j'', ''down'']
      # Press enter/escape to return to default keybindings.
      - commands: [''wm-disable-binding-mode --name resize'']
        bindings: [''escape'', ''enter'']

keybindings:
  # Resize focused window by a percentage or pixel amount.
  - commands: [''resize --width -2%'']
    bindings: [''alt+u'']
  - commands: [''resize --width +2%'']
    bindings: [''alt+p'']
  - commands: [''resize --height +2%'']
    bindings: [''alt+o'']
  - commands: [''resize --height -2%'']
    bindings: [''alt+i'']

  # As an alternative to the resize keybindings above, resize mode enables
  # resizing via arrow keys or HJKL. The binding mode is defined above with
  # the name ''resize''.
  - commands: [''wm-enable-binding-mode --name resize'']
    bindings: [''alt+r'']', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'atajos', N'ventanas');

/* Atajos de control: flotante, pantalla completa, cerrar y terminal */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Atajos de control: flotante, pantalla completa, cerrar y terminal', N'Atajos para pausar GlazeWM, alternar ventana flotante, mosaico, pantalla completa o minimizada, cerrar ventanas, recargar la configuración, salir y abrir la terminal con alt+enter.', N'keybindings:
  # Disables window management and all other keybindings until alt+shift+p
  # is pressed again.
  - commands: [''wm-toggle-pause'']
    bindings: [''alt+shift+p'']

  # Change tiling direction. This determines where new tiling windows will
  # be inserted.
  - commands: [''toggle-tiling-direction'']
    bindings: [''alt+v'']

  # Change focus from tiling windows -> floating -> fullscreen.
  - commands: [''wm-cycle-focus'']
    bindings: [''alt+space'']

  # Change the focused window to be floating.
  - commands: [''toggle-floating --centered'']
    bindings: [''alt+shift+space'']

  # Change the focused window to be tiling.
  - commands: [''toggle-tiling'']
    bindings: [''alt+t'']

  # Change the focused window to be fullscreen.
  - commands: [''toggle-fullscreen'']
    bindings: [''alt+f'']

  # Minimize focused window.
  - commands: [''toggle-minimized'']
    bindings: [''alt+m'']

  # Close focused window.
  - commands: [''close'']
    bindings: [''alt+shift+q'']

  # Kill GlazeWM process safely.
  - commands: [''wm-exit'']
    bindings: [''alt+shift+e'']

  # Re-evaluate configuration file.
  - commands: [''wm-reload-config'']
    bindings: [''alt+shift+r'']

  # Redraw all windows.
  - commands: [''wm-redraw'']
    bindings: [''alt+shift+w'']

  # Launch CMD terminal. Alternatively, use `shell-exec wt` or
  # `shell-exec %ProgramFiles%/Git/git-bash.exe` to start Windows
  # Terminal and Git Bash respectively.
  - commands: [''shell-exec wt'']
    bindings: [''alt+enter'']', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'atajos', N'ventanas');

/* Atajos para cambiar de espacio de trabajo */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Atajos para cambiar de espacio de trabajo', N'Atajos para ir a un espacio de trabajo concreto con alt+1 a alt+9, al siguiente o anterior con alt+s/a y al último usado con alt+d.', N'keybindings:
  # Focus the next/previous active workspace defined in `workspaces` config.
  - commands: [''focus --next-active-workspace'']
    bindings: [''alt+s'']
  - commands: [''focus --prev-active-workspace'']
    bindings: [''alt+a'']

  # Focus the workspace that last had focus.
  - commands: [''focus --recent-workspace'']
    bindings: [''alt+d'']

  # Change focus to a workspace defined in `workspaces` config.
  - commands: [''focus --workspace 1'']
    bindings: [''alt+1'']
  - commands: [''focus --workspace 2'']
    bindings: [''alt+2'']
  - commands: [''focus --workspace 3'']
    bindings: [''alt+3'']
  - commands: [''focus --workspace 4'']
    bindings: [''alt+4'']
  - commands: [''focus --workspace 5'']
    bindings: [''alt+5'']
  - commands: [''focus --workspace 6'']
    bindings: [''alt+6'']
  - commands: [''focus --workspace 7'']
    bindings: [''alt+7'']
  - commands: [''focus --workspace 8'']
    bindings: [''alt+8'']
  - commands: [''focus --workspace 9'']
    bindings: [''alt+9'']', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'atajos', N'espacios de trabajo');

/* Atajos para mover ventanas entre espacios de trabajo y monitores */
INSERT  INTO dbo.configuracion (
  herramienta_id,
  titulo,
  descripcion,
  codigo_yaml,
  codigo_css
)
VALUES                         ((SELECT herramienta_id
                                 FROM   dbo.herramienta
                                 WHERE  nombre = N'GlazeWM'), N'Atajos para mover ventanas entre espacios de trabajo y monitores', N'Atajos para enviar la ventana enfocada a un espacio de trabajo con alt+shift+1 a 9 y para mover espacios de trabajo entre monitores.', N'keybindings:
  # Move the focused window''s parent workspace to a monitor in a given
  # direction.
  - commands: [''move-workspace --direction left'']
    bindings: [''alt+shift+a'']
  - commands: [''move-workspace --direction right'']
    bindings: [''alt+shift+f'']
  - commands: [''move-workspace --direction up'']
    bindings: [''alt+shift+d'']
  - commands: [''move-workspace --direction down'']
    bindings: [''alt+shift+s'']

  # Move focused window to a workspace defined in `workspaces` config.
  - commands: [''move --workspace 1'', ''focus --workspace 1'']
    bindings: [''alt+shift+1'']
  - commands: [''move --workspace 2'', ''focus --workspace 2'']
    bindings: [''alt+shift+2'']
  - commands: [''move --workspace 3'', ''focus --workspace 3'']
    bindings: [''alt+shift+3'']
  - commands: [''move --workspace 4'', ''focus --workspace 4'']
    bindings: [''alt+shift+4'']
  - commands: [''move --workspace 5'', ''focus --workspace 5'']
    bindings: [''alt+shift+5'']
  - commands: [''move --workspace 6'', ''focus --workspace 6'']
    bindings: [''alt+shift+6'']
  - commands: [''move --workspace 7'', ''focus --workspace 7'']
    bindings: [''alt+shift+7'']
  - commands: [''move --workspace 8'', ''focus --workspace 8'']
    bindings: [''alt+shift+8'']
  - commands: [''move --workspace 9'', ''focus --workspace 9'']
    bindings: [''alt+shift+9'']', NULL);

SET @id = SCOPE_IDENTITY();

INSERT INTO dbo.configuracion_categoria (
  configuracion_id,
  categoria_id
)
SELECT @id,
       categoria_id
FROM   dbo.categoria
WHERE  nombre IN (N'atajos', N'espacios de trabajo');

/* Ejemplos de peticiones que se muestran al iniciar la app */
INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Dame una barra con el clima de mi ciudad y un gestor de notificaciones',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Widget de clima en la barra con tarjeta de previsión';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Quiero un reloj con calendario en la barra',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Reloj en la barra con calendario desplegable';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Quiero ver la música que suena en la barra',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Reproductor multimedia en la barra';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Un temporizador pomodoro para estudiar',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Temporizador Pomodoro en la barra';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Ver el uso de CPU y memoria en la barra',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Monitor de CPU y memoria RAM en la barra';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Necesito atajos de teclado para moverme entre ventanas',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Atajos para mover el foco y las ventanas con el teclado';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Cómo cambio de espacio de trabajo con el teclado',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Atajos para cambiar de espacio de trabajo';

INSERT INTO dbo.peticion_ejemplo (
  texto,
  configuracion_id
)
SELECT N'Quiero ventanas con bordes de color y huecos entre ellas',
       configuracion_id
FROM   dbo.configuracion
WHERE  titulo = N'Aspecto de GlazeWM: huecos, bordes y transparencia';

COMMIT TRANSACTION;


GO
/* Comprobaciones */
SELECT   h.nombre AS herramienta,
         COUNT(*) AS configuraciones
FROM     dbo.configuracion AS c
         INNER JOIN
         dbo.herramienta AS h
         ON h.herramienta_id = c.herramienta_id
GROUP BY h.nombre;

SELECT (SELECT COUNT(*)
        FROM   dbo.configuracion) AS configuraciones,
       (SELECT COUNT(*)
        FROM   dbo.categoria) AS categorias,
       (SELECT COUNT(*)
        FROM   dbo.configuracion_categoria) AS relaciones,
       (SELECT COUNT(*)
        FROM   dbo.peticion_ejemplo) AS peticiones;

SELECT   configuracion_id,
         titulo,
         LEN(codigo_yaml) AS len_yaml,
         LEN(codigo_css) AS len_css
FROM     dbo.configuracion
ORDER BY configuracion_id;