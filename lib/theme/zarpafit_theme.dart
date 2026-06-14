import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta semántica de superficies/texto. Una instancia por modo.
class ZarpaPalette {
  const ZarpaPalette({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.foreground,
    required this.muted,
    required this.mutedLight,
    required this.border,
    required this.navSurface,
    required this.navBorder,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color foreground;
  final Color muted;
  final Color mutedLight;
  final Color border;
  final Color navSurface;
  final Color navBorder;
}

const _light = ZarpaPalette(
  background: Color(0xFFF8FAFC), // slate-50
  surface: Color(0xFFFFFFFF), // white
  surface2: Color(0xFFF1F5F9), // slate-100
  foreground: Color(0xFF0F172A), // slate-900
  muted: Color(0xFF64748B), // slate-500
  mutedLight: Color(0xFF94A3B8), // slate-400
  border: Color(0xFFE2E8F0), // slate-200
  navSurface: Color(0xFFFFFFFF),
  navBorder: Color(0xFFE2E8F0),
);

const _dark = ZarpaPalette(
  background: Color(0xFF111827), // gray-900
  surface: Color(0xFF1F2937), // gray-800
  surface2: Color(0xFF374151), // gray-700
  foreground: Color(0xFFF8FAFC), // slate-50
  muted: Color(0xFF9CA3AF), // gray-400
  mutedLight: Color(0xFF6B7280), // gray-500
  border: Color(0xFF374151), // gray-700
  navSurface: Color(0xFF1F2937),
  navBorder: Color(0xFF374151),
);

/// Colores de marca ZarpaFit — Vibrant & Block-based.
///
/// Los colores de marca (naranja/verde/estados) son iguales en ambos modos
/// y siguen siendo `const`. Los de superficie/texto delegan en la paleta
/// activa, que se intercambia con [ZarpaColors.apply] antes de construir
/// el MaterialApp.
abstract final class ZarpaColors {
  static ZarpaPalette _p = _light;

  static bool get isDark => identical(_p, _dark);

  static void apply(Brightness brightness) {
    _p = brightness == Brightness.dark ? _dark : _light;
  }

  // === Base (cambian con el modo) ===
  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surface2 => _p.surface2;
  static Color get foreground => _p.foreground;
  static Color get muted => _p.muted;
  static Color get mutedLight => _p.mutedLight;
  static Color get border => _p.border;

  // === Brand (constantes en ambos modos) ===
  static const primary = Color(0xFFF97316); // orange-500
  static const primaryLight = Color(0xFFFB923C); // orange-400
  static const primaryAlpha = Color(0xDEF97316);
  static const cta = Color(0xFF22C55E); // green-500
  static const ctaLight = Color(0xFF4ADE80); // green-400

  // === Legacy aliases ===
  static const espresso = Color(0xFF3A2418);
  static const cream = Color(0xFFD6C3A1);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // === Categorías ===
  static const fuerza = Color(0xFFF97316);
  static const hiit = Color(0xFFEF4444);
  static const cardio = Color(0xFF22C55E);
  static const movilidad = Color(0xFFFBBF24);

  // === Nav & overlays ===
  static Color get darkSurface => _p.navSurface;
  static Color get darkBorder => _p.navBorder;
}

/// Tipografía de marca: Barlow Condensed para titulares, Barlow para cuerpo,
/// IBM Plex Mono para microetiquetas técnicas (fechas, metadatos, telemetría).
abstract final class ZarpaFonts {
  static const body = 'Barlow';
  static const display = 'BarlowCondensed';
  static const mono = 'IBMPlexMono';
}

/// Tinta del sistema híbrido (póster/HUD/asfalto): tonos fijos que NO cambian
/// con el modo de tema — se usan sobre fotografía o en pantallas dark-first.
abstract final class ZarpaInk {
  static const black = Color(0xFF0A0A0A);
  static const veilTop = Color(0x73000000); // negro 45% (legibilidad header)
  static const veilMid = Color(0x1A000000); // negro 10% (foto respira)
  static const veilBottom = Color(0xDB000000); // negro 86%
  static const paper = Color(0xFFF8FAFC);
  static const steel = Color(0xFFC7BEB5); // gris cálido para mono sobre foto
}

ThemeData zarpaFitTheme() => _buildTheme(_light, Brightness.light);

ThemeData zarpaFitThemeDark() => _buildTheme(_dark, Brightness.dark);

ThemeData _buildTheme(ZarpaPalette p, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  TextStyle display(double size, FontWeight weight) => TextStyle(
        fontFamily: ZarpaFonts.display,
        fontSize: size,
        fontWeight: weight,
        color: p.foreground,
        letterSpacing: 0.3,
        height: 1.1,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.background,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: ZarpaColors.primary,
      onPrimary: Colors.white,
      secondary: ZarpaColors.primaryLight,
      onSecondary: Colors.white,
      surface: p.surface,
      onSurface: p.foreground,
      error: ZarpaColors.error,
      onError: Colors.white,
      outline: p.border,
      surfaceContainerHighest: p.surface2,
      onSurfaceVariant: p.muted,
    ),
    fontFamily: ZarpaFonts.body,
    textTheme: TextTheme(
      displayLarge: display(40, FontWeight.w700),
      displayMedium: display(34, FontWeight.w700),
      displaySmall: display(28, FontWeight.w700),
      headlineLarge: display(26, FontWeight.w700),
      headlineMedium: display(24, FontWeight.w600),
      headlineSmall: display(22, FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.foreground,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: ZarpaFonts.display,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: p.foreground,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.navSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: ZarpaColors.primary.withOpacity(0.16),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.5,
          color: selected ? ZarpaColors.primary : p.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? ZarpaColors.primary : p.muted,
          size: 24,
        );
      }),
      height: 64,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZarpaColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: ZarpaFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.foreground,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ZarpaColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: ZarpaColors.primary.withOpacity(0.12),
      side: BorderSide(color: p.border),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.foreground,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: DividerThemeData(
      color: p.border,
      thickness: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.foreground,
      contentTextStyle: TextStyle(
        fontFamily: ZarpaFonts.body,
        color: p.background,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
