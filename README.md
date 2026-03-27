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
