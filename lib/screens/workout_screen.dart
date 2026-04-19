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
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
  late Set<int> _weightEnabledExercises;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

    // Determinar qué ejercicios tienen peso activado por defecto
    _weightEnabledExercises = {};
    for (int i = 0; i < _exercises.length; i++) {
      final ex = _exercises[i];
      if (ex.measurementType == MeasurementType.weight ||
          (ex.weightKg != null && ex.weightKg! > 0)) {
        _weightEnabledExercises.add(i);
      }
    }
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

    bool advancedExercise = false;

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
        advancedExercise = true;
      }
    });

    // Si avanzamos de ejercicio, animar el PageView al nuevo ejercicio
    // para que al cerrar el descanso se vea el ejercicio correcto.
    if (advancedExercise) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        _pageController.animateToPage(
          _currentExerciseIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _skipRest() {
    _timer.stop();
    setState(() {
      _showingRest = false;
    });
    // Asegurar que el PageView muestra el ejercicio actual tras cerrar descanso.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      if (_pageController.page?.round() != _currentExerciseIndex) {
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
    final choice = await showDialog<_QuitChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del entrenamiento?'),
        content: const Text(
          '¿Qué quieres hacer con esta sesión?',
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _QuitChoice.cancel),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: ZarpaColors.error),
            onPressed: () => Navigator.pop(ctx, _QuitChoice.discard),
            child: const Text('Descartar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _QuitChoice.save),
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
    if (choice == null || choice == _QuitChoice.cancel) return;
    if (choice == _QuitChoice.discard) {
      await _discardWorkout();
    } else {
      await _finishWorkout();
    }
  }

  Future<void> _discardWorkout() async {
    _timer.stop();
    final id = _workoutId;
    if (id != null) {
      try {
        await widget.workoutsRepository.deleteWorkout(id);
      } catch (_) {
        // Si falla, al menos salimos sin guardar cambios.
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Al volver del background, recomputar el tiempo real restante.
      _timer.refresh();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

            // Main content — PageView siempre montado para preservar su estado;
            // la vista de descanso se superpone cuando está activa.
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _exercises.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, index) =>
                        _buildExerciseViewForIndex(index),
                  ),
                  if (_showingRest)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                        child: _buildRestView(),
                      ),
                    ),
                ],
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
        // Cuerpo scrollable: cabecera + pickers + lista de series
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Column(
              children: [
                // Exercise GIF/photo or fallback emoji
                if (ex.photoUrl != null && ex.photoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ex.photoUrl!,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(_categoryIcon(ex),
                          style: const TextStyle(fontSize: 56)),
                    ),
                  )
                else
                  Text(_categoryIcon(ex),
                      style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),

                // Exercise name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    ex.exerciseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Serie ${displaySet + 1} de $totalSets',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZarpaColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Giant metric display — editable reps
                ..._buildEditableMetricDisplay(currentSet, mt, exerciseIndex),

                const SizedBox(height: 20),
                // Lista vertical de todas las series del ejercicio
                _buildAllSetsList(exerciseIndex, flatStart, displaySet),

                if (_exercises.length > 1) ...[
                  const SizedBox(height: 16),
                  Row(
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
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

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

  Widget _restAdjustButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ZarpaColors.foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ZarpaColors.foreground,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
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
      WorkoutSet set, MeasurementType mt, int exerciseIndex) {
    final showWeight = _weightEnabledExercises.contains(exerciseIndex);

    // ── Picker principal según tipo ──
    Widget mainPicker;
    switch (mt) {
      case MeasurementType.weight:
      case MeasurementType.reps:
        mainPicker = Column(
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
                scrollController:
                    FixedExtentScrollController(initialItem: set.reps - 1),
                itemExtent: 40,
                diameterRatio: 1.2,
                squeeze: 1.0,
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: ZarpaColors.primary.withOpacity(0.08),
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
        );
      case MeasurementType.time:
        final secs = set.durationSeconds ?? 30;
        mainPicker = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                const Text('MIN',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ZarpaColors.muted,
                        letterSpacing: 2)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  height: 120,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: secs ~/ 60),
                    itemExtent: 40,
                    diameterRatio: 1.2,
                    squeeze: 1.0,
                    selectionOverlay:
                        CupertinoPickerDefaultSelectionOverlay(
                      background: ZarpaColors.primary.withOpacity(0.08),
                    ),
                    onSelectedItemChanged: (i) {
                      final curS = (set.durationSeconds ?? 30) % 60;
                      setState(() => set.durationSeconds = i * 60 + curS);
                    },
                    children: List.generate(
                        61,
                        (i) => Center(
                              child: Text('$i',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: ZarpaColors.foreground)),
                            )),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(':',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: ZarpaColors.foreground)),
            ),
            Column(
              children: [
                const Text('SEG',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ZarpaColors.muted,
                        letterSpacing: 2)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  height: 120,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: secs % 60),
                    itemExtent: 40,
                    diameterRatio: 1.2,
                    squeeze: 1.0,
                    selectionOverlay:
                        CupertinoPickerDefaultSelectionOverlay(
                      background: ZarpaColors.primary.withOpacity(0.08),
                    ),
                    onSelectedItemChanged: (i) {
                      final curM = (set.durationSeconds ?? 30) ~/ 60;
                      setState(() => set.durationSeconds = curM * 60 + i);
                    },
                    children: List.generate(
                        60,
                        (i) => Center(
                              child: Text(i.toString().padLeft(2, '0'),
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
        );
      case MeasurementType.distance:
        mainPicker = Column(
          children: [
            const Text('METROS',
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
                    initialItem: ((set.distanceMeters ?? 0) / 100).round()),
                itemExtent: 40,
                diameterRatio: 1.2,
                squeeze: 1.0,
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: ZarpaColors.primary.withOpacity(0.08),
                ),
                onSelectedItemChanged: (i) =>
                    setState(() => set.distanceMeters = i * 100.0),
                children: List.generate(
                    201, // 0 a 20000 m en pasos de 100
                    (i) {
                  final m = i * 100;
                  final label =
                      m >= 1000 ? '${(m / 1000).toStringAsFixed(1)}k' : '$m';
                  return Center(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: ZarpaColors.foreground)),
                  );
                }),
              ),
            ),
          ],
        );
    }

    // ── Weight picker (si está activo) ──
    Widget weightPicker = Column(
      children: [
        const Text('KG',
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
                initialItem: ((set.weightKg ?? 0) / 2.5).round()),
            itemExtent: 40,
            diameterRatio: 1.2,
            squeeze: 1.0,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
              background: ZarpaColors.primary.withOpacity(0.08),
            ),
            onSelectedItemChanged: (i) =>
                setState(() => set.weightKg = i * 2.5),
            children: List.generate(
                121,
                (i) => Center(
                      child: Text(
                          (i * 2.5) == (i * 2.5).roundToDouble()
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
    );

    return [
      SizedBox(
        height: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mainPicker,
            if (showWeight) ...[
              const SizedBox(width: 24),
              weightPicker,
            ],
          ],
        ),
      ),
      const SizedBox(height: 8),
      // ── Toggle peso ──
      GestureDetector(
        onTap: () => setState(() {
          if (showWeight) {
            _weightEnabledExercises.remove(exerciseIndex);
            // Limpiar peso de todas las series de este ejercicio
            final flatStart = _flatIndexForExercise(exerciseIndex);
            for (int i = 0; i < _exercises[exerciseIndex].sets; i++) {
              _sets[flatStart + i].weightKg = null;
            }
          } else {
            _weightEnabledExercises.add(exerciseIndex);
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: showWeight
                ? ZarpaColors.primary.withOpacity(0.1)
                : ZarpaColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: showWeight
                  ? ZarpaColors.primary.withOpacity(0.3)
                  : ZarpaColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showWeight
                    ? Icons.fitness_center
                    : Icons.fitness_center_outlined,
                size: 16,
                color: showWeight ? ZarpaColors.primary : ZarpaColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                showWeight ? 'Con peso' : 'Añadir peso',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      showWeight ? ZarpaColors.primary : ZarpaColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildAllSetsList(int exerciseIndex, int flatStart, int displaySet) {
    final totalSets = _exercises[exerciseIndex].sets;
    final isCurrentExercise = exerciseIndex == _currentExerciseIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Row(
              children: const [
                Text(
                  'SERIES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: ZarpaColors.muted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(totalSets, (i) {
            final s = _sets[flatStart + i];
            final isCompleted = s.completed;
            final isCurrent = isCurrentExercise && i == displaySet;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSetRow(
                index: i,
                set: s,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                onTap: isCurrentExercise && !isCompleted
                    ? () => setState(() => _currentSetInExercise = i)
                    : null,
                onCheckTap: isCurrentExercise
                    ? () => _toggleSetCompletion(flatStart + i)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSetRow({
    required int index,
    required WorkoutSet set,
    required bool isCompleted,
    required bool isCurrent,
    required VoidCallback? onTap,
    required VoidCallback? onCheckTap,
  }) {
    final bg = isCompleted
        ? const Color(0xFFDFFFDB) // verde claro estilo Hevy
        : isCurrent
            ? ZarpaColors.primary.withOpacity(0.08)
            : ZarpaColors.surface;
    final border = isCurrent && !isCompleted
        ? ZarpaColors.primary
        : ZarpaColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            // Número de serie
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF2E7D32)
                    : ZarpaColors.surface2,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isCompleted ? Colors.white : ZarpaColors.foreground,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Resumen kg × reps
            Expanded(
              child: Text(
                _setSummary(set),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? const Color(0xFF1B5E20)
                      : ZarpaColors.foreground,
                ),
              ),
            ),
            // Check
            GestureDetector(
              onTap: onCheckTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF2E7D32)
                        : ZarpaColors.border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: isCompleted ? Colors.white : ZarpaColors.mutedLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSetCompletion(int flatIdx) {
    if (flatIdx < 0 || flatIdx >= _sets.length) return;
    final set = _sets[flatIdx];
    if (set.completed) {
      // Desmarcar no reinicia el timer ni cambia índice — sólo cambia estado.
      setState(() => set.completed = false);
      return;
    }
    // Marcar esta serie como completada. Si es la actual, reutilizar el flujo
    // completo (que inicia descanso y avanza). Si no, sólo marcar.
    if (flatIdx == _currentFlatIndex) {
      _completeCurrentSet();
    } else {
      setState(() => set.completed = true);
    }
  }

  String _setSummary(WorkoutSet s) {
    String fmtKg(double w) =>
        w == w.roundToDouble() ? '${w.toInt()}' : w.toStringAsFixed(1);
    switch (s.measurementType) {
      case MeasurementType.weight:
        final w = s.weightKg ?? 0;
        return w > 0 ? '${s.reps}×${fmtKg(w)}kg' : '${s.reps} reps';
      case MeasurementType.reps:
        final w = s.weightKg ?? 0;
        return w > 0 ? '${s.reps}×${fmtKg(w)}kg' : '${s.reps} reps';
      case MeasurementType.time:
        final secs = s.durationSeconds ?? 0;
        final m = secs ~/ 60;
        final sc = secs % 60;
        return m > 0
            ? '$m:${sc.toString().padLeft(2, '0')}'
            : '${secs}s';
      case MeasurementType.distance:
        final m = s.distanceMeters ?? 0;
        return m >= 1000
            ? '${(m / 1000).toStringAsFixed(1)}km'
            : '${m.toStringAsFixed(0)}m';
    }
  }

  int _flatIndexForExercise(int exerciseIndex) {
    int idx = 0;
    for (int i = 0; i < exerciseIndex; i++) {
      idx += _exercises[i].sets;
    }
    return idx;
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

        const SizedBox(height: 16),

        // ± 10s controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _restAdjustButton(
              label: '-10s',
              icon: Icons.remove,
              onTap: () => _timer.adjustSeconds(-10),
            ),
            const SizedBox(width: 12),
            _restAdjustButton(
              label: '+10s',
              icon: Icons.add,
              onTap: () => _timer.adjustSeconds(10),
            ),
          ],
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

enum _QuitChoice { cancel, discard, save }
