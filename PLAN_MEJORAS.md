# Plan de mejoras ZarpaFit

> Hoja de ruta priorizada de UI/UX, funcionalidades nuevas e integraciones técnicas.
> Basado en la auditoría de abril 2026.
> Formato: cada bloque es ejecutable de forma independiente.

---

## 🎯 Objetivo estratégico

Convertir ZarpaFit en la app de gym **con mejor identidad de marca y mejor experiencia de sesión activa** del mercado hispano. Diferenciación: branding "zarpa/instinto" + IA opcional + estética premium.

KPIs a mover:
- **Activación Day-1** (% de usuarios que completan 1 sesión tras login): objetivo +40%
- **Retención Día-7**: objetivo 35%
- **Sesiones por usuario activo / semana**: objetivo 2.5
- **Conversión a Pro** (cuando se monetice): objetivo 4–6%

---

## FASE 1 — Quick wins (Sprint 1, 3–5 días)

Cambios de alto impacto que se pueden hacer ya sin nuevas dependencias mayores.

### 1.1 · Onboarding post-login (3 slides)
- **Qué**: tras Google Sign-In, antes del Home, mostrar 3 pantallas:
  1. Objetivo (Fuerza / Hipertrofia / Perder grasa / Mantenimiento / Cardio)
  2. Nivel (Inicio / Intermedio / Avanzado)
  3. Días/semana disponibles
- **Resultado**: marca un `RoutineModel` recomendado del catálogo y lo fija como "Programa del día".
- **Archivos**: nuevo `lib/screens/onboarding_screen.dart`; gancho en `root_screen.dart` para detectar primer login (campo `onboardingCompleted` en `users/{uid}`).
- **Esfuerzo**: 1 día.
- **Impacto**: +30–50% activación.

### 1.2 · Dark mode completo
- **Qué**: añadir `zarpaFitThemeDark()` en [zarpafit_theme.dart](lib/theme/zarpafit_theme.dart). Toggle en Settings + auto según sistema.
- **Persistencia**: ampliar `SettingsService` con `themeMode` (light/dark/system).
- **Esfuerzo**: medio día.
- **Impacto**: tabla stakes 2026.

