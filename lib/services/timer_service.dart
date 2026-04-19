import 'dart:async';

import 'package:flutter/foundation.dart';

/// Servicio de temporizador de descanso entre series.
///
/// Usa un timestamp de fin (_endTime) como fuente de verdad. El ticker periódico
/// sólo refresca el valor mostrado — si el proceso se suspende (app en segundo
/// plano en iOS), al volver basta con llamar a [refresh] para recomputar.
class TimerService extends ChangeNotifier {
  Timer? _ticker;
  DateTime? _endTime;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  String get display {
    final secs = _remainingSeconds < 0 ? 0 : _remainingSeconds;
    final min = secs ~/ 60;
    final sec = secs % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void start(int seconds) {
    _ticker?.cancel();
    _endTime = DateTime.now().add(Duration(seconds: seconds));
    _remainingSeconds = seconds;
    _isRunning = true;
    notifyListeners();

    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  void _tick() {
    if (_endTime == null) return;
    final remaining = _endTime!.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      _remainingSeconds = 0;
      stop();
      return;
    }
    if (remaining != _remainingSeconds) {
      _remainingSeconds = remaining;
      notifyListeners();
    }
  }

  /// Ajusta el tiempo restante en delta segundos (puede ser negativo).
  void adjustSeconds(int delta) {
    if (!_isRunning || _endTime == null) return;
    _endTime = _endTime!.add(Duration(seconds: delta));
    final newRemaining = _endTime!.difference(DateTime.now()).inSeconds;
    if (newRemaining <= 0) {
      _remainingSeconds = 0;
      stop();
      return;
    }
    _remainingSeconds = newRemaining;
    notifyListeners();
  }

  /// Recalcula el tiempo restante. Debe llamarse al volver del background.
  void refresh() {
    if (!_isRunning) return;
    _tick();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _endTime = null;
    notifyListeners();
  }

  void reset(int seconds) {
    stop();
    _remainingSeconds = seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
