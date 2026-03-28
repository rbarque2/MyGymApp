import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

// Web audio API interop
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Servicio de sonido para los beeps de la cuenta atrás.
/// Usa Web Audio API directamente (compatible con Flutter web).
class BeepService {
  static BeepService? _instance;
  factory BeepService() => _instance ??= BeepService._();
  BeepService._();

  /// Reproduce un beep corto (pip).
  void playShortBeep() {
    _playTone(frequency: 880, durationMs: 150);
  }

  /// Reproduce un beep largo (piiiiip).
  void playLongBeep() {
    _playTone(frequency: 1046, durationMs: 500);
  }

  void _playTone({required double frequency, required int durationMs}) {
    try {
      if (kIsWeb) {
        _playWebTone(frequency, durationMs);
      }
    } catch (e) {
      debugPrint('Error al reproducir beep: $e');
    }
  }

  void _playWebTone(double frequency, int durationMs) {
    // Generar audio usando AudioContext de Web Audio API
    final context = web.AudioContext();
    final oscillator = context.createOscillator();
    final gainNode = context.createGain();

    oscillator.type = 'sine';
    oscillator.frequency.value = frequency;
    gainNode.gain.value = 0.5;

    oscillator.connect(gainNode);
    gainNode.connect(context.destination);

    oscillator.start();

    // Programar el stop
    Future.delayed(Duration(milliseconds: durationMs), () {
      oscillator.stop();
      context.close();
    });
  }
}
