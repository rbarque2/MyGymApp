# ZarpaFit — Sistema híbrido de diseño (jun 2026)

Tres conceptos, un sistema. Cada uno gobierna el contexto donde es más fuerte,
unidos por un ADN común. Decidido con el usuario el 2026-06-12.

## Mapping por contexto

| Contexto | Concepto | Esencia |
|---|---|---|
| Home | **Instinto** (póster editorial) | Foto full-bleed + palabra de marca gigante + CTA subrayado |
| Sesión activa + descanso | **Telemetría** (HUD) | Datos de cabina: anillo de progreso, mono, retícula 1px |
| Stats / racha / completion | **Asfalto** (brutalismo atlético) | Números protagonistas, bordes duros, sin tarjetas |
| Utilitarias (ajustes, editor, listas) | Material suavizado actual | No pelear con la función |

## ADN compartido (tokens)

- **Display**: Barlow Condensed w700, tamaños masivos (38–84+), `height` 0.85–1.0,
  tracking negativo en palabras-póster. MAYÚSCULAS en titulares de sistema.
- **Micro**: IBM Plex Mono (`ZarpaFonts.mono`) 10–12px, `letterSpacing` 1–2.5,
  para fechas, metadatos, telemetría y section labels.
- **Cuerpo**: Barlow.
- **Naranja #F97316 solo como golpe**: número clave, palabra-póster, CTA,
  tag invertido (fondo naranja + texto negro). Nunca relleno decorativo.
- **Retícula 1px**: divisores `ZarpaColors.border` en vez de cards con sombra.
- **Esquinas duras**: 0–2px en componentes del sistema (mini-pósters 2px).
- **Tinta fija** (`ZarpaInk`): negro #0A0A0A, velos 45%/10%/86%, `paper`,
  `steel` — NO cambian con el modo de tema; se usan sobre fotografía.
- **Section labels**: barra naranja 18×2 + label mono mayúsculas.

## Reglas de fotografía

- Portadas: `routineCoverUrl()` — foto propia → foto del primer ejercicio →
  set curado por hash (31-bit, seguro en web).
- Toda foto lleva velo de 3 paradas (45% → 10% → 86%) para legibilidad
  WCAG del texto superpuesto.
- El póster es **siempre oscuro** aunque el tema sea claro (status bar light).

## Estado

- ✅ Fase 1 (2026-06-12): Home póster Instinto + franja stats Asfalto +
  filas de sesión duras + mini-pósters. Preview sin login: `lib/main_preview.dart`
  (`flutter build web -t lib/main_preview.dart`).
- ✅ Fase 2 (2026-06-12): Workout activo + descanso como HUD Telemetría
  (anillo de descanso `_RestRingPainter`, header con progreso segmentado por
  serie, contador/reloj mono, descanso siempre oscuro `ZarpaInk.black`).
- ✅ Fase 3 (2026-06-12): Stats en Asfalto (racha gigante, bloques de mes con
  retícula, barras cuadradas, filas duras) y workout completion como póster
  compartible (cabina oscura, duración protagonista, COMPARTIR al portapapeles).
- ⏳ Fase 4: login como póster, perfil, detalle de rutina (sigue antiguo),
  empty states del sistema.