### 1.3 · Nueva paleta primary
- **Qué**: cambiar `ZarpaColors.primary` de `#0000FF` puro a `#1B4EFF` (azul eléctrico con más profundidad). Crear gradiente de marca `[#1B4EFF, #6E3CFF]` para CTAs hero.
- **Archivos**: [zarpafit_theme.dart:10](lib/theme/zarpafit_theme.dart#L10).
- **Esfuerzo**: 30 min.
- **Impacto**: percepción premium inmediata.

### 1.4 · Empty states con CTA
- **Qué**: en Home, Rutinas, Stats — cuando no hay datos mostrar ilustración + CTA accionable, no solo texto.
- Ejemplos:
  - Home sin sesiones: *"Tu zarpa está esperando → Empieza con un programa de 20 min"* + botón
  - Rutinas vacío: *"Crea tu primera rutina o explora 40+ programas"*
- **Esfuerzo**: medio día.

### 1.5 · CTA flotante "Empezar ahora" en Home
- **Qué**: cuando hay rutina recomendada o última usada, FAB extendido encima del bottom nav que la lanza directamente.
- **Esfuerzo**: 1 hora.
- **Impacto**: -1 tap = +20% sesiones iniciadas.

### 1.6 · Apple Sign-In
- **Qué**: requisito App Store si tienes Google Sign-In. Añadir `sign_in_with_apple` package.
- **Archivos**: [auth_service.dart](lib/services/auth_service.dart), [login_screen.dart](lib/screens/login_screen.dart).
- **Esfuerzo**: 2–3 horas (incluye configuración Apple Developer).

---

## FASE 2 — Diferenciación 2026 (Sprint 2, 1–2 semanas)

Funcionalidades que separan la app del montón.

### 2.1 · Live Activities iOS (Dynamic Island)
- **Qué**: cuando se está en descanso entre series, mostrar timer en Dynamic Island del iPhone 14+.
- **Integración**: `live_activities` package (Flutter ↔ ActivityKit nativo). Requiere extensión Swift en `ios/`.
- **Archivos**: nuevo `ios/LiveActivityExtension/`, ganchos en [workout_screen.dart](lib/screens/workout_screen.dart) y [timer_service.dart](lib/services/timer_service.dart).
- **Esfuerzo**: 2–3 días.
- **Impacto**: factor "wow" + diferenciación clara vs Hevy/Strong.

### 2.2 · AI Coach (chat)
- **Qué**: pestaña o burbuja flotante. Chat con Claude Haiku 4.5 que conoce el historial de sesiones y sugiere:
  - Qué entrenar hoy
  - Cuándo subir peso
  - Por qué está estancado
- **Integración**: Anthropic SDK desde Flutter via Cloud Function (no exponer API key cliente). Cache prompts del sistema (descripción del usuario + últimas 10 sesiones) para minimizar coste.
- **Coste estimado**: ~$0.0005 por mensaje con Haiku 4.5 + caché. 100 usuarios x 5 msgs/día = $7.50/mes.
- **Archivos**: nueva Cloud Function `aiCoach`, `lib/services/ai_coach_service.dart`, `lib/screens/coach_screen.dart`.
- **Esfuerzo**: 4–5 días (incluye prompt engineering).

### 2.3 · Heatmap "Tu semana"
- **Qué**: vista en Stats o Profile tipo GitHub contributions, con cuadritos de los últimos 12 meses coloreados según volumen entrenado.
- **Librería**: ya tienes `fl_chart`; o usar `flutter_heatmap_calendar`.
- **Esfuerzo**: 1 día.

### 2.4 · Bottom nav con acción central
- **Qué**: rediseño del NavigationBar — 5 slots con el central elevado (icono 🔥 grande) que abre bottom sheet "Empezar entreno":
  - Programa recomendado
  - Última rutina usada
  - Crear rutina vacía
- **Archivos**: [home_screen.dart:70-95](lib/screens/home_screen.dart#L70-L95), [zarpafit_theme.dart](lib/theme/zarpafit_theme.dart).
- **Esfuerzo**: medio día.

### 2.5 · Compartir sesión post-workout
- **Qué**: en `workout_completion_screen.dart`, botón "Compartir" que genera tarjeta 9:16 (formato story) con:
  - Foto/logo + tagline ZarpaFit
  - Nombre de la sesión, duración, sets, peso total
  - Racha actual
- **Librerías**: `screenshot` + `share_plus`.
- **Esfuerzo**: 1 día.
- **Impacto**: crecimiento orgánico viral.

### 2.6 · Tipografía premium
- **Qué**: añadir Geist o Bricolage Grotesque como display font para títulos. Inter sigue para body.
- **Archivos**: `pubspec.yaml` (assets fonts), [zarpafit_theme.dart](lib/theme/zarpafit_theme.dart).
- **Esfuerzo**: 1 hora.

### 2.7 · Háptica fuerte y sonidos premium
- **Qué**: usar `HapticFeedback.heavyImpact()` al completar serie, `HapticFeedback.selectionClick()` en cambios de set. Reemplazar el beep actual por sample propio (whistle short, kettlebell ding).
- **Archivos**: [workout_screen.dart](lib/screens/workout_screen.dart), [beep_service.dart](lib/services/beep_service.dart).
- **Esfuerzo**: 2–3 horas.

---

## FASE 3 — Monetización y crecimiento (Sprint 3+, planificación v1.1)

### 3.1 · Modelo Free vs Pro
| Feature | Free | Pro |
|---------|------|-----|
| Crear rutinas | ✅ Ilimitado | ✅ Ilimitado |
| Programas catálogo | 8 básicos | 40+ todos |
| AI Coach | ❌ | ✅ |
| Live Activities | ✅ | ✅ |
| Historial | 30 días | Ilimitado |
| Wrapped anual | ❌ | ✅ |
| Análisis avanzado (PRs, volumen, gráficas) | Básico | Completo |

### 3.2 · Integración con RevenueCat
- **Por qué**: paywall configurable sin redeploy, A/B testing, gestión de suscripciones cross-platform.
- **Pricing inicial**: €4,99/mes ó €34,99/año (–42% anual). Trial 7 días.
- **Esfuerzo**: 2–3 días.

### 3.3 · Wrapped anual
- **Qué**: en diciembre, modal/pantalla animada con stats del año:
  - Sesiones totales
  - Kg totales movidos
  - Racha más larga
  - Programa favorito
  - Comparativa "vs el resto de zarpas" (% percentil)
- **Esfuerzo**: 3 días.
- **Impacto**: viralidad estacional + reactivación.

### 3.4 · Social ligero
- **Qué**: añadir amigos por código de 6 dígitos, ver mutuamente racha y volumen semanal. Sin feed.
- **Por qué**: estudio Strava → +40% retención con un amigo conectado.
- **Esfuerzo**: 1 semana.

### 3.5 · Notificaciones inteligentes
- **Qué**: usar Firebase Cloud Messaging para:
  - Recordatorio si llevas 2 días sin entrenar
  - "Toca pierna hoy" según historial
  - Felicitación al batir PR
- **Esfuerzo**: 2 días.

---

## 🔌 Integraciones técnicas resumen

| Integración | Para qué | Esfuerzo | Coste |
|-------------|----------|----------|-------|
| `sign_in_with_apple` | Login Apple (App Store req.) | 3h | Gratis |
| `live_activities` + extensión Swift | Dynamic Island | 2–3 días | Gratis |
| Cloud Functions + Anthropic SDK | AI Coach | 4–5 días | ~$10/mes/100 usuarios |
| `revenue_cat` (`purchases_flutter`) | Paywall y suscripciones | 2–3 días | $0 hasta $2.5k MRR, luego 1% |
| Firebase Cloud Messaging | Notificaciones push | 2 días | Gratis |
| `screenshot` + `share_plus` | Compartir tarjeta sesión | 1 día | Gratis |
| `flutter_heatmap_calendar` | Heatmap actividad | 4h | Gratis |
| Sentry o Firebase Crashlytics | Crash reporting (recomendado YA) | 2h | Gratis hasta 10k events |
| PostHog o Firebase Analytics | Producto analytics | 4h | Gratis tier generoso |

---

## 📅 Roadmap sugerido

```
Semana 1   Fase 1 (quick wins) → release v1.1
Semana 2-3 Fase 2 (Live Activities + AI Coach + heatmap + compartir)
Semana 4   Beta cerrada con 20–50 usuarios
Semana 5   Fase 3 inicio (RevenueCat + Free/Pro)
Semana 6-7 Wrapped + social + notificaciones
Semana 8   Lanzamiento Pro v2.0
```

---

## ⚠️ Deuda técnica a resolver en paralelo

Detectada durante la auditoría — no bloquea features pero conviene atajar:

1. **`withOpacity` deprecado** (28 usos en `programs_section.dart`) → migrar a `.withValues(alpha: ...)`.
2. **`programsCatalog` + Firestore divergentes**: hoy se fusionan en runtime (parche aplicado), pero falta un job que sincronice catálogo local → Firestore al deploy.
3. **Sin tests** (carpeta `test/` vacía). Mínimo: tests de modelos (`ProgramModel.fromMap`, `ProgramExercise.summary`) + tests de servicios críticos (`TimerService`, `AuthService`).
4. **Crash reporting ausente.** Imprescindible añadir Crashlytics antes de cualquier launch público.
5. **Sin analítica de producto.** No sabes qué pantallas se usan. PostHog o Firebase Analytics como prerequisito para iterar con datos.

---

## 🚦 Criterios de éxito por fase

- **Fase 1 cerrada cuando**: dark mode funciona, hay onboarding, FAB en Home, Apple Sign-In activo, 0 empty states sin CTA.
- **Fase 2 cerrada cuando**: Live Activity visible en iPhone 14+, AI Coach responde con historial, hay tarjeta compartible post-sesión.
- **Fase 3 cerrada cuando**: paywall live, primer usuario Pro, push notifications enviadas.

---

*Última actualización: 2026-04-18*
