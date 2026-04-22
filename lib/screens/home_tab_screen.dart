import 'dart:async';

import 'package:flutter/material.dart';

import '../models/routine_model.dart';
import '../models/workout_session_model.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import '../repositories/exercises_repository.dart';
import '../theme/zarpafit_theme.dart';
import 'routine_detail_screen.dart';
import 'workout_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({
    super.key,
    required this.ownerUid,
    required this.userName,
    required this.routinesRepository,
    required this.exercisesRepository,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final String ownerUid;
  final String userName;
  final RoutinesRepository routinesRepository;
  final ExercisesRepository exercisesRepository;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  List<WorkoutSessionModel> _recentWorkouts = [];
  int _sloganIndex = 0;
  double _sloganOpacity = 1.0;
  Timer? _sloganTimer;

  static const _slogans = [
    'Instinto en movimiento',
    'Fuerza de asfalto',
    'Sin ruido. Sin excusas.',
    'Despierta la zarpa interior',
    'Cada serie cuenta',
  ];

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'NOCHE DE HIERRO';
    if (hour < 12) return 'BUENOS DÍAS';
    if (hour < 18) return 'BUENAS TARDES';
    return 'BUENAS NOCHES';
  }

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _startSloganRotation();
  }

  @override
  void dispose() {
    _sloganTimer?.cancel();
    super.dispose();
  }

  void _startSloganRotation() {
    _sloganTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _sloganOpacity = 0.0);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _sloganIndex = (_sloganIndex + 1) % _slogans.length;
          _sloganOpacity = 1.0;
        });
      });
    });
  }

  Future<void> _loadRecent() async {
    final data = await widget.workoutsRepository.getRecentWorkouts(
      widget.ownerUid,
      limit: 3,
    );
    if (mounted) setState(() => _recentWorkouts = data);
  }

  int _calculateStreak(List<WorkoutSessionModel> workouts) {
    if (workouts.isEmpty) return 0;
    int streak = 0;
    DateTime check = DateTime.now();
    final dates = workouts
        .where((w) => w.startedAt != null)
        .map((w) {
          final d = w.startedAt!.toDate();
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in dates) {
      final diff = DateTime(check.year, check.month, check.day)
          .difference(date)
          .inDays;
      if (diff <= 1) {
        streak++;
        check = date;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: SafeArea(
        child: StreamBuilder<List<RoutineModel>>(
          stream: widget.routinesRepository.watchRoutines(widget.ownerUid),
          builder: (context, routineSnap) {
            final routines = routineSnap.data ?? [];
            final streak = _calculateStreak(_recentWorkouts);
            final totalMin = _recentWorkouts.fold<int>(
                0, (sum, w) => sum + (w.durationMinutes ?? 0));

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // === HEADER ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: TextStyle(
                            fontSize: 13,
                            color: ZarpaColors.primary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userName.split(' ').first,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: ZarpaColors.foreground,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ZarpaColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/zarpafit_logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // === STATS ROW ===
                Row(
                  children: [
                    _StatMiniCard(
                      icon: Icons.local_fire_department,
                      value: '$streak',
                      label: 'RACHA',
                      iconColor: ZarpaColors.primary,
                      highlight: true,
                    ),
                    const SizedBox(width: 10),
                    _StatMiniCard(
                      icon: Icons.fitness_center,
                      value: '${_recentWorkouts.length}',
                      label: 'SESIONES',
                      iconColor: ZarpaColors.cta,
                    ),
                    const SizedBox(width: 10),
                    _StatMiniCard(
                      icon: Icons.timer_outlined,
                      value: '$totalMin',
                      label: 'MINUTOS',
                      iconColor: ZarpaColors.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // === FEATURED WORKOUT ===
                if (routines.isNotEmpty) ...[
                  _SectionTitle(label: 'ENTRENAMIENTO DEL DÍA'),
                  const SizedBox(height: 14),
                  _FeaturedRoutineCard(
                    routine: routines.first,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RoutineDetailScreen(
                          ownerUid: widget.ownerUid,
                          routine: routines.first,
                          routinesRepository: widget.routinesRepository,
                          exercisesRepository: widget.exercisesRepository,
                          workoutsRepository: widget.workoutsRepository,
                          settingsService: widget.settingsService,
                        ),
                      ),
                    ),
                    onStart: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WorkoutScreen(
                          ownerUid: widget.ownerUid,
                          routine: routines.first,
                          workoutsRepository: widget.workoutsRepository,
                          settingsService: widget.settingsService,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // === QUICK ROUTINES ===
                if (routines.length > 1) ...[
                  _SectionTitle(label: 'RUTINAS RÁPIDAS'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: routines.length.clamp(0, 6),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final r = routines[i];
                        return _QuickRoutineCard(
                          routine: r,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RoutineDetailScreen(
                                ownerUid: widget.ownerUid,
                                routine: r,
                                routinesRepository:
                                    widget.routinesRepository,
                                exercisesRepository:
                                    widget.exercisesRepository,
                                workoutsRepository:
                                    widget.workoutsRepository,
                                settingsService: widget.settingsService,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // === RECENT SESSIONS ===
                if (_recentWorkouts.isNotEmpty) ...[
                  _SectionTitle(label: 'ÚLTIMAS SESIONES'),
                  const SizedBox(height: 14),
                  ...List.generate(_recentWorkouts.length, (i) {
                    final w = _recentWorkouts[i];
                    final date = w.startedAt?.toDate();
                    final dateStr = date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : '';
                    return _RecentSessionRow(
                      name: w.routineName,
                      date: dateStr,
                      duration: '${w.durationMinutes ?? 0} min',
                      isLast: i == _recentWorkouts.length - 1,
                    );
                  }),
                  const SizedBox(height: 32),
                ],

                // === SLOGAN ROTATIVO ===
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: ZarpaColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: AnimatedOpacity(
                    opacity: _sloganOpacity,
                    duration: Duration(
                        milliseconds: _sloganOpacity == 0.0 ? 300 : 400),
                    child: Text(
                      _slogans[_sloganIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: ZarpaColors.primary.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// === WIDGETS PRIVADOS ===

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: ZarpaColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ZarpaColors.foreground,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    this.highlight = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlight
              ? ZarpaColors.primary.withOpacity(0.08)
              : ZarpaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight ? ZarpaColors.primary.withOpacity(0.3) : ZarpaColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ZarpaColors.foreground,
                letterSpacing: -0.5,
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

class _FeaturedRoutineCard extends StatelessWidget {
  const _FeaturedRoutineCard({
    required this.routine,
    required this.onTap,
    required this.onStart,
  });
  final RoutineModel routine;
  final VoidCallback onTap;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final exCount = routine.exercises.length;
    final totalSets =
        routine.exercises.fold<int>(0, (sum, e) => sum + e.sets);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ZarpaColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'RUTINA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Icon(
              Icons.fitness_center,
              size: 36,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 10),
            Text(
              routine.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            if (routine.description != null) ...[
              const SizedBox(height: 6),
              Text(
                routine.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.fitness_center,
                    size: 14, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  '$exCount ejercicios',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.85)),
                ),
                const SizedBox(width: 16),
                Icon(Icons.repeat,
                    size: 14, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  '$totalSets series',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ZarpaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: routine.exercises.isEmpty ? null : onStart,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'COMENZAR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
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

class _QuickRoutineCard extends StatelessWidget {
  const _QuickRoutineCard({required this.routine, required this.onTap});
  final RoutineModel routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZarpaColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.fitness_center,
                size: 24, color: ZarpaColors.primary),
            const SizedBox(height: 10),
            Text(
              routine.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ZarpaColors.foreground,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ZarpaColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${routine.exercises.length} ej.',
                style: const TextStyle(
                  fontSize: 11,
                  color: ZarpaColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionRow extends StatelessWidget {
  const _RecentSessionRow({
    required this.name,
    required this.date,
    required this.duration,
    required this.isLast,
  });
  final String name;
  final String date;
  final String duration;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZarpaColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ZarpaColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: ZarpaColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZarpaColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZarpaColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ZarpaColors.cta.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              duration,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ZarpaColors.cta,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              size: 18, color: ZarpaColors.mutedLight),
        ],
      ),
    );
  }
}
