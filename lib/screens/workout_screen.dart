import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/routine_model.dart';
import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';
import '../services/beep_service.dart';
import '../services/settings_service.dart';
import '../services/timer_service.dart';
import '../theme/zarpafit_theme.dart';
import 'workout_completion_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    super.key,
    required this.ownerUid,
    required this.routine,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final String ownerUid;
  final RoutineModel routine;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  late final List<WorkoutSet> _sets;
  late final TimerService _timer;
  late final BeepService _beep;
  late final DateTime _startTime;
  String? _workoutId;

  // Current exercise tracking — grouped by exercise
  int _currentExerciseIndex = 0;
  int _currentSetInExercise = 0;
  bool _showingRest = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _timer = TimerService();
    _beep = BeepService();
    _startTime = DateTime.now();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _sets = [];
    for (final ex in widget.routine.exercises) {
      for (int s = 1; s <= ex.sets; s++) {
        _sets.add(WorkoutSet(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          setNumber: s,
          reps: ex.reps,
          weightKg: ex.weightKg,
        ));
      }
    }

    _createSession();
    _timer.addListener(_onTimerTick);
  }

  // Get the exercises from the routine
  List<RoutineExercise> get _exercises => widget.routine.exercises;

  RoutineExercise get _currentExercise => _exercises[_currentExerciseIndex];

  int get _totalSetsForCurrentExercise => _currentExercise.sets;

  // Get the flat index in _sets for the current exercise & set
  int get _currentFlatIndex {
    int idx = 0;
    for (int i = 0; i < _currentExerciseIndex; i++) {
      idx += _exercises[i].sets;
    }
    return idx + _currentSetInExercise;
  }

  int get _completedCount => _sets.where((s) => s.completed).length;

  void _onTimerTick() {
    if (mounted) {
      setState(() {});

      final settings = widget.settingsService;
      if (settings.countdownSoundEnabled && _timer.isRunning) {
        final remaining = _timer.remainingSeconds;
        if (remaining > 0 && remaining <= settings.countdownBeepFrom) {
          _beep.playShortBeep();
        } else if (remaining == 0) {
          _beep.playRoar();
        }
      }

      // When rest timer finishes, go back to exercise view
      if (!_timer.isRunning && _showingRest) {
        setState(() => _showingRest = false);
      }
    }
  }

  Future<void> _createSession() async {
    final session = WorkoutSessionModel(
      id: '',
      ownerUid: widget.ownerUid,
      routineId: widget.routine.id,
      routineName: widget.routine.name,
      sets: _sets,
      startedAt: Timestamp.now(),
    );
    final ref = await widget.workoutsRepository.createWorkout(session);
    _workoutId = ref.id;
  }

  void _completeCurrentSet() {
    final flatIdx = _currentFlatIndex;
    if (flatIdx >= _sets.length) return;

    setState(() {
      _sets[flatIdx].completed = true;

      // Check if this was the last set of the last exercise
      final isLastExercise = _currentExerciseIndex == _exercises.length - 1;
      final isLastSet =
          _currentSetInExercise == _totalSetsForCurrentExercise - 1;

      if (isLastExercise && isLastSet) {
        // Workout complete!
        _finishWorkout();
        return;
      }

      // Start rest timer
      final restSeconds = _currentExercise.restSeconds > 0
          ? _currentExercise.restSeconds
          : widget.settingsService.defaultRestSeconds;
      _timer.start(restSeconds);
      _showingRest = true;

      // Advance to next set or exercise
      if (_currentSetInExercise < _totalSetsForCurrentExercise - 1) {
        _currentSetInExercise++;
      } else {
        _currentExerciseIndex++;
        _currentSetInExercise = 0;
      }
    });
  }

  void _skipRest() {
    _timer.stop();
    setState(() => _showingRest = false);
  }

  Future<void> _finishWorkout() async {
    if (_workoutId == null) return;

    final duration = DateTime.now().difference(_startTime).inMinutes;

    await widget.workoutsRepository.finishWorkout(
      _workoutId!,
      sets: _sets,
      durationMinutes: duration,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutCompletionScreen(
          routineName: widget.routine.name,
          completedSets: _completedCount,
          totalSets: _sets.length,
          durationMinutes: duration,
          exerciseCount: _exercises.length,
        ),
      ),
    );
  }

  Future<void> _confirmQuit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del entrenamiento?'),
        content: const Text(
          'Se guardará tu progreso hasta ahora.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ZarpaColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _finishWorkout();
    }
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerTick);
    _timer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _sets.isEmpty ? 0.0 : _completedCount / _sets.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            _buildHeader(progress),

            // Main content
            Expanded(
              child: _showingRest ? _buildRestView() : _buildExerciseView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ZarpaColors.surface2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _confirmQuit,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ZarpaColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.routine.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: ZarpaColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_completedCount}/${_sets.length} series',
                      style: const TextStyle(
                        fontSize: 11,
                        color: ZarpaColors.mutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Elapsed time
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ZarpaColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: ZarpaColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      _formatElapsed(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: ZarpaColors.surface2,
              valueColor:
                  const AlwaysStoppedAnimation(ZarpaColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatElapsed() {
    final elapsed = DateTime.now().difference(_startTime);
    final m = elapsed.inMinutes;
    final s = elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildExerciseView() {
    if (_currentExerciseIndex >= _exercises.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final ex = _currentExercise;
    final currentSet = _sets[_currentFlatIndex];

    return Column(
      children: [
        const Spacer(flex: 2),

        // Emoji
        const Text('💪', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),

        // Exercise name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            ex.exerciseName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Weight info
        if (currentSet.weightKg != null && currentSet.weightKg! > 0)
          Text(
            '${currentSet.weightKg} kg',
            style: const TextStyle(
              fontSize: 16,
              color: ZarpaColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 24),

        // Set dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalSetsForCurrentExercise, (i) {
            final isCompleted = i < _currentSetInExercise ||
                (i <= _currentSetInExercise &&
                    _sets[_currentFlatIndex - _currentSetInExercise + i]
                        .completed);
            final isCurrent = i == _currentSetInExercise;
            return Container(
              width: isCurrent ? 14 : 10,
              height: isCurrent ? 14 : 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? ZarpaColors.primary
                    : isCurrent
                        ? ZarpaColors.primary.withOpacity(0.4)
                        : ZarpaColors.surface2,
                border: isCurrent
                    ? Border.all(color: ZarpaColors.primary, width: 2)
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Serie ${_currentSetInExercise + 1} de $_totalSetsForCurrentExercise',
          style: const TextStyle(
            fontSize: 12,
            color: ZarpaColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),

        // Giant reps number
        Text(
          '${currentSet.reps}',
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: ZarpaColors.foreground,
            height: 1,
          ),
        ),
        const Text(
          'REPETICIONES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ZarpaColors.muted,
            letterSpacing: 2,
          ),
        ),

        const Spacer(flex: 3),

        // Complete button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ZarpaColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _completeCurrentSet,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'SERIE COMPLETADA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestView() {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Rest icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ZarpaColors.primary.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.hourglass_bottom,
            size: 40,
            color: ZarpaColors.primary,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'DESCANSO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ZarpaColors.muted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),

        // Giant timer
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.05),
              child: Text(
                _timer.display,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: ZarpaColors.primary,
                  height: 1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${_timer.remainingSeconds}s restantes',
          style: const TextStyle(
            fontSize: 14,
            color: ZarpaColors.muted,
          ),
        ),

        const SizedBox(height: 24),

        // Next up info
        if (_currentExerciseIndex < _exercises.length)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZarpaColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ZarpaColors.border),
            ),
            child: Row(
              children: [
                const Text('💪', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SIGUIENTE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ZarpaColors.muted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        _currentExercise.exerciseName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Serie ${_currentSetInExercise + 1} · ${_currentExercise.reps} reps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZarpaColors.primary,
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

        // Skip rest button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: ZarpaColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _skipRest,
              child: const Text(
                'SALTAR DESCANSO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: ZarpaColors.foreground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
