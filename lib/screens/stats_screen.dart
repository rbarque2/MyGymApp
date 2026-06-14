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
      return Scaffold(
        backgroundColor: ZarpaColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final workouts = _workouts ?? [];
    final streak = _calculateStreak();
    final weekly = _weeklyData();
    final monthly = _monthlyStats();
    final maxWeekly =
        weekly.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, 100);
    final dayLabels = _getDayLabels();
    final weekTotal = weekly.fold<int>(0, (s, v) => s + v);

    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Header
              Text(
                'PROGRESO',
                style: TextStyle(
                  fontFamily: ZarpaFonts.display,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: ZarpaColors.foreground,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 24),

              if (workouts.isEmpty) ...[
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 72, color: ZarpaColors.mutedLight),
                      const SizedBox(height: 16),
                      Text(
                        'ENTRENA PARA VER TU PROGRESO',
                        style: TextStyle(
                          fontFamily: ZarpaFonts.display,
                          fontSize: 20,
                          color: ZarpaColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aquí verás tus estadísticas',
                        style: TextStyle(fontSize: 13, color: ZarpaColors.muted),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Racha como protagonista Asfalto.
                _StreakHero(streak: streak),
                const SizedBox(height: 28),

                // Esta semana
                const _SectionTitle(label: 'ESTA SEMANA'),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$weekTotal',
                      style: TextStyle(
                        fontFamily: ZarpaFonts.display,
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: ZarpaColors.foreground,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        weekTotal == 1 ? 'SESIÓN' : 'SESIONES',
                        style: TextStyle(
                          fontFamily: ZarpaFonts.mono,
                          fontSize: 12,
                          color: ZarpaColors.muted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
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
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  dayLabels[idx],
                                  style: TextStyle(
                                    fontFamily: ZarpaFonts.mono,
                                    fontSize: 11,
                                    color: isToday
                                        ? ZarpaColors.primary
                                        : ZarpaColors.muted,
                                  ),
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
                                  : ZarpaColors.primary.withOpacity(0.28),
                              width: 30,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Este mes — bloques duros con números gigantes.
                const _SectionTitle(label: 'ESTE MES'),
                const SizedBox(height: 14),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _BigStatCell(
                        value: '${monthly['sessions']}',
                        label: 'SESIONES',
                      ),
                      _GridDivider(),
                      _BigStatCell(
                        value: '${monthly['minutes']}',
                        label: 'MINUTOS',
                      ),
                      _GridDivider(),
                      _BigStatCell(
                        value:
                            '${(monthly['volume'] as double).toStringAsFixed(0)}',
                        label: 'KG VOL.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Total
                const _SectionTitle(label: 'TOTAL'),
                const SizedBox(height: 6),
                ..._buildTotalStats(workouts),
                const SizedBox(height: 28),

                // Historial reciente — filas duras, fecha mono.
                const _SectionTitle(label: 'HISTORIAL RECIENTE'),
                const SizedBox(height: 6),
                ...List.generate(
                  workouts.length.clamp(0, 10),
                  (i) {
                    final w = workouts[i];
                    final date = w.startedAt?.toDate();
                    final dateStr = date != null ? _shortDate(date) : '';
                    final completedSets =
                        w.sets.where((s) => s.completed).length;
                    return _HistoryRow(
                      name: w.routineName,
                      meta:
                          '$dateStr · ${w.durationMinutes ?? 0} MIN · $completedSets/${w.sets.length} SERIES',
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

  static String _shortDate(DateTime date) {
    const months = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return '${date.day} ${months[date.month - 1]}';
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

/// Racha como número gigante con borde superior naranja (Asfalto).
class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ZarpaColors.primary, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$streak',
            style: const TextStyle(
              fontFamily: ZarpaFonts.display,
              fontSize: 100,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.primary,
              height: 0.8,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak == 1 ? 'DÍA DE RACHA' : 'DÍAS DE RACHA',
                    style: TextStyle(
                      fontFamily: ZarpaFonts.display,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ZarpaColors.foreground,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    streak > 0
                        ? 'SIGUE ASÍ. NO PARES.'
                        : 'ENTRENA HOY PARA EMPEZAR',
                    style: TextStyle(
                      fontFamily: ZarpaFonts.mono,
                      fontSize: 11,
                      color: ZarpaColors.muted,
                      letterSpacing: 1,
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

/// Celda de cifra grande con retícula (Asfalto). Va dentro de IntrinsicHeight.
class _BigStatCell extends StatelessWidget {
  const _BigStatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: ZarpaFonts.display,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: ZarpaColors.foreground,
                height: 0.95,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: ZarpaFonts.mono,
              fontSize: 10,
              color: ZarpaColors.muted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: ZarpaColors.border,
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ZarpaColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: ZarpaFonts.mono,
              fontSize: 12,
              color: ZarpaColors.muted,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: ZarpaFonts.display,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ZarpaColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.name, required this.meta});
  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ZarpaColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
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
                  meta,
                  style: TextStyle(
                    fontFamily: ZarpaFonts.mono,
                    fontSize: 10,
                    color: ZarpaColors.muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: ZarpaColors.mutedLight),
        ],
      ),
    );
  }
}
