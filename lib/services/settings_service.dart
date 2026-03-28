import 'package:flutter/foundation.dart';

/// Servicio de configuración global de la app.
class SettingsService extends ChangeNotifier {
  /// Duración predeterminada del descanso en segundos.
  int _defaultRestSeconds = 60;

  /// Si el sonido de la cuenta atrás está habilitado.
  bool _countdownSoundEnabled = true;

  /// Segundo en el que empiezan los beeps (ej: 3 → beep en 3, 2, 1, 0).
  int _countdownBeepFrom = 3;

  int get defaultRestSeconds => _defaultRestSeconds;
  bool get countdownSoundEnabled => _countdownSoundEnabled;
  int get countdownBeepFrom => _countdownBeepFrom;

  set defaultRestSeconds(int value) {
    if (value < 5) value = 5;
    if (value > 600) value = 600;
    _defaultRestSeconds = value;
    notifyListeners();
  }

  set countdownSoundEnabled(bool value) {
    _countdownSoundEnabled = value;
    notifyListeners();
  }

  set countdownBeepFrom(int value) {
    if (value < 1) value = 1;
    if (value > 10) value = 10;
    _countdownBeepFrom = value;
    notifyListeners();
  }

  /// Formatea los segundos como MM:SS.
  String formatSeconds(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// Devuelve la etiqueta para mostrar el descanso predeterminado.
  String get defaultRestDisplay => formatSeconds(_defaultRestSeconds);
}
