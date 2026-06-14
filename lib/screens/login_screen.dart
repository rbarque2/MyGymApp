import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/zarpafit_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;
  int _wordIndex = 0;
  Timer? _wordTimer;

  static const _words = ['INSTINTO', 'ASFALTO', 'FUERZA', 'ZARPA'];

  // Foto de portada del póster de bienvenida (misma fuente que las rutinas).
  static const _coverUrl =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';

  @override
  void initState() {
    super.initState();
    _wordTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _wordIndex = (_wordIndex + 1) % _words.length);
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.authService.signInWithGoogle();
    } on AuthCancelledException {
      // El usuario cerró el flujo.
    } catch (error) {
      debugPrint('Login error: $error');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo iniciar sesión. Inténtalo de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Póster de bienvenida: cabina oscura full-bleed, en ambos temas.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ZarpaInk.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: ZarpaInk.black),
            Image.network(
              _coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B2415), Color(0xFF0A0A0A)],
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [
                    ZarpaInk.veilTop,
                    ZarpaInk.veilMid,
                    ZarpaInk.veilBottom,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ZARPAFIT',
                      style: TextStyle(
                        fontFamily: ZarpaFonts.mono,
                        fontSize: 12,
                        color: ZarpaInk.steel,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    // Palabra de marca gigante rotativa.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: Text(
                        _words[_wordIndex],
                        key: ValueKey(_wordIndex),
                        style: const TextStyle(
                          fontFamily: ZarpaFonts.display,
                          fontSize: 76,
                          fontWeight: FontWeight.w700,
                          color: ZarpaColors.primary,
                          height: 0.9,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const Text(
                      'EN MOVIMIENTO.',
                      style: TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: ZarpaInk.paper,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Sin ruido. Sin excusas. Despierta la zarpa.',
                      style: TextStyle(
                        fontFamily: ZarpaFonts.body,
                        fontSize: 15,
                        color: ZarpaInk.steel,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: ZarpaColors.error.withOpacity(0.15),
                          border:
                              Border.all(color: ZarpaColors.error.withOpacity(0.5)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFF09595)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: ZarpaInk.paper,
                          foregroundColor: ZarpaInk.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: ZarpaFonts.display,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            letterSpacing: 1.5,
                          ),
                        ),
                        onPressed: _loading ? null : _signIn,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: ZarpaInk.black),
                              )
                            : const Icon(Icons.login, size: 20),
                        label: const Text('ENTRAR CON GOOGLE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
