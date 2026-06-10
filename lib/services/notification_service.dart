import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notificaciones locales: fin del descanso entre series y recordatorio
/// diario de entrenamiento. No disponible en web (no-op silencioso).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _restEndId = 1001;
  static const _dailyReminderId = 2001;

  static const _restDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'rest_timer',
      'Temporizador de descanso',
      channelDescription: 'Aviso cuando termina el descanso entre series',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'workout_reminder',
      'Recordatorio de entrenamiento',
      channelDescription: 'Recordatorio diario para no perder la racha',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
  );

  Future<void> init() async {
    if (kIsWeb || _ready) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Se queda en UTC: el timer de descanso usa duraciones relativas y no
      // se ve afectado; solo el recordatorio diario perdería la zona local.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(settings);
      _ready = true;
    } catch (_) {
      // Plataforma sin soporte: la app sigue funcionando sin notificaciones.
    }
  }

  /// Pide permiso al usuario. Idempotente: el sistema solo muestra el
  /// diálogo la primera vez.
  Future<bool> requestPermissions() async {
    if (!_ready) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macos != null) {
      return await macos.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Programa el aviso de fin de descanso dentro de [remaining].
  /// Llamar cuando la app pasa a segundo plano con el timer corriendo.
  Future<void> scheduleRestEnd(Duration remaining) async {
    if (!_ready || remaining <= Duration.zero) return;
    final when = tz.TZDateTime.now(tz.local).add(remaining);
    try {
      await _plugin.zonedSchedule(
        _restEndId,
        'Descanso terminado',
        'Vuelve a la carga: te espera la siguiente serie.',
        when,
        _restDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Sin permiso de alarma exacta (Android 12+): mejor aproximado que nada.
      try {
        await _plugin.zonedSchedule(
          _restEndId,
          'Descanso terminado',
          'Vuelve a la carga: te espera la siguiente serie.',
          when,
          _restDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {}
    }
  }

  /// Cancela el aviso de fin de descanso (la app volvió a primer plano,
  /// el usuario saltó el descanso o terminó la sesión).
  Future<void> cancelRestEnd() async {
    if (!_ready) return;
    await _plugin.cancel(_restEndId);
  }

  /// Programa el recordatorio diario de entrenamiento a la hora dada.
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_ready) return;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        'Hora de entrenar',
        'Tu zarpa no se afila sola. Dale a la primera serie.',
        when,
        _reminderDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> cancelDailyReminder() async {
    if (!_ready) return;
    await _plugin.cancel(_dailyReminderId);
  }
}
