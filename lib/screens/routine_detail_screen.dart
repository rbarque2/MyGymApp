import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/routine_model.dart';
import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';
import '../widgets/routine_cover.dart';
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
      body: CustomScrollView(
        slivers: [
          // Header póster con foto de portada.
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: ZarpaInk.black,
            foregroundColor: ZarpaInk.paper,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editRoutine(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
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
                        stops: [0.0, 0.4, 1.0],
                        colors: [
                          ZarpaInk.veilTop,
                          ZarpaInk.veilMid,
                          ZarpaInk.veilBottom,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          color: ZarpaColors.primary,
                          child: const Text(
                            'RUTINA',
                            style: TextStyle(
                              fontFamily: ZarpaFonts.mono,
                              color: ZarpaInk.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          routine.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: ZarpaFonts.display,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: ZarpaInk.paper,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${routine.exercises.length} EJERCICIOS · $totalSets SERIES',
                          style: const TextStyle(
                            fontFamily: ZarpaFonts.mono,
                            fontSize: 11,
                            color: ZarpaInk.steel,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (routine.description != null) ...[
                  Text(
                    routine.description!,
                    style: TextStyle(
                      fontFamily: ZarpaFonts.body,
                      fontSize: 15,
                      color: ZarpaColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const _SectionTitle(label: 'EJERCICIOS'),
                const SizedBox(height: 6),
                if (routine.exercises.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
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
                  ...List.generate(
                    routine.exercises.length,
                    (i) => _ExerciseRow(
                      index: i,
                      exercise: routine.exercises[i],
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),

      // Bottom button
      bottomSheet: routine.exercises.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: BoxDecoration(
                color: ZarpaColors.background,
                border: Border(
                  top: BorderSide(color: ZarpaColors.border),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ZarpaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
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
                          fontFamily: ZarpaFonts.display,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
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

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.exercise});
  final int index;
  final RoutineExercise exercise;

  @override
  Widget build(BuildContext context) {
    final restStr = exercise.restSeconds > 0
        ? ' · ${exercise.restSeconds}S DESC'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ZarpaColors.border)),
      ),
      child: Row(
        children: [
          Text(
            (index + 1).toString().padLeft(2, '0'),
            style: TextStyle(
              fontFamily: ZarpaFonts.display,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName.toUpperCase(),
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
                  '${exercise.sets} × ${exercise.reps} REPS$restStr',
                  style: const TextStyle(
                    fontFamily: ZarpaFonts.mono,
                    fontSize: 10,
                    color: ZarpaColors.primary,
                    letterSpacing: 0.5,
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
