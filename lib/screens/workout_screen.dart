import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/routine_model.dart';
import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';
import '../services/beep_service.dart';
import '../services/settings_service.dart';
import '../services/timer_service.dart';

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

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final List<WorkoutSet> _sets;
  late final TimerService _timer;
  late final BeepService _beep;
  late final DateTime _startTime;
  String? _workoutId;

  @override
  void initState() {
    super.initState();
    _timer = TimerService();
    _beep = BeepService();
    _startTime = DateTime.now();

    // Generar todas las series a partir de la rutina.
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

    // Crear documento del workout en Firestore.
    _createSession();

    _timer.addListener(_onTimerTick);
  }

  void _onTimerTick() {
    if (mounted) {
      setState(() {});

      // Reproducir beeps en la cuenta atrás
      final settings = widget.settingsService;
      if (settings.countdownSoundEnabled && _timer.isRunning) {
        final remaining = _timer.remainingSeconds;
        if (remaining > 0 && remaining <= settings.countdownBeepFrom) {
          _beep.playShortBeep();
        } else if (remaining == 0) {
          _beep.playLongBeep();
        }
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

  void _toggleSet(int index) {
    setState(() {
      _sets[index].completed = !_sets[index].completed;

      // Si se completó, iniciar temporizador de descanso.
      if (_sets[index].completed) {
        final routineEx = widget.routine.exercises.firstWhere(
          (e) => e.exerciseId == _sets[index].exerciseId,
        );
        // Usar el descanso de la rutina o el predeterminado de settings
        final restSeconds = routineEx.restSeconds > 0
            ? routineEx.restSeconds
            : widget.settingsService.defaultRestSeconds;
        _timer.start(restSeconds);
      }
    });
  }

  void _updateWeight(int index, String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    _sets[index].weightKg = parsed;
  }

  void _updateReps(int index, String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) _sets[index].reps = parsed;
  }

  void _showTimerPicker() {
    int seconds = widget.settingsService.defaultRestSeconds;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String fmt(int s) {
            final m = s ~/ 60;
            final r = s % 60;
            return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
          }

          return AlertDialog(
            title: const Text('Iniciar descanso'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: seconds > 5
                          ? () => setDialogState(() => seconds -= 5)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmt(seconds),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: seconds < 600
                          ? () => setDialogState(() => seconds += 5)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [30, 45, 60, 90, 120, 180].map((s) {
                    return ActionChip(
                      label: Text(fmt(s)),
                      onPressed: () => setDialogState(() => seconds = s),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _timer.start(seconds);
                },
                child: const Text('Iniciar'),
              ),
            ],
          );
        },
      ),
    );
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

    final completedSets = _sets.where((s) => s.completed).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Entrenamiento completado! $completedSets/${_sets.length} series · $duration min',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerTick);
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _sets.where((s) => s.completed).length;
    final progress =
        _sets.isEmpty ? 0.0 : completedCount / _sets.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
        actions: [
          TextButton.icon(
            onPressed: _finishWorkout,
            icon: const Icon(Icons.check),
            label: const Text('Terminar'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso y temporizador.
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completedCount / ${_sets.length} series',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Temporizador de descanso.
                GestureDetector(
                  onTap: () {
                    if (_timer.isRunning) {
                      _timer.stop();
                    } else {
                      _showTimerPicker();
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _timer.isRunning
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _timer.isRunning ? Icons.timer : Icons.timer_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timer.display,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: [
                                      const FontFeature.tabularFigures()
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de series.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _sets.length,
              itemBuilder: (context, index) {
                final s = _sets[index];
                // Mostrar cabecera de ejercicio.
                final showHeader = index == 0 ||
                    _sets[index - 1].exerciseId != s.exerciseId;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) ...[
                      if (index != 0) const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          s.exerciseName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    Card(
                      color: s.completed
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.5)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                'S${s.setNumber}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                initialValue: s.weightKg?.toString() ?? '',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'kg',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => _updateWeight(index, v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: TextFormField(
                                initialValue: s.reps.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'reps',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => _updateReps(index, v),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                s.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: s.completed ? Colors.green : null,
                                size: 32,
                              ),
                              onPressed: () => _toggleSet(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
