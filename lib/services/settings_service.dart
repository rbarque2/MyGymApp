import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de configuración global de la app.
class SettingsService extends ChangeNotifier {
  static const _keyRestSeconds = 'defaultRestSeconds';
  static const _keySoundEnabled = 'countdownSoundEnabled';
  static const _keyBeepFrom = 'countdownBeepFrom';
  static const _keyThemeMode = 'themeMode';
  static const _keyReminderEnabled = 'workoutReminderEnabled';
  static const _keyReminderHour = 'workoutReminderHour';
  static const _keyReminderMinute = 'workoutReminderMinute';

  /// Duración predeterminada del descanso en segundos.
  int _defaultRestSeconds = 45;

  /// Si el sonido de la cuenta atrás está habilitado.
  bool _countdownSoundEnabled = true;

  /// Segundo en el que empiezan los beeps (ej: 3 → beep en 3, 2, 1, 0).
  int _countdownBeepFrom = 3;

  /// Modo de tema: sistema, claro u oscuro.
  ThemeMode _themeMode = ThemeMode.system;

  /// Recordatorio diario de entrenamiento.
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);

  int get defaultRestSeconds => _defaultRestSeconds;
  bool get countdownSoundEnabled => _countdownSoundEnabled;
  int get countdownBeepFrom => _countdownBeepFrom;
  ThemeMode get themeMode => _themeMode;
  bool get reminderEnabled => _reminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  /// Carga los valores guardados desde SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultRestSeconds = prefs.getInt(_keyRestSeconds) ?? 45;
    _countdownSoundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    _countdownBeepFrom = prefs.getInt(_keyBeepFrom) ?? 3;
    _themeMode = ThemeMode.values.asNameMap()[prefs.getString(_keyThemeMode)] ??
        ThemeMode.system;
    _reminderEnabled = prefs.getBool(_keyReminderEnabled) ?? false;
    _reminderTime = TimeOfDay(
      hour: prefs.getInt(_keyReminderHour) ?? 19,
      minute: prefs.getInt(_keyReminderMinute) ?? 0,
    );
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRestSeconds, _defaultRestSeconds);
    await prefs.setBool(_keySoundEnabled, _countdownSoundEnabled);
    await prefs.setInt(_keyBeepFrom, _countdownBeepFrom);
    await prefs.setString(_keyThemeMode, _themeMode.name);
    await prefs.setBool(_keyReminderEnabled, _reminderEnabled);
    await prefs.setInt(_keyReminderHour, _reminderTime.hour);
    await prefs.setInt(_keyReminderMinute, _reminderTime.minute);
  }

  set defaultRestSeconds(int value) {
    if (value < 5) value = 5;
    if (value > 600) value = 600;
    _defaultRestSeconds = value;
    notifyListeners();
    _save();
  }

  set countdownSoundEnabled(bool value) {
    _countdownSoundEnabled = value;
    notifyListeners();
    _save();
  }

  set countdownBeepFrom(int value) {
    if (value < 1) value = 1;
    if (value > 10) value = 10;
    _countdownBeepFrom = value;
    notifyListeners();
    _save();
  }

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
    _save();
  }

  set reminderEnabled(bool value) {
    _reminderEnabled = value;
    notifyListeners();
    _save();
  }

  set reminderTime(TimeOfDay value) {
    _reminderTime = value;
    notifyListeners();
    _save();
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
