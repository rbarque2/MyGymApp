# MyGymApp

App para gestionar entrenamientos de gimnasio. Organiza tus ejercicios, crea rutinas personalizadas, registra tus sesiones y visualiza tu progreso.

## Funcionalidades

- **Catálogo de ejercicios** — Crea y filtra ejercicios por grupo muscular (pecho, espalda, piernas, etc.)
- **Rutinas personalizadas** — Combina ejercicios con series, repeticiones, peso y tiempo de descanso
- **Registro de entrenamientos** — Sigue tu sesión en tiempo real, marca series completadas y ajusta pesos/reps
- **Temporizador de descanso** — Timer integrado entre series con duración configurable
- **Historial** — Consulta todas tus sesiones pasadas con detalles de volumen y duración
- **Estadísticas y progreso** — Gráficas de evolución de volumen y duración por sesión
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

### 2026-04-19

- **Timer de descanso en segundo plano**: el temporizador ahora usa un timestamp de fin como fuente de verdad; al cambiar de app y volver, el tiempo restante es el correcto.
- **Saltar descanso ya no vuelve al primer ejercicio**: el PageView se mantiene montado y la vista de descanso se superpone; además, al completar un ejercicio se sincroniza la página automáticamente.
- **Controles ±10s en descanso**: botones para sumar o restar 10 segundos al timer de descanso (pulsables varias veces para saltar 20s, 30s, etc.).
- **Cerrar rutina con opción de descartar**: el diálogo de salida ofrece tres opciones — Cancelar, Descartar (elimina la sesión del histórico) y Guardar y salir.
- **Lista de series estilo Hevy**: debajo de los pickers aparece una lista vertical apilada con cada serie (nº de serie, kg × reps, check cuadrado). Se puede tocar una fila para editarla o el check para marcarla como completada.
- **Vista del ejercicio scrollable**: la ficha (foto, nombre, pickers, lista de series) ahora scrollea; el botón "SERIE COMPLETADA" queda fijo abajo.
