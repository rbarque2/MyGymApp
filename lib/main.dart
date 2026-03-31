import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/root_screen.dart';
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
  runApp(const ZarpaFitApp());
}

class ZarpaFitApp extends StatelessWidget {
  const ZarpaFitApp({super.key});

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
    return MaterialApp(
      title: 'ZarpaFit',
      debugShowCheckedModeBanner: false,
      theme: zarpaFitTheme(),
      home: const RootScreen(),
    );
  }
}