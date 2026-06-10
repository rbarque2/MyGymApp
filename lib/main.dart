import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/root_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'theme/zarpafit_theme.dart';

String? _initError;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    _initError = e.toString();
  }
  await NotificationService.instance.init();
  runApp(const ZarpaFitApp());
}

class ZarpaFitApp extends StatefulWidget {
  const ZarpaFitApp({super.key});

  @override
  State<ZarpaFitApp> createState() => _ZarpaFitAppState();
}

class _ZarpaFitAppState extends State<ZarpaFitApp>
    with WidgetsBindingObserver {
  final _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settingsService.load().then((_) {
      // Reasegura el recordatorio diario (id fijo: reprogramar es idempotente).
      if (_settingsService.reminderEnabled) {
        NotificationService.instance
            .scheduleDailyReminder(_settingsService.reminderTime);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Con modo "sistema", la paleta debe re-aplicarse al cambiar el SO.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Firebase init error:\n\n$_initError',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: _settingsService,
      builder: (context, _) {
        final mode = _settingsService.themeMode;
        final platformBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                platformBrightness == Brightness.dark);
        // ZarpaColors alimenta los colores hardcodeados de las pantallas;
        // debe apuntar a la paleta correcta antes de construir el árbol.
        ZarpaColors.apply(isDark ? Brightness.dark : Brightness.light);
        return MaterialApp(
          title: 'ZarpaFit',
          debugShowCheckedModeBanner: false,
          theme: zarpaFitTheme(),
          darkTheme: zarpaFitThemeDark(),
          themeMode: mode,
          home: RootScreen(settingsService: _settingsService),
        );
      },
    );
  }
}
