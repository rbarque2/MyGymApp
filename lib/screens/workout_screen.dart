import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
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
  late PageController _pageController;

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

    _pageController = PageController(initialPage: 0);

    _sets = [];
    for (final ex in widget.routine.exercises) {
      for (int s = 1; s <= ex.sets; s++) {
        _sets.add(WorkoutSet(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          setNumber: s,
          reps: ex.reps,
          weightKg: ex.weightKg,
          durationSeconds: ex.durationSeconds,
          distanceMeters: ex.distanceMeters,
          measurementType: ex.measurementType,
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
    setState(() {
      _showingRest = false;
      // Sync page to current exercise after rest
      if (_pageController.hasClients &&
          _pageController.page?.round() != _currentExerciseIndex) {
        _pageController.jumpToPage(_currentExerciseIndex);
      }
    });
  }

  void _onPageChanged(int page) {
    if (page == _currentExerciseIndex) return;
    setState(() {
      _currentExerciseIndex = page;
      // Find the first incomplete set for this exercise
      int flatStart = 0;
      for (int i = 0; i < page; i++) {
        flatStart += _exercises[i].sets;
      }
      final totalSets = _exercises[page].sets;
      _currentSetInExercise = 0;
      for (int s = 0; s < totalSets; s++) {
        if (!_sets[flatStart + s].completed) {
          _currentSetInExercise = s;
          return;
        }
      }
      // All sets completed for this exercise, show last set
      _currentSetInExercise = totalSets - 1;
    });
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
    _pageController.dispose();
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
              child: _showingRest
                  ? _buildRestView()
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _exercises.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (_, index) =>
                          _buildExerciseViewForIndex(index),
                    ),
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

  Widget _buildExerciseViewForIndex(int exerciseIndex) {
    if (exerciseIndex >= _exercises.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final ex = _exercises[exerciseIndex];
    final isCurrentExercise = exerciseIndex == _currentExerciseIndex;
    final setInExercise =
        isCurrentExercise ? _currentSetInExercise : 0;

    // Find flat index for this exercise
    int flatStart = 0;
    for (int i = 0; i < exerciseIndex; i++) {
      flatStart += _exercises[i].sets;
    }
    // Find first incomplete set for non-current exercises
    int displaySet = setInExercise;
    if (!isCurrentExercise) {
      for (int s = 0; s < ex.sets; s++) {
        if (!_sets[flatStart + s].completed) {
          displaySet = s;
          break;
        }
      }
    }
    final flatIdx = flatStart + displaySet;
    if (flatIdx >= _sets.length) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentSet = _sets[flatIdx];
    final mt = currentSet.measurementType;
    final totalSets = ex.sets;

    return Column(
      children: [
        const Spacer(flex: 2),

        // Exercise GIF/photo or fallback emoji
        if (ex.photoUrl != null && ex.photoUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ex.photoUrl!,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Text(_categoryIcon(ex), style: const TextStyle(fontSize: 64)),
            ),
          )
        else
          Text(_categoryIcon(ex), style: const TextStyle(fontSize: 64)),
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

        const SizedBox(height: 24),

        // Set dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSets, (i) {
            final isCompleted = _sets[flatStart + i].completed;
            final isCurrent = i == displaySet;
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
          'Serie ${displaySet + 1} de $totalSets',
          style: const TextStyle(
            fontSize: 12,
            color: ZarpaColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),

        // Giant metric display — editable reps
        ..._buildEditableMetricDisplay(currentSet, mt),

        // Swipe hint
        const Spacer(flex: 1),
        if (_exercises.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (exerciseIndex > 0)
                  const Icon(Icons.chevron_left,
                      size: 16, color: ZarpaColors.mutedLight),
                Text(
                  '${exerciseIndex + 1} / ${_exercises.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: ZarpaColors.mutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (exerciseIndex < _exercises.length - 1)
                  const Icon(Icons.chevron_right,
                      size: 16, color: ZarpaColors.mutedLight),
              ],
            ),
          ),

        const Spacer(flex: 1),

        // Complete button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isCurrentExercise
                    ? ZarpaColors.primary
                    : ZarpaColors.muted,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isCurrentExercise
                  ? _completeCurrentSet
                  : () {
                      // Navigate to current exercise
                      _pageController.animateToPage(
                        _currentExerciseIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCurrentExercise ? Icons.check : Icons.arrow_forward,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCurrentExercise
                        ? 'SERIE COMPLETADA'
                        : 'IR AL EJERCICIO ACTUAL',
                    style: const TextStyle(
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

  Widget _stepButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ZarpaColors.surface,
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Icon(icon, size: 18, color: ZarpaColors.foreground),
      ),
    );
  }

  List<Widget> _buildEditableMetricDisplay(
      WorkoutSet set, MeasurementType mt) {
    switch (mt) {
      case MeasurementType.weight:
        // Reps (1-100) + Peso (0-300 en pasos de 2.5)
        return [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Reps picker ──
                Column(
                  children: [
                    const Text('REPS',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ZarpaColors.muted,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: set.reps - 1),
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        squeeze: 1.0,
                        selectionOverlay:
                            CupertinoPickerDefaultSelectionOverlay(
                          background:
                              ZarpaColors.primary.withOpacity(0.08),
                        ),
                        onSelectedItemChanged: (i) =>
                            setState(() => set.reps = i + 1),
                        children: List.generate(
                            100,
                            (i) => Center(
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: ZarpaColors.foreground)),
                                )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                // ── Weight picker ──
                Column(
                  children: [
                    const Text('KG',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ZarpaColors.muted,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      height: 120,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem:
                                ((set.weightKg ?? 0) / 2.5).round()),
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        squeeze: 1.0,
                        selectionOverlay:
                            CupertinoPickerDefaultSelectionOverlay(
                          background:
                              ZarpaColors.primary.withOpacity(0.08),
                        ),
                        onSelectedItemChanged: (i) =>
                            setState(() => set.weightKg = i * 2.5),
                        children: List.generate(
                            121, // 0 a 300 kg en pasos de 2.5
                            (i) => Center(
                                  child: Text(
                                      (i * 2.5) ==
                                              (i * 2.5).roundToDouble()
                                          ? '${(i * 2.5).toInt()}'
                                          : (i * 2.5).toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: ZarpaColors.foreground)),
                                )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ];
      case MeasurementType.reps:
        // Solo reps sin peso
        return [
          SizedBox(
            height: 140,
            child: Column(
              children: [
                const Text('REPETICIONES',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ZarpaColors.muted,
                        letterSpacing: 2)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 100,
                  height: 120,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: set.reps - 1),
                    itemExtent: 40,
                    diameterRatio: 1.2,
                    squeeze: 1.0,
                    selectionOverlay:
                        CupertinoPickerDefaultSelectionOverlay(
                      background: ZarpaColors.primary.withOpacity(0.08),
                    ),
                    onSelectedItemChanged: (i) =>
                        setState(() => set.reps = i + 1),
                    children: List.generate(
                        100,
                        (i) => Center(
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: ZarpaColors.foreground)),
                            )),
                  ),
                ),
              ],
            ),
          ),
        ];
      case MeasurementType.time:
        final secs = set.durationSeconds ?? 30;
        final m = secs ~/ 60;
        final s = secs % 60;
        return [
          Text(
            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: ZarpaColors.foreground,
              height: 1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Text(
            'DURACIÓN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.muted,
              letterSpacing: 2,
            ),
          ),
        ];
      case MeasurementType.distance:
        final meters = set.distanceMeters ?? 0;
        final display = meters >= 1000
            ? '${(meters / 1000).toStringAsFixed(1)} km'
            : '${meters.toStringAsFixed(0)} m';
        return [
          Text(
            display,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: ZarpaColors.foreground,
              height: 1,
            ),
          ),
          const Text(
            'DISTANCIA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.muted,
              letterSpacing: 2,
            ),
          ),
        ];
    }
  }

  String _categoryIcon(RoutineExercise ex) {
    // Try to match the exercise's measurement type to a category icon
    switch (ex.measurementType) {
      case MeasurementType.time:
        return '⏱️';
      case MeasurementType.distance:
        return '🏃';
      case MeasurementType.reps:
        return '💪';
      case MeasurementType.weight:
        return '🏋️';
    }
  }

  String _nextUpDetail() {
    final ex = _currentExercise;
    switch (ex.measurementType) {
      case MeasurementType.weight:
        final w = ex.weightKg != null ? ' · ${ex.weightKg} kg' : '';
        return '${ex.reps} reps$w';
      case MeasurementType.reps:
        return '${ex.reps} reps';
      case MeasurementType.time:
        final secs = ex.durationSeconds ?? 30;
        return '${secs}s';
      case MeasurementType.distance:
        final m = ex.distanceMeters ?? 0;
        return m >= 1000
            ? '${(m / 1000).toStringAsFixed(1)} km'
            : '${m.toStringAsFixed(0)} m';
    }
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
                        'Serie ${_currentSetInExercise + 1} · ${_nextUpDetail()}',
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
