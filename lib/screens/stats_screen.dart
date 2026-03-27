import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({
    super.key,
    required this.ownerUid,
    required this.workoutsRepository,
  });

  final String ownerUid;
  final WorkoutsRepository workoutsRepository;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<WorkoutSessionModel>? _workouts;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.workoutsRepository.getRecentWorkouts(
      widget.ownerUid,
      limit: 30,
    );
    if (mounted) {
      setState(() {
        _workouts = data.reversed.toList(); // cronológico
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final workouts = _workouts ?? [];
    if (workouts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Entrena para ver tus estadísticas.'),
          ],
        ),
      );
    }

    // Datos para las gráficas
    final volumeSpots = <FlSpot>[];
    final durationSpots = <FlSpot>[];
    for (int i = 0; i < workouts.length; i++) {
      volumeSpots.add(FlSpot(i.toDouble(), workouts[i].totalVolume));
      durationSpots.add(FlSpot(
        i.toDouble(),
        (workouts[i].durationMinutes ?? 0).toDouble(),
      ));
    }

    final totalSessions = workouts.length;
    final avgVolume = workouts.isEmpty
        ? 0.0
        : workouts.map((w) => w.totalVolume).reduce((a, b) => a + b) /
            workouts.length;
    final avgDuration = workouts.isEmpty
        ? 0.0
        : workouts
                .map((w) => (w.durationMinutes ?? 0).toDouble())
                .reduce((a, b) => a + b) /
            workouts.length;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen
          Row(
            children: [
              _StatCard(
                label: 'Sesiones',
                value: '$totalSessions',
                icon: Icons.calendar_today,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Vol. medio',
                value: '${avgVolume.toStringAsFixed(0)} kg',
                icon: Icons.fitness_center,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Duración media',
                value: '${avgDuration.toStringAsFixed(0)} min',
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfica de volumen
          Text('Volumen por sesión (kg)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 50),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: volumeSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Gráfica de duración
          Text('Duración por sesión (min)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 50),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: durationSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
