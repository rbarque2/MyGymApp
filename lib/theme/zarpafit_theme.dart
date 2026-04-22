import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colores de marca ZarpaFit — Light & Vibrant.
abstract final class ZarpaColors {
  // === Base ===
  static const background = Color(0xFFF8FAFC);   // slate-50  (scaffold)
  static const surface = Color(0xFFFFFFFF);       // white     (cards)
  static const surface2 = Color(0xFFF1F5F9);     // slate-100 (secondary)
  static const foreground = Color(0xFF0F172A);    // slate-900 (body text)
  static const muted = Color(0xFF64748B);         // slate-500 (secondary text)
  static const mutedLight = Color(0xFF94A3B8);    // slate-400 (icons / hints)

  // === Brand ===
  static const primary = Color(0xFFF97316);       // orange-500
  static const primaryLight = Color(0xFFFB923C);  // orange-400
  static const primaryAlpha = Color(0xDEF97316);
  static const cta = Color(0xFF22C55E);           // green-500
  static const ctaLight = Color(0xFF4ADE80);      // green-400

  // === Legacy aliases ===
  static const espresso = Color(0xFF3A2418);
  static const cream = Color(0xFFD6C3A1);
  static const border = Color(0xFFE2E8F0);        // slate-200
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // === Categorías ===
  static const fuerza = Color(0xFFF97316);
  static const hiit = Color(0xFFEF4444);
  static const cardio = Color(0xFF22C55E);
  static const movilidad = Color(0xFFFBBF24);

  // === Nav & overlays ===
  static const darkSurface = Color(0xFFFFFFFF);   // white
  static const darkBorder = Color(0xFFE2E8F0);    // slate-200
}

/// Tema de la app ZarpaFit — Light & Vibrant.
ThemeData zarpaFitTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ZarpaColors.background,
    colorScheme: const ColorScheme.light(
      primary: ZarpaColors.primary,
      onPrimary: Colors.white,
      secondary: ZarpaColors.primaryLight,
      surface: ZarpaColors.surface,
      onSurface: ZarpaColors.foreground,
      error: ZarpaColors.error,
      outline: ZarpaColors.border,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: ZarpaColors.background,
      foregroundColor: ZarpaColors.foreground,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      color: ZarpaColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ZarpaColors.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ZarpaColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: ZarpaColors.primary.withOpacity(0.16),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.5,
          color: selected ? ZarpaColors.primary : ZarpaColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? ZarpaColors.primary : ZarpaColors.muted,
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
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ZarpaColors.foreground,
        side: const BorderSide(color: ZarpaColors.border),
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
      backgroundColor: ZarpaColors.surface,
      selectedColor: ZarpaColors.primary.withOpacity(0.12),
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
      color: ZarpaColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ZarpaColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ZarpaColors.foreground,
      contentTextStyle: const TextStyle(color: ZarpaColors.background),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
