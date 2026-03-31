import 'package:flutter/material.dart';

/// Colores de marca ZarpaFit.
abstract final class ZarpaColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const surface2 = Color(0xFFEEEEEE);
  static const foreground = Color(0xFF000000);
  static const muted = Color(0xFF666666);
  static const primary = Color(0xFF0000FF);
  static const primaryAlpha = Color(0xDE0000FF);
  static const espresso = Color(0xFF3A2418);
  static const cream = Color(0xFFD6C3A1);
  static const border = Color(0xFFDDDDDD);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Categorías
  static const fuerza = Color(0xFF0000FF);
  static const hiit = Color(0xFFEF4444);
  static const cardio = Color(0xFF22C55E);
  static const movilidad = Color(0xFFD6C3A1);

  // Dark surfaces (para nav bar, overlays)
  static const darkSurface = Color(0xFF171717);
  static const darkBorder = Color(0xFF2A2D34);
  static const mutedLight = Color(0xFF9BA1A6);
}

/// Tema de la app ZarpaFit.
ThemeData zarpaFitTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ZarpaColors.surface,
    colorScheme: const ColorScheme.light(
      primary: ZarpaColors.primary,
      onPrimary: Colors.white,
      secondary: ZarpaColors.espresso,
      surface: ZarpaColors.surface,
      onSurface: ZarpaColors.foreground,
      error: ZarpaColors.error,
      outline: ZarpaColors.border,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ZarpaColors.foreground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: ZarpaColors.foreground,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ZarpaColors.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ZarpaColors.primary,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: selected ? Colors.white : Colors.white.withOpacity(0.5),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? Colors.white : Colors.white.withOpacity(0.5),
          size: 24,
        );
      }),
      height: 64,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZarpaColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ZarpaColors.foreground,
        side: const BorderSide(color: ZarpaColors.foreground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ZarpaColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: ZarpaColors.primary.withOpacity(0.1),
      side: const BorderSide(color: ZarpaColors.border),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ZarpaColors.foreground,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(
      color: ZarpaColors.border,
      thickness: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
