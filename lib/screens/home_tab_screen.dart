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
      backgroundColor: Colors.white,
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
                          style: const TextStyle(
                            fontSize: 14,
                            color: ZarpaColors.muted,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.userName.split(' ').first,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: ZarpaColors.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/zarpafit_logo.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // === STATS ROW ===
                Row(
                  children: [
                    _StatMiniCard(
                      icon: Icons.local_fire_department,
                      value: '$streak',
                      label: 'RACHA',
                      iconColor: ZarpaColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatMiniCard(
                      icon: Icons.fitness_center,
                      value: '${_recentWorkouts.length}',
                      label: 'SESIONES',
                      iconColor: ZarpaColors.foreground,
                    ),
                    const SizedBox(width: 12),
                    _StatMiniCard(
                      icon: Icons.timer_outlined,
                      value: '$totalMin',
                      label: 'MINUTOS',
                      iconColor: ZarpaColors.mutedLight,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // === FEATURED WORKOUT ===
                if (routines.isNotEmpty) ...[
                  _SectionTitle(label: 'ENTRENAMIENTO DEL DÍA'),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 28),
                ],

                // === QUICK ROUTINES ===
                if (routines.length > 1) ...[
                  _SectionTitle(label: 'RUTINAS RÁPIDAS'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
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
                  const SizedBox(height: 28),
                ],

                // === RECENT SESSIONS ===
                if (_recentWorkouts.isNotEmpty) ...[
                  _SectionTitle(label: 'ÚLTIMAS SESIONES'),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 28),
                ],

                // === SLOGAN ROTATIVO ===
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: ZarpaColors.primary, width: 1),
                    ),
                  ),
                  child: AnimatedOpacity(
                    opacity: _sloganOpacity,
                    duration: Duration(
                        milliseconds: _sloganOpacity == 0.0 ? 300 : 400),
                    child: Text(
                      _slogans[_sloganIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ZarpaColors.muted,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
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
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ZarpaColors.muted,
        letterSpacing: 2,
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ZarpaColors.muted,
                letterSpacing: 0.5,
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
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZarpaColors.border),
          // Blue left accent
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ZarpaColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'FUERZA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '💪',
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              routine.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ZarpaColors.foreground,
                letterSpacing: -0.5,
              ),
            ),
            if (routine.description != null) ...[
              const SizedBox(height: 4),
              Text(
                routine.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: ZarpaColors.muted,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.fitness_center,
                    size: 14, color: ZarpaColors.mutedLight),
                const SizedBox(width: 4),
                Text(
                  '$exCount ejercicios',
                  style: const TextStyle(
                      fontSize: 12, color: ZarpaColors.muted),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.repeat,
                    size: 14, color: ZarpaColors.mutedLight),
                const SizedBox(width: 4),
                Text(
                  '$totalSets series',
                  style: const TextStyle(
                      fontSize: 12, color: ZarpaColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ZarpaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.white),
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
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💪', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
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
            Text(
              '${routine.exercises.length} ej.',
              style: const TextStyle(
                fontSize: 11,
                color: ZarpaColors.muted,
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: ZarpaColors.surface2, width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ZarpaColors.primary,
              borderRadius: BorderRadius.circular(4),
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
          Text(
            duration,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ZarpaColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
