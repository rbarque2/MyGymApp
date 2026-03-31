import 'package:flutter/foundation.dart';

import 'beep_service_native.dart'
    if (dart.library.js_interop) 'beep_service_web.dart';

/// Servicio de sonido para los beeps de la cuenta atrás.
/// Usa Web Audio API en web, no-op en otras plataformas.
class BeepService {
  static BeepService? _instance;
  factory BeepService() => _instance ??= BeepService._();
  BeepService._();

  /// Reproduce un beep corto (pip).
  void playShortBeep() {
    try {
      playShortBeepImpl();
    } catch (e) {
      debugPrint('Error al reproducir beep corto: $e');
    }
  }

  /// Reproduce un beep largo (piiiiip).
  void playLongBeep() {
    try {
      playLongBeepImpl();
    } catch (e) {
      debugPrint('Error al reproducir beep largo: $e');
    }
  }

  /// Reproduce un rugido de felino sintetizado.
  void playRoar() {
    try {
      playRoarImpl();
    } catch (e) {
      debugPrint('Error al reproducir rugido: $e');
    }
  }
}
