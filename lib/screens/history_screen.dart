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

  static const _months = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: SafeArea(
        child: StreamBuilder<List<WorkoutSessionModel>>(
          stream: workoutsRepository.watchWorkouts(ownerUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final workouts = snapshot.data ?? [];

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HISTORIAL',
                          style: TextStyle(
                            fontFamily: ZarpaFonts.display,
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: ZarpaColors.foreground,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (workouts.isNotEmpty)
                          Text(
                            '${workouts.length} ${workouts.length == 1 ? 'SESIÓN REGISTRADA' : 'SESIONES REGISTRADAS'}',
                            style: TextStyle(
                              fontFamily: ZarpaFonts.mono,
                              fontSize: 11,
                              color: ZarpaColors.muted,
                              letterSpacing: 1.5,
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (workouts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 64, color: ZarpaColors.mutedLight),
                        const SizedBox(height: 12),
                        Text(
                          'SIN ENTRENAMIENTOS AÚN',
                          style: TextStyle(
                            fontFamily: ZarpaFonts.display,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ZarpaColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tus sesiones aparecerán aquí',
                          style: TextStyle(
                              fontSize: 13, color: ZarpaColors.muted),
                        ),
                        const Spacer(),
                      ],
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, i) =>
                          _HistoryRow(workout: workouts[i], months: _months),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.workout, required this.months});
  final WorkoutSessionModel workout;
  final List<String> months;

  @override
  Widget build(BuildContext context) {
    final date = workout.startedAt?.toDate();
    final dayNum = date != null ? date.day.toString().padLeft(2, '0') : '--';
    final monthStr = date != null ? months[date.month - 1] : '';
    final timeStr = date != null
        ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '';
    final durationStr =
        workout.durationMinutes != null ? '${workout.durationMinutes} MIN' : '';
    final completedSets = workout.sets.where((s) => s.completed).toList();

    return Theme(
      // Quita las líneas divisorias por defecto del ExpansionTile.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: ZarpaColors.border)),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16, left: 4),
          iconColor: ZarpaColors.primary,
          collapsedIconColor: ZarpaColors.mutedLight,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayNum,
                style: TextStyle(
                  fontFamily: ZarpaFonts.display,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: ZarpaColors.primary,
                  height: 0.9,
                ),
              ),
              Text(
                monthStr,
                style: TextStyle(
                  fontFamily: ZarpaFonts.mono,
                  fontSize: 9,
                  color: ZarpaColors.muted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          title: Text(
            workout.routineName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: ZarpaFonts.display,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.foreground,
            ),
          ),
          subtitle: Text(
            '$timeStr · $durationStr · ${workout.totalVolume.toStringAsFixed(0)} KG',
            style: TextStyle(
              fontFamily: ZarpaFonts.mono,
              fontSize: 10,
              color: ZarpaColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          children: [
            if (workout.notes != null && workout.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 12),
                child: Text(
                  'Notas: ${workout.notes}',
                  style: TextStyle(fontSize: 13, color: ZarpaColors.muted),
                ),
              ),
            ...completedSets.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 14, color: ZarpaColors.cta),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${s.exerciseName}  ·  S${s.setNumber}  ·  ${s.reps} × ${s.weightKg ?? 0} kg',
                        style: TextStyle(
                          fontFamily: ZarpaFonts.mono,
                          fontSize: 11,
                          color: ZarpaColors.foreground,
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
