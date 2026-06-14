import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/zarpafit_theme.dart';

class WorkoutCompletionScreen extends StatefulWidget {
  const WorkoutCompletionScreen({
    super.key,
    required this.routineName,
    required this.completedSets,
    required this.totalSets,
    required this.durationMinutes,
    required this.exerciseCount,
  });

  final String routineName;
  final int completedSets;
  final int totalSets;
  final int durationMinutes;
  final int exerciseCount;

  @override
  State<WorkoutCompletionScreen> createState() =>
      _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState extends State<WorkoutCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calories = (widget.durationMinutes * 7.5).round();

    // Póster de cierre: cabina oscura siempre, en ambos temas.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ZarpaInk.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'ZARPAFIT',
                          style: TextStyle(
                            fontFamily: ZarpaFonts.mono,
                            fontSize: 11,
                            color: ZarpaInk.steel,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'SESIÓN COMPLETADA',
                          style: TextStyle(
                            fontFamily: ZarpaFonts.mono,
                            fontSize: 11,
                            color: ZarpaColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Protagonista: duración gigante.
                    Text(
                      'HAS ENTRENADO',
                      style: TextStyle(
                        fontFamily: ZarpaFonts.mono,
                        fontSize: 12,
                        color: ZarpaInk.steel,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          '${widget.durationMinutes}',
                          style: const TextStyle(
                            fontFamily: ZarpaFonts.display,
                            fontSize: 140,
                            fontWeight: FontWeight.w700,
                            color: ZarpaInk.paper,
                            height: 0.85,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 18),
                          child: Text(
                            'MIN',
                            style: TextStyle(
                              fontFamily: ZarpaFonts.display,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: ZarpaColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.routineName.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: ZarpaInk.paper,
                        height: 1.0,
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Retícula de cifras.
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _StatCell(
                            value:
                                '${widget.completedSets}/${widget.totalSets}',
                            label: 'SERIES',
                          ),
                          const _CellDivider(),
                          _StatCell(
                            value: '${widget.exerciseCount}',
                            label: 'EJERCICIOS',
                          ),
                          const _CellDivider(),
                          _StatCell(value: '$calories', label: 'KCAL'),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF333333)),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                            onPressed: () => _shareSummary(calories),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.ios_share,
                                    size: 18, color: ZarpaInk.paper),
                                SizedBox(width: 8),
                                Text(
                                  'COMPARTIR',
                                  style: TextStyle(
                                    fontFamily: ZarpaFonts.display,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: ZarpaInk.paper,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: ZarpaColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                            onPressed: () =>
                                Navigator.of(context).popUntil((r) => r.isFirst),
                            child: const Text(
                              'TERMINAR',
                              style: TextStyle(
                                fontFamily: ZarpaFonts.display,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shareSummary(int calories) {
    final text =
        'He entrenado ${widget.durationMinutes} min · ${widget.routineName} · '
        '${widget.completedSets}/${widget.totalSets} series · $calories kcal 🐾 ZarpaFit';
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumen copiado al portapapeles')),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: ZarpaFonts.display,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: ZarpaInk.paper,
                  height: 0.95,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: ZarpaFonts.mono,
                fontSize: 10,
                color: ZarpaInk.steel,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CellDivider extends StatelessWidget {
  const _CellDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF2A2A2A),
    );
  }
}
