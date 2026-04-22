import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/workout_session_model.dart';
import '../repositories/workouts_repository.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final User user;
  final AuthService authService;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<WorkoutSessionModel> _allWorkouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.workoutsRepository.getRecentWorkouts(
      widget.user.uid,
      limit: 200,
    );
    if (mounted) {
      setState(() {
        _allWorkouts = data;
        _loading = false;
      });
    }
  }

  int _calculateStreak() {
    if (_allWorkouts.isEmpty) return 0;
    int streak = 0;
    DateTime check = DateTime.now();
    final dates = _allWorkouts
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

  int _calculateBestStreak() {
    if (_allWorkouts.isEmpty) return 0;
    final dates = _allWorkouts
        .where((w) => w.startedAt != null)
        .map((w) {
          final d = w.startedAt!.toDate();
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList()
      ..sort();

    int best = 1;
    int current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }

  String _getLevelName(int sessions) {
    if (sessions >= 75) return 'LEYENDA';
    if (sessions >= 30) return 'ÉLITE';
    if (sessions >= 10) return 'GUERRERO';
    return 'NOVATO';
  }

  Color _getLevelColor(int sessions) {
    if (sessions >= 75) return ZarpaColors.warning;
    if (sessions >= 30) return ZarpaColors.primary;
    if (sessions >= 10) return ZarpaColors.success;
    return ZarpaColors.mutedLight;
  }

  int _getNextLevelThreshold(int sessions) {
    if (sessions >= 75) return 75;
    if (sessions >= 30) return 75;
    if (sessions >= 10) return 30;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: ZarpaColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalSessions = _allWorkouts.length;
    final streak = _calculateStreak();
    final bestStreak = _calculateBestStreak();
    final totalMin = _allWorkouts.fold<int>(
        0, (sum, w) => sum + (w.durationMinutes ?? 0));
    final levelName = _getLevelName(totalSessions);
    final levelColor = _getLevelColor(totalSessions);
    final nextThreshold = _getNextLevelThreshold(totalSessions);
    final progress =
        totalSessions >= 75 ? 1.0 : totalSessions / nextThreshold;
    final initial = (widget.user.displayName ?? 'U')[0].toUpperCase();

    // Achievements
    final achievements = [
      _Achievement(
        'Primera Zarpa',
        'Primer entrenamiento',
        Icons.pets,
        totalSessions >= 1,
      ),
      _Achievement(
        'Guerrero Urbano',
        '10 sesiones',
        Icons.shield,
        totalSessions >= 10,
      ),
      _Achievement(
        'Racha de Fuego',
        '7 días seguidos',
        Icons.local_fire_department,
        bestStreak >= 7,
      ),
      _Achievement(
        'Élite del Asfalto',
        '30 sesiones',
        Icons.bolt,
        totalSessions >= 30,
      ),
      _Achievement(
        'Leyenda Nocturna',
        '75 sesiones',
        Icons.emoji_events,
        totalSessions >= 75,
      ),
      _Achievement(
        'Instinto Puro',
        '5 entrenamientos HIIT',
        Icons.flash_on,
        false,
      ),
    ];

    return Scaffold(
      backgroundColor: ZarpaColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PERFIL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        settingsService: widget.settingsService,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ZarpaColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ZarpaColors.border),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZarpaColors.surface2,
                      border: Border.all(color: levelColor, width: 3),
                    ),
                    child: widget.user.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              widget.user.photoURL!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.displayName ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: levelColor.withOpacity(0.15),
                      border: Border.all(color: levelColor),
                    ),
                    child: Text(
                      levelName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: levelColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: ZarpaColors.border,
                      valueColor: AlwaysStoppedAnimation(levelColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalSessions >= 75
                        ? 'Nivel máximo alcanzado'
                        : '$totalSessions / $nextThreshold sesiones para el siguiente nivel',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ZarpaColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Grid
            const Text(
              'ESTADÍSTICAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ZarpaColors.muted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ProfileStatCard(
                    icon: Icons.fitness_center,
                    value: '$totalSessions',
                    label: 'SESIONES'),
                _ProfileStatCard(
                    icon: Icons.local_fire_department,
                    value: '$streak',
                    label: 'RACHA'),
                _ProfileStatCard(
                    icon: Icons.emoji_events,
                    value: '$bestStreak',
                    label: 'MEJOR RACHA'),
                _ProfileStatCard(
                    icon: Icons.timer,
                    value: '$totalMin',
                    label: 'MINUTOS'),
                _ProfileStatCard(
                    icon: Icons.star,
                    value:
                        '${achievements.where((a) => a.unlocked).length}',
                    label: 'LOGROS'),
              ],
            ),
            const SizedBox(height: 28),

            // Achievements
            const Text(
              'LOGROS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ZarpaColors.muted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: achievements
                  .map((a) => _AchievementCard(achievement: a))
                  .toList(),
            ),
            const SizedBox(height: 28),

            // Logout  
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: ZarpaColors.error,
                side: const BorderSide(color: ZarpaColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => widget.authService.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN',
                  style: TextStyle(
                      letterSpacing: 1, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),

            // Brand footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: ZarpaColors.surface2),
                ),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/zarpafit_logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ZARPAFIT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Instinto en movimiento',
                    style: TextStyle(
                      fontSize: 12,
                      color: ZarpaColors.muted,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
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
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  const _Achievement(this.title, this.description, this.icon, this.unlocked);
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.of(context).size.width - 40 - 20) / 3; // 3 per row
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ZarpaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZarpaColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: ZarpaColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
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

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40 - 20) / 3;
    return SizedBox(
      width: width,
      child: Opacity(
        opacity: achievement.unlocked ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ZarpaColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement.unlocked
                  ? ZarpaColors.primary
                  : ZarpaColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                achievement.unlocked
                    ? achievement.icon
                    : Icons.lock_outline,
                size: 28,
                color: achievement.unlocked
                    ? ZarpaColors.primary
                    : ZarpaColors.mutedLight,
              ),
              const SizedBox(height: 4),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: ZarpaColors.muted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
