import 'package:flutter/material.dart';

import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';
import '../theme/zarpafit_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.ownerUid,
    required this.workoutsRepository,
  });

  final String ownerUid;
  final WorkoutsRepository workoutsRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: StreamBuilder<List<WorkoutSessionModel>>(
        stream: workoutsRepository.watchWorkouts(ownerUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Aún no has registrado entrenamientos.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final w = workouts[index];
              final date = w.startedAt?.toDate();
              final dateStr = date != null
                  ? '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                  : 'Fecha desconocida';
              final durationStr =
                  w.durationMinutes != null ? '${w.durationMinutes} min' : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: ZarpaColors.border)),
                color: ZarpaColors.surface,
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ZarpaColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: ZarpaColors.success),
                  ),
                  title: Text(
                    w.routineName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$dateStr  ·  $durationStr'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${w.completedSets} series',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${w.totalVolume.toStringAsFixed(0)} kg vol.',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (w.notes != null && w.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Notas: ${w.notes}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ...w.sets
                              .where((s) => s.completed)
                              .map(
                                (s) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check,
                                          size: 14, color: ZarpaColors.success),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${s.exerciseName}  Serie ${s.setNumber}:  '
                                        '${s.reps} reps × ${s.weightKg ?? 0} kg',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
