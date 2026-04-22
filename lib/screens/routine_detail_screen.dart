import 'package:flutter/material.dart';

import '../models/routine_model.dart';
import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';
import 'routine_editor_screen.dart';
import 'workout_screen.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({
    super.key,
    required this.ownerUid,
    required this.routine,
    required this.routinesRepository,
    required this.exercisesRepository,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final String ownerUid;
  final RoutineModel routine;
  final RoutinesRepository routinesRepository;
  final ExercisesRepository exercisesRepository;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  void _startWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          ownerUid: ownerUid,
          routine: routine,
          workoutsRepository: workoutsRepository,
          settingsService: settingsService,
        ),
      ),
    );
  }

  void _editRoutine(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          ownerUid: ownerUid,
          routinesRepository: routinesRepository,
          exercisesRepository: exercisesRepository,
          existing: routine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSets =
        routine.exercises.fold<int>(0, (sum, e) => sum + e.sets);

    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ZarpaColors.border),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ZarpaColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_left, size: 24),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'RUTINA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ZarpaColors.muted,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _editRoutine(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ZarpaColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ZarpaColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(
                      left: BorderSide(color: ZarpaColors.primary, width: 4),
                      top: BorderSide(color: ZarpaColors.border),
                      right: BorderSide(color: ZarpaColors.border),
                      bottom: BorderSide(color: ZarpaColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ZarpaColors.primary,
                          borderRadius: BorderRadius.circular(4),
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
                      const SizedBox(height: 12),
                      const Icon(Icons.fitness_center,
                          size: 40, color: ZarpaColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        routine.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (routine.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          routine.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ZarpaColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      // Meta chips
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.fitness_center,
                            label:
                                '${routine.exercises.length} ejercicios',
                          ),
                          const SizedBox(width: 8),
                          _MetaChip(
                            icon: Icons.repeat,
                            label: '$totalSets series',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Section title
                const Text(
                  'EJERCICIOS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ZarpaColors.muted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Exercise list
                if (routine.exercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Sin ejercicios. Edita la rutina para añadirlos.',
                        style: TextStyle(
                          fontSize: 14,
                          color: ZarpaColors.muted,
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(routine.exercises.length, (i) {
                    return _ExerciseRow(
                      index: i,
                      exercise: routine.exercises[i],
                    );
                  }),
              ],
            ),
          ),
        ],
      ),

      // Bottom button
      bottomSheet: routine.exercises.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: BoxDecoration(
                color: ZarpaColors.surface,
                border: Border(
                  top: BorderSide(color: ZarpaColors.border),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ZarpaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _startWorkout(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 20, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'INICIAR ENTRENAMIENTO',
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
            )
          : null,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ZarpaColors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ZarpaColors.mutedLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: ZarpaColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.exercise});
  final int index;
  final RoutineExercise exercise;

  @override
  Widget build(BuildContext context) {
    final restStr = exercise.restSeconds > 0
        ? ' · ${exercise.restSeconds}s descanso'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZarpaColors.border),
      ),
      child: Row(
        children: [
          // Number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ZarpaColors.surface2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ZarpaColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.sets} series × ${exercise.reps} reps$restStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: ZarpaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
