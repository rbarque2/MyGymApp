import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';
import '../theme/zarpafit_theme.dart';

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
      limit: 100,
    );
    if (mounted) {
      setState(() {
        _workouts = data;
        _loading = false;
      });
    }
  }

  // Get workout count per day of the week (last 7 days)
  List<int> _weeklyData() {
    final now = DateTime.now();
    final counts = List.filled(7, 0);
    final workouts = _workouts ?? [];

    for (final w in workouts) {
      if (w.startedAt == null) continue;
      final date = w.startedAt!.toDate();
      final diff = now.difference(date).inDays;
      if (diff < 7) {
        // 0 = today, 6 = 6 days ago
        counts[6 - diff]++;
      }
    }
    return counts;
  }

  int _calculateStreak() {
    final workouts = _workouts ?? [];
    if (workouts.isEmpty) return 0;
    int streak = 0;
    DateTime check = DateTime.now();
    final dates = workouts
        .where((w) => w.startedAt != null)
        .map((w) {
          final d = w.startedAt!.toDate();
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in dates) {
      final diff = DateTime(check.year, check.month, check.day)
          .difference(date)
          .inDays;
      if (diff <= 1) {
        streak++;
        check = date;
      } else {
        break;
      }
    }
    return streak;
  }

  // Monthly stats
  Map<String, dynamic> _monthlyStats() {
    final workouts = _workouts ?? [];
    final now = DateTime.now();
    final thisMonth = workouts.where((w) {
      if (w.startedAt == null) return false;
      final d = w.startedAt!.toDate();
      return d.month == now.month && d.year == now.year;
    }).toList();

    final sessions = thisMonth.length;
    final totalMin =
        thisMonth.fold<int>(0, (s, w) => s + (w.durationMinutes ?? 0));
    final totalVol =
        thisMonth.fold<double>(0, (s, w) => s + w.totalVolume);

    return {
      'sessions': sessions,
      'minutes': totalMin,
      'volume': totalVol,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: ZarpaColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final workouts = _workouts ?? [];
    final streak = _calculateStreak();
    final weekly = _weeklyData();
    final monthly = _monthlyStats();
    final maxWeekly =
        weekly.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, 100);

    final dayLabels = _getDayLabels();

    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header
              const Text(
                'PROGRESO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              if (workouts.isEmpty) ...[
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.bar_chart_rounded,
                          size: 72, color: ZarpaColors.mutedLight),
                      const SizedBox(height: 16),
                      const Text(
                        'Entrena para ver tu progreso',
                        style: TextStyle(
                          fontSize: 16,
                          color: ZarpaColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Aquí verás tus estadísticas',
                        style: TextStyle(
                          fontSize: 13,
                          color: ZarpaColors.muted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          // Navigate to routines tab via parent
                        },
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Empezar a entrenar'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Streak badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ZarpaColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak ${streak == 1 ? 'día' : 'días'} de racha',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            streak > 0
                                ? '¡Sigue así, no pares!'
                                : 'Entrena hoy para empezar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section: weekly chart
                const Text(
                  'ESTA SEMANA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ZarpaColors.muted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ZarpaColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ZarpaColors.border),
                  ),
                  child: SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxWeekly + 1,
                        barTouchData: BarTouchData(enabled: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= dayLabels.length) {
                                  return const SizedBox();
                                }
                                final isToday = idx == 6;
                                return Text(
                                  dayLabels[idx],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isToday
                                        ? ZarpaColors.primary
                                        : ZarpaColors.muted,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(7, (i) {
                          final isToday = i == 6;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: weekly[i].toDouble(),
                                color: isToday
                                    ? ZarpaColors.primary
                                    : ZarpaColors.primary.withOpacity(0.3),
                                width: 28,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Monthly stats
                const Text(
                  'ESTE MES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ZarpaColors.muted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MonthStat(
                      value: '${monthly['sessions']}',
                      label: 'SESIONES',
                      icon: Icons.fitness_center,
                    ),
                    const SizedBox(width: 10),
                    _MonthStat(
                      value: '${monthly['minutes']}',
                      label: 'MINUTOS',
                      icon: Icons.timer,
                    ),
                    const SizedBox(width: 10),
                    _MonthStat(
                      value:
                          '${(monthly['volume'] as double).toStringAsFixed(0)}',
                      label: 'KG VOL.',
                      icon: Icons.monitor_weight_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Total stats
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ZarpaColors.muted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildTotalStats(workouts),
                const SizedBox(height: 24),

                // Recent history
                const Text(
                  'HISTORIAL RECIENTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ZarpaColors.muted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  workouts.length.clamp(0, 10),
                  (i) {
                    final w = workouts[i];
                    final date = w.startedAt?.toDate();
                    final dateStr = date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : '';
                    final completedSets =
                        w.sets.where((s) => s.completed).length;
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
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ZarpaColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.routineName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '$dateStr · ${w.durationMinutes ?? 0} min · $completedSets/${w.sets.length} series',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ZarpaColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 18, color: ZarpaColors.mutedLight),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getDayLabels() {
    const names = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return names[day.weekday - 1];
    });
  }

  List<Widget> _buildTotalStats(List<WorkoutSessionModel> workouts) {
    final totalSessions = workouts.length;
    final totalMin =
        workouts.fold<int>(0, (s, w) => s + (w.durationMinutes ?? 0));
    final totalVol =
        workouts.fold<double>(0, (s, w) => s + w.totalVolume);
    final totalSets =
        workouts.fold<int>(0, (s, w) => s + w.sets.where((s) => s.completed).length);

    return [
      _TotalStatRow(label: 'Sesiones totales', value: '$totalSessions'),
      _TotalStatRow(label: 'Minutos totales', value: '$totalMin'),
      _TotalStatRow(
          label: 'Volumen total', value: '${totalVol.toStringAsFixed(0)} kg'),
      _TotalStatRow(label: 'Series completadas', value: '$totalSets'),
    ];
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: ZarpaColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ZarpaColors.muted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalStatRow extends StatelessWidget {
  const _TotalStatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ZarpaColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ZarpaColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
