import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';
import '../services/beep_service.dart';
import '../services/notification_service.dart';
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

  /// Total del descanso en curso, para el anillo del HUD (remaining/total).
  int _restTotalSeconds = 1;

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
      _restTotalSeconds = restSeconds;
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
      // Al volver del background, recomputar el tiempo real restante y
      // cancelar el aviso programado: el beep en-app vuelve a encargarse.
      NotificationService.instance.cancelRestEnd();
      _timer.refresh();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.paused) {
      // App en segundo plano con descanso en marcha: avisar cuando acabe,
      // aunque la pantalla esté bloqueada.
      if (_timer.isRunning && _timer.remainingSeconds > 0) {
        NotificationService.instance.scheduleRestEnd(
          Duration(seconds: _timer.remainingSeconds, milliseconds: 500),
        );
      }
    }
  }

  @override
  void dispose() {
    NotificationService.instance.cancelRestEnd();
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
      backgroundColor: ZarpaColors.background,
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
                        // El descanso es cabina: siempre oscuro, en ambos temas.
                        color: ZarpaInk.black,
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ZarpaColors.border),
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
                    border: Border.all(color: ZarpaColors.border),
                    borderRadius: BorderRadius.circular(2),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: ZarpaColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_completedCount.toString().padLeft(2, '0')}/${_sets.length.toString().padLeft(2, '0')} SERIES',
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
              // Elapsed time
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: ZarpaColors.border),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  _formatElapsed(),
                  style: TextStyle(
                    fontFamily: ZarpaFonts.mono,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ZarpaColors.foreground,
                    letterSpacing: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progreso segmentado: un bloque por serie (telemetría).
          if (_sets.length <= 40)
            Row(
              children: [
                for (int i = 0; i < _sets.length; i++)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(
                          right: i == _sets.length - 1 ? 0 : 2),
                      color: i < _completedCount
                          ? ZarpaColors.primary
                          : ZarpaColors.surface2,
                    ),
                  ),
              ],
            )
          else
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: ZarpaColors.surface2,
              valueColor: const AlwaysStoppedAnimation(ZarpaColors.primary),
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
                      errorBuilder: (_, __, ___) => Icon(
                          _categoryIconData(ex),
                          size: 56,
                          color: ZarpaColors.primary),
                    ),
                  )
                else
                  Icon(_categoryIconData(ex),
                      size: 56, color: ZarpaColors.primary),
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
                  style: TextStyle(
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
                        Icon(Icons.chevron_left,
                            size: 16, color: ZarpaColors.mutedLight),
                      Text(
                        '${exerciseIndex + 1} / ${_exercises.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ZarpaColors.mutedLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (exerciseIndex < _exercises.length - 1)
                        Icon(Icons.chevron_right,
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
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
                      fontFamily: ZarpaFonts.display,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: ZarpaFonts.mono,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ZarpaInk.paper,
            letterSpacing: 1.5,
          ),
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
            Text('REPS',
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
                              style: TextStyle(
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
                Text('MIN',
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
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: ZarpaColors.foreground)),
                            )),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(':',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: ZarpaColors.foreground)),
            ),
            Column(
              children: [
                Text('SEG',
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
                                  style: TextStyle(
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
            Text('METROS',
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
                        style: TextStyle(
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
        Text('KG',
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
                          style: TextStyle(
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
              children: [
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
        ? ZarpaColors.success.withOpacity(0.15)
        : isCurrent
            ? ZarpaColors.primary.withOpacity(0.12)
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
                    ? ZarpaColors.success
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
                      ? ZarpaColors.success
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
                      ? ZarpaColors.success
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? ZarpaColors.success
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

  IconData _categoryIconData(RoutineExercise ex) {
    switch (ex.measurementType) {
      case MeasurementType.time:
        return Icons.timer_outlined;
      case MeasurementType.distance:
        return Icons.directions_run;
      case MeasurementType.reps:
        return Icons.fitness_center;
      case MeasurementType.weight:
        return Icons.fitness_center;
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
    final ringProgress = _restTotalSeconds <= 0
        ? 0.0
        : (_timer.remainingSeconds / _restTotalSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        const Spacer(flex: 2),

        const Text(
          'DESCANSO',
          style: TextStyle(
            fontFamily: ZarpaFonts.mono,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ZarpaInk.steel,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),

        // Anillo de telemetría con countdown gigante.
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.02),
              child: child,
            );
          },
          child: SizedBox(
            width: 230,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RestRingPainter(progress: ringProgress),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timer.display,
                      style: const TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: ZarpaInk.paper,
                        height: 1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'RESTANTES',
                      style: TextStyle(
                        fontFamily: ZarpaFonts.mono,
                        fontSize: 10,
                        color: ZarpaInk.steel,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ± 10s controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _restAdjustButton(
              label: '-10S',
              onTap: () => _timer.adjustSeconds(-10),
            ),
            const SizedBox(width: 10),
            _restAdjustButton(
              label: '+10S',
              onTap: () => _timer.adjustSeconds(10),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Next up info
        if (_currentExerciseIndex < _exercises.length)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SIGUIENTE BLOQUE',
                        style: TextStyle(
                          fontFamily: ZarpaFonts.mono,
                          fontSize: 9,
                          color: ZarpaInk.steel,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currentExercise.exerciseName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: ZarpaFonts.display,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: ZarpaInk.paper,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SERIE ${_currentSetInExercise + 1} · ${_nextUpDetail().toUpperCase()}',
                        style: const TextStyle(
                          fontFamily: ZarpaFonts.mono,
                          fontSize: 11,
                          color: ZarpaColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_arrow,
                    size: 22, color: ZarpaColors.primary),
              ],
            ),
          ),

        const Spacer(flex: 3),

        // Skip rest
        Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: InkWell(
            onTap: _skipRest,
            child: Container(
              padding: const EdgeInsets.only(bottom: 5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ZarpaInk.steel, width: 2),
                ),
              ),
              child: const Text(
                'SALTAR DESCANSO',
                style: TextStyle(
                  fontFamily: ZarpaFonts.display,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: ZarpaInk.paper,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Anillo de descanso del HUD: track oscuro + arco naranja (remaining/total).
class _RestRingPainter extends CustomPainter {
  _RestRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFF222222);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt
      ..color = ZarpaColors.primary;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RestRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

enum _QuitChoice { cancel, discard, save }
