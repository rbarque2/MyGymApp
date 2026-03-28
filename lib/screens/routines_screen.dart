import 'package:flutter/material.dart';

import '../models/routine_model.dart';
import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import 'routine_editor_screen.dart';
import 'workout_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({
    super.key,
    required this.ownerUid,
    required this.routinesRepository,
    required this.exercisesRepository,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final String ownerUid;
  final RoutinesRepository routinesRepository;
  final ExercisesRepository exercisesRepository;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  void _openEditor(BuildContext context, [RoutineModel? existing]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          ownerUid: ownerUid,
          routinesRepository: routinesRepository,
          exercisesRepository: exercisesRepository,
          existing: existing,
        ),
      ),
    );
  }

  void _startWorkout(BuildContext context, RoutineModel routine) {
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

  Future<void> _deleteRoutine(
    BuildContext context,
    RoutineModel routine,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: Text('¿Eliminar "${routine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await routinesRepository.deleteRoutine(routine.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RoutineModel>>(
      stream: routinesRepository.watchRoutines(ownerUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar rutinas:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        final routines = snapshot.data ?? [];
        if (routines.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.list_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Crea tu primera rutina.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _openEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva rutina'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final r = routines[index];
                final summary = r.exercises.isEmpty
                    ? 'Sin ejercicios'
                    : '${r.exercises.length} ejercicios';
                return Card(
                  child: ListTile(
                    title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '$summary${r.description != null ? '\n${r.description}' : ''}',
                    ),
                    isThreeLine: r.description != null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.green),
                          tooltip: 'Empezar',
                          onPressed: r.exercises.isEmpty
                              ? null
                              : () => _startWorkout(context, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Editar',
                          onPressed: () => _openEditor(context, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Eliminar',
                          onPressed: () => _deleteRoutine(context, r),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add_routine',
                onPressed: () => _openEditor(context),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
