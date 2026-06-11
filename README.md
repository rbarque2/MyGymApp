# MyGymApp

App para gestionar entrenamientos de gimnasio. Organiza tus ejercicios, crea rutinas personalizadas, registra tus sesiones y visualiza tu progreso.

## Funcionalidades

- **Catálogo de ejercicios** — Crea y filtra ejercicios por grupo muscular (pecho, espalda, piernas, etc.)
- **Rutinas personalizadas** — Combina ejercicios con series, repeticiones, peso y tiempo de descanso
- **Registro de entrenamientos** — Sigue tu sesión en tiempo real, marca series completadas y ajusta pesos/reps
- **Temporizador de descanso** — Timer integrado entre series con duración configurable
- **Historial** — Consulta todas tus sesiones pasadas con detalles de volumen y duración
- **Estadísticas y progreso** — Gráficas de evolución de volumen y duración por sesión
- **Dark mode** — Tema claro y oscuro con selector (sistema/claro/oscuro)
- **Notificaciones** — Aviso de fin de descanso en segundo plano y recordatorio diario de entreno
- **Autenticación con Google** — Login seguro y sincronización entre dispositivos

## Tech Stack

- **Flutter** (iOS, Android, Web)
- **Firebase Auth** (Google Sign-In)
- **Cloud Firestore** (base de datos en tiempo real)
- **fl_chart** (gráficas de progreso)

## Configuración

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Ejecuta `flutterfire configure` para vincular Firebase
3. `flutter pub get`
4. `flutter run`

## Changelog

> Registro de actualizaciones. Cada día con cambios se publica como una versión nueva.

### 2026-06-10

- **Logo rebrandeado a naranja**: `assets/zarpafit_logo.png` y `assets/zarpafit-icon.png` pasan del azul antiguo al naranja de marca `#F97316` (generados con `tool/rebrand_logo.py`), además de reducir su peso de 6,1 MB a 1,9 MB.
- **Dark mode completo**: nueva paleta oscura (gray-900/800 con el naranja/verde de marca) y selector Sistema / Claro / Oscuro en Configuración → Apariencia, con persistencia y respuesta en vivo al tema del sistema. Internamente `ZarpaColors` pasó de constantes a getters sobre una paleta intercambiable (`tool/deconst.py` limpió los ~106 `const` huérfanos).
- **Tipografía de marca real**: Barlow (cuerpo) y Barlow Condensed (titulares, AppBar, hero) bundleadas en `assets/fonts` y declaradas en pubspec. Antes el tema pedía 'Inter' sin incluirla y toda la app caía en Roboto.
- **Hero con foto en Home**: la tarjeta "Entrenamiento del día" ahora muestra foto de portada (foto propia de la rutina → foto del primer ejercicio → set curado de Unsplash por hash del nombre) con velo oscuro para legibilidad y fallback al gradiente naranja si no hay red.
- **Notificaciones locales**: aviso de "Descanso terminado" cuando la app está en segundo plano con el timer corriendo (se programa al pasar a background y se cancela al volver), y recordatorio diario de entrenamiento configurable en Configuración → Recordatorio. Permisos Android 13+/iOS gestionados; sin soporte web (no-op).
- **Campo `photoUrl` en rutinas**: las rutinas propias aceptan foto de portada (Firestore, opcional y retrocompatible).
- **Empty state en Home**: cuando el usuario no tiene rutinas, se muestra una tarjeta con ícono, texto motivacional y botón "Crear mi primera rutina" que lleva directamente a la pestaña Entrena.
- **Cálculo de racha corregido**: Home ahora carga hasta 30 sesiones para calcular la racha de días correctamente (antes solo cargaba 3 y podía mostrar racha falsa).
- **Fechas legibles en sesiones recientes**: formato cambiado de `5/6/2026` a `5 jun` usando helper interno (sin dependencia de intl).
- **Filas de sesión reciente son tappables**: las filas con chevron derecho ahora responden al toque con ripple de InkWell. El chevron ya no miente.
- **Peek en carrusel de rutinas rápidas**: ShaderMask con degradado en el borde derecho del carrusel horizontal indica que hay más cards fuera de pantalla.

### 2026-04-19

- **Timer de descanso en segundo plano**: el temporizador ahora usa un timestamp de fin como fuente de verdad; al cambiar de app y volver, el tiempo restante es el correcto.
- **Saltar descanso ya no vuelve al primer ejercicio**: el PageView se mantiene montado y la vista de descanso se superpone; además, al completar un ejercicio se sincroniza la página automáticamente.
- **Controles ±10s en descanso**: botones para sumar o restar 10 segundos al timer de descanso (pulsables varias veces para saltar 20s, 30s, etc.).
- **Cerrar rutina con opción de descartar**: el diálogo de salida ofrece tres opciones — Cancelar, Descartar (elimina la sesión del histórico) y Guardar y salir.
- **Lista de series estilo Hevy**: debajo de los pickers aparece una lista vertical apilada con cada serie (nº de serie, kg × reps, check cuadrado). Se puede tocar una fila para editarla o el check para marcarla como completada.
- **Vista del ejercicio scrollable**: la ficha (foto, nombre, pickers, lista de series) ahora scrollea; el botón "SERIE COMPLETADA" queda fijo abajo.
- **Más GIFs de ejercicios (79% de cobertura)**: `_gifLibrary` en `ProgramExercise` ahora incluye ~60 mapeos nuevos desde liftmanual.com (press militar, press francés, pushdown, hiperextensión, superman, dead bug, bird dog, farmer carry, pallof, dragon flag, yoga poses, estiramientos básicos, etc.). Cobertura sube de 55% → 79% (56 ejercicios sin gif, casi todos drills de movilidad/calentamiento genéricos).
- **Portadas de programas (Unsplash)**: los 47 programas que mostraban degradado ahora tienen foto de portada. Script en `tool/fetch_program_covers.py` consulta la Unsplash Search API una vez y bakea las URLs en `programsCatalog`. Keys en `.env` gitignoreado (`.env.example` documenta el formato).
