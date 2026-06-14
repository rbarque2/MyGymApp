import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/routine_model.dart';
import '../models/workout_session_model.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import '../repositories/exercises_repository.dart';
import '../theme/zarpafit_theme.dart';
import '../widgets/routine_cover.dart';
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
    this.onGoToRoutines,
  });

  final String ownerUid;
  final String userName;
  final RoutinesRepository routinesRepository;
  final ExercisesRepository exercisesRepository;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;
  final VoidCallback? onGoToRoutines;

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  List<WorkoutSessionModel> _recentWorkouts = [];
  int _wordIndex = 0;
  Timer? _wordTimer;

  /// Palabras-póster del sistema Instinto. Rotan como claim de marca.
  static const _displayWords = [
    'INSTINTO',
    'ZARPA',
    'ASFALTO',
    'FUERZA',
    'RITMO',
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
    _wordTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _wordIndex = (_wordIndex + 1) % _displayWords.length);
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    // Load up to 30 sessions so streak calculation is accurate;
    // only the first 3 are shown in the UI.
    final data = await widget.workoutsRepository.getRecentWorkouts(
      widget.ownerUid,
    );
    if (mounted) setState(() => _recentWorkouts = data);
  }

  static String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  static String _posterDate() {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    const months = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
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

  void _openDetail(RoutineModel routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          ownerUid: widget.ownerUid,
          routine: routine,
          routinesRepository: widget.routinesRepository,
          exercisesRepository: widget.exercisesRepository,
          workoutsRepository: widget.workoutsRepository,
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  void _startWorkout(RoutineModel routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          ownerUid: widget.ownerUid,
          routine: routine,
          workoutsRepository: widget.workoutsRepository,
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: StreamBuilder<List<RoutineModel>>(
        stream: widget.routinesRepository.watchRoutines(widget.ownerUid),
        builder: (context, routineSnap) {
          final routines = routineSnap.data ?? [];
          final streak = _calculateStreak(_recentWorkouts);
          final totalMin = _recentWorkouts.fold<int>(
              0, (sum, w) => sum + (w.durationMinutes ?? 0));

          if (routines.isEmpty) {
            return SafeArea(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    _greeting,
                    style: TextStyle(
                      fontFamily: ZarpaFonts.mono,
                      fontSize: 11,
                      color: ZarpaColors.primary,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userName.split(' ').first.toUpperCase(),
                    style: TextStyle(
                      fontFamily: ZarpaFonts.display,
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: ZarpaColors.foreground,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _AsphaltStats(
                    streak: streak,
                    sessions: _recentWorkouts.length,
                    minutes: totalMin,
                  ),
                  const SizedBox(height: 32),
                  _EmptyHomeState(
                    onCreateRoutine: widget.onGoToRoutines ?? () {},
                  ),
                ],
              ),
            );
          }

          final featured = routines.first;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            // El póster es oscuro en ambos modos: iconos de status bar claros.
            value: SystemUiOverlayStyle.light,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _PosterHeader(
                  routine: featured,
                  word: _displayWords[_wordIndex],
                  date: _posterDate(),
                  userName: widget.userName.split(' ').first,
                  streak: streak,
                  onTap: () => _openDetail(featured),
                  onStart: featured.exercises.isEmpty
                      ? null
                      : () => _startWorkout(featured),
                ),
                _AsphaltStats(
                  streak: streak,
                  sessions: _recentWorkouts.length,
                  minutes: totalMin,
                ),
                if (_recentWorkouts.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionTitle(label: 'ÚLTIMAS SESIONES'),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final w in _recentWorkouts.take(3))
                          _AsphaltSessionRow(
                            name: w.routineName,
                            date: w.startedAt != null
                                ? _formatDate(w.startedAt!.toDate())
                                : '',
                            minutes: w.durationMinutes ?? 0,
                          ),
                      ],
                    ),
                  ),
                ],
                if (routines.length > 1) ...[
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionTitle(label: 'MÁS RUTINAS'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      itemCount: routines.length.clamp(0, 8),
                      separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final r = routines[i];
                        return _MiniPoster(
                          routine: r,
                          onTap: () => _openDetail(r),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// === WIDGETS PRIVADOS ===

/// Cabecera póster del sistema Instinto: foto full-bleed, palabra de marca
/// gigante y CTA subrayado. Siempre oscura, en ambos modos de tema.
class _PosterHeader extends StatelessWidget {
  const _PosterHeader({
    required this.routine,
    required this.word,
    required this.date,
    required this.userName,
    required this.streak,
    required this.onTap,
    required this.onStart,
  });

  final RoutineModel routine;
  final String word;
  final String date;
  final String userName;
  final int streak;
  final VoidCallback onTap;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final height =
        (MediaQuery.sizeOf(context).height * 0.58).clamp(420.0, 560.0);
    final exCount = routine.exercises.length;
    final totalSets = routine.exercises.fold<int>(0, (sum, e) => sum + e.sets);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: ZarpaInk.black),
            Image.network(
              routineCoverUrl(routine),
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
                  stops: [0.0, 0.38, 1.0],
                  colors: [
                    ZarpaInk.veilTop,
                    ZarpaInk.veilMid,
                    ZarpaInk.veilBottom,
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ZARPAFIT',
                          style: TextStyle(
                            fontFamily: ZarpaFonts.mono,
                            fontSize: 11,
                            color: ZarpaInk.steel,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$date · ${userName.toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: ZarpaFonts.mono,
                            fontSize: 11,
                            color: ZarpaInk.steel,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: FittedBox(
                        key: ValueKey(word),
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: word,
                                style:
                                    const TextStyle(color: ZarpaColors.primary),
                              ),
                              const TextSpan(
                                text: '.',
                                style: TextStyle(color: ZarpaInk.paper),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontFamily: ZarpaFonts.display,
                            fontSize: 84,
                            fontWeight: FontWeight.w700,
                            height: 0.85,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      routine.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ZarpaInk.paper,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$exCount EJERCICIOS · $totalSets SERIES · RACHA $streak',
                      style: const TextStyle(
                        fontFamily: ZarpaFonts.mono,
                        fontSize: 11,
                        color: ZarpaInk.steel,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: onStart,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: ZarpaColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ENTRENAR AHORA',
                              style: TextStyle(
                                fontFamily: ZarpaFonts.display,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                                color: onStart == null
                                    ? ZarpaInk.steel
                                    : ZarpaColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: onStart == null
                                  ? ZarpaInk.steel
                                  : ZarpaColors.primary,
                            ),
                          ],
                        ),
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

/// Franja de métricas del sistema Asfalto: números gigantes, retícula de
/// 1px, sin tarjetas ni esquinas. Sigue el tema (light/dark).
class _AsphaltStats extends StatelessWidget {
  const _AsphaltStats({
    required this.streak,
    required this.sessions,
    required this.minutes,
  });

  final int streak;
  final int sessions;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    Widget cell(String value, String label, {bool highlight = false}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: ZarpaFonts.display,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  height: 0.95,
                  color: highlight
                      ? ZarpaColors.primary
                      : ZarpaColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: ZarpaFonts.mono,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: ZarpaColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final divider = Container(width: 1, color: ZarpaColors.border);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ZarpaColors.border),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            cell('$streak', 'RACHA', highlight: true),
            divider,
            cell('$sessions', 'SESIONES'),
            divider,
            cell('$minutes', 'MINUTOS'),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 18, height: 2, color: ZarpaColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: ZarpaFonts.mono,
            fontSize: 11,
            letterSpacing: 2,
            color: ZarpaColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Fila de sesión del sistema Asfalto: divider duro, fecha mono.
class _AsphaltSessionRow extends StatelessWidget {
  const _AsphaltSessionRow({
    required this.name,
    required this.date,
    required this.minutes,
  });

  final String name;
  final String date;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ZarpaColors.border),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ZarpaFonts.display,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ZarpaColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: ZarpaFonts.mono,
                      fontSize: 11,
                      color: ZarpaColors.muted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$minutes MIN',
              style: const TextStyle(
                fontFamily: ZarpaFonts.mono,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ZarpaColors.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 18, color: ZarpaColors.mutedLight),
          ],
        ),
      ),
    );
  }
}

/// Mini-póster de rutina: foto con veil y nombre superpuesto.
class _MiniPoster extends StatelessWidget {
  const _MiniPoster({required this.routine, required this.onTap});

  final RoutineModel routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: ZarpaInk.black),
              Image.network(
                routineCoverUrl(routine),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF2A221C)),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ZarpaInk.veilTop, ZarpaInk.veilBottom],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      routine.name.toUpperCase(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ZarpaInk.paper,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${routine.exercises.length} EJ',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState({required this.onCreateRoutine});
  final VoidCallback onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: ZarpaColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ZarpaColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 32,
              color: ZarpaColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DESPIERTA LA ZARPA',
            style: TextStyle(
              fontFamily: ZarpaFonts.display,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera rutina y empieza a entrenar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ZarpaColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreateRoutine,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('CREAR MI PRIMERA RUTINA'),
            ),
          ),
        ],
      ),
    );
  }
}
