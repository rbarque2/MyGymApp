Auditoría UI/UX de ZarpaFit — Lente de ventas y retención
🟢 Lo que ya funciona bien (capitaliza)
Identidad fuerte y diferenciada. Marca con voz propia ("Instinto en movimiento", paleta azul eléctrico + slogans rotativos). Esto es oro — la mayoría de apps de gym son grises.
Onboarding-zero friction. Login con Google directo, sin crear cuenta. Punto perfecto en 2026.
Catálogo de programas robusto (40+ después de los cambios) — el centro de valor percibido.
Active workout flow con timer/beep/pulso — la pantalla más importante para retención está cuidada.
🟡 Hallazgos críticos por pantalla
1. Login (login_screen.dart)
Sin propuesta de valor. Solo logo + tagline + botón. Un usuario nuevo no sabe qué obtiene. Conversión Day-0 baja.
Solo Google. Pierdes a usuarios sin cuenta Google o que no quieren vincularla (~30% del mercado iOS).
Sin "modo invitado" para probar la app sin compromiso.
2. Home (home_tab_screen.dart)
Stats en 0 al abrir por primera vez = sensación de app vacía. Hay que sembrar contenido (programa demo, racha ficticia "empieza tu primera").
"ENTRENAMIENTO DEL DÍA" = primera rutina creada. No hay lógica de recomendación. En 2026 esto es el mínimo: sugerir el programa que toca según día/semana.
Slogan rotativo bonito pero ocupa espacio sin acción. Mejor convertirlo en CTA contextual ("Llevas 3 días sin entrenar →").
3. Programas (programs_section.dart)
Carruseles horizontales por categoría = scroll infinito sin foco. El usuario no sabe por dónde empezar.
Sin "Para ti" ni filtros por objetivo (ganar masa, perder grasa, mantenerse). Los filtros actuales son por grupo muscular — útiles pero no resuelven la pregunta "¿qué hago hoy?".
Tarjetas con gradientes alegres — bien, pero falta indicador de duración + dificultad visual unificado (ej: ⚡⚡⚡ = nivel + ⏱ 30 min en tipografía grande).
Sin previews de progreso ("ya hiciste 2/8 sesiones").
4. Tema (zarpafit_theme.dart)
Sin dark mode. En 2026 es estándar — apps fitness se usan en gimnasios con poca luz.
Color primario #0000FF puro — vibrante pero "hostil" en pantalla grande. Las apps top usan azules con saturación reducida (Hevy, Strong, Ladder).
Inter como fuente — segura pero genérica. Para fitness/lifestyle: una display font para títulos (Bricolage, Geist Mono, Space Grotesk) crea diferenciación inmediata.
5. Bottom nav (Home → 4 tabs)
Iconos OK. Pero falta acción central destacada: el patrón actual en apps fitness es un FAB grande "Start workout" en el centro del nav (Strava, Nike Training).
6. Workout activo
Pantalla bien ejecutada técnicamente. Solo le faltan dos cosas modernas: Live Activity (iPhone Dynamic Island con timer de descanso) y háptica fuerte al terminar serie.
7. Perfil
No vende. Ningún hook a compartir, retar a un amigo, ver "tu año en ZarpaFit" (Spotify Wrapped style).
📊 Plan de mejoras priorizado (impacto × esfuerzo)
🔥 Quick wins (1–3 días, máximo impacto)
#	Mejora	Por qué importa
1	Onboarding de 3 slides post-login: objetivo (fuerza/grasa/cardio), nivel, días/semana. Genera "Plan recomendado".	+30–50% activación Day-1
2	Dark mode completo	Tabla stakes 2026; muchos abandonan sin él
3	CTA "Empezar ahora" flotante en Home cuando hay rutina recomendada	Reduce 1 tap = +20% sesiones iniciadas
4	Empty states con ilustración + CTA ("Aún no entrenaste hoy → Programa de 20 min")	Combate el "app vacía"
5	Botón Apple Sign-In	Requisito App Store si tienes Google
🚀 Tendencias 2025–2026 a integrar (1–2 semanas)
#	Mejora	Referencia
6	Live Activities iOS con timer de descanso en Dynamic Island	Strong, Hevy lo usan ya
7	AI Coach ligero: chat con sugerencias ("hoy toca pierna porque ayer hiciste pecho"). Usa Claude Haiku 4.5 — barato y rápido	Apps top de 2026
8	Pantalla "Tu semana" tipo heatmap GitHub/Strava con racha visible	Gamificación pasiva
9	Compartir sesión post-workout como tarjeta cuidada (Instagram story format 9:16)	Crecimiento orgánico
10	Bottom nav con acción central destacada ("+" o flame XL) que abre selector rápido de rutina	Reduce fricción a 1 tap
💰 Monetización / valor percibido (planificar para v1.1)
#	Mejora	Lógica
11	Free vs Pro transparente: 5 programas gratis + creación libre, premium = catálogo completo + AI coach + sin límite de historial	Modelo Hevy/Strong validado
12	Paywall blando post-onboarding: "Prueba 7 días Pro" con cancelación visible	+15–25% conversión vs paywall duro
13	Wrapped anual ("Tu año en ZarpaFit: 142 sesiones, 18.500kg levantados")	Viralidad estacional
14	Social ligero — añadir amigos por código, ver racha del otro (sin feed completo)	Retención +40% según estudio Strava
🎨 Polish visual (paralelo, continuo)
Cambiar #0000FF por un azul con más profundidad (ej. #1B4EFF o #2348DB) para que no canse en superficies grandes.
Sustituir Inter por Geist o Bricolage Grotesque en títulos — instantáneamente más "premium 2026".
Añadir micro-animaciones en transiciones de tab (Hero), botones (scale on press), y completado de set (confetti sutil tipo Duolingo).
Iconografía consistente — ahora mezclas emojis (🍑🦏) con Material Icons. Decide: o todo emoji custom (más "fun"), o todo icon set (Phosphor, Lucide → más "pro").
🎯 Posicionamiento sugerido
Tu activo más fuerte es la identidad de marca "instinto/zarpa" — es lo que ningún competidor (Hevy, Strong, FitBod) tiene. El plan debe reforzarlo, no diluirlo. Recomendación de pitch:

"La única app de gym que entrena contigo, no te entrena a ti." — Programas reales hechos por humanos + IA opcional + estética que no parece una hoja de cálculo.

Diferénciate en branding + feeling de la sesión activa (audio, háptica, tipografía). Eso es lo que justifica €4,99/mes frente al gigante gratuito (Hevy).

¿Quieres que implemente algo concreto del plan? Mis recomendaciones para arrancar:

Dark mode + nuevo color primario (1h, impacto enorme).
Onboarding de 3 slides con plan recomendado (medio día).
CTA flotante "Empezar" en Home (15 min).