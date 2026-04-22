import 'package:flutter/material.dart';

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
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calories = (widget.durationMinutes * 7.5).round(); // estimate

    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Trophy animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ZarpaColors.primary.withOpacity(0.1),
                    border:
                        Border.all(color: ZarpaColors.primary, width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.emoji_events,
                        size: 56, color: ZarpaColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // COMPLETADO
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'COMPLETADO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: ZarpaColors.primary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.routineName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ZarpaColors.muted,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats grid
                    Row(
                      children: [
                        _CompletionStat(
                          icon: Icons.timer,
                          value: '${widget.durationMinutes}',
                          label: 'MINUTOS',
                        ),
                        const SizedBox(width: 12),
                        _CompletionStat(
                          icon: Icons.fitness_center,
                          value: '${widget.exerciseCount}',
                          label: 'EJERCICIOS',
                        ),
                        const SizedBox(width: 12),
                        _CompletionStat(
                          icon: Icons.local_fire_department,
                          value: '$calories',
                          label: 'KCAL',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sets completed
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ZarpaColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ZarpaColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 20, color: ZarpaColors.success),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.completedSets}/${widget.totalSets} series completadas',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ZarpaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 20, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'VOLVER AL INICIO',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  const _CompletionStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: ZarpaColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ZarpaColors.muted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
