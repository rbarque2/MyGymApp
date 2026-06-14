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
      return Scaffold(
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'PERFIL',
                  style: TextStyle(
                    fontFamily: ZarpaFonts.display,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: ZarpaColors.foreground,
                    height: 0.95,
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

            // Identidad: avatar + nombre + nivel.
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: ZarpaColors.surface2,
                    border: Border.all(color: levelColor, width: 3),
                  ),
                  child: widget.user.photoURL != null
                      ? Image.network(
                          widget.user.photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _AvatarInitial(initial),
                        )
                      : _AvatarInitial(initial),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.user.displayName ?? 'SIN NOMBRE').toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: ZarpaFonts.display,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: ZarpaColors.foreground,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        color: levelColor,
                        child: Text(
                          levelName,
                          style: const TextStyle(
                            fontFamily: ZarpaFonts.mono,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: ZarpaInk.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progreso de nivel
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: ZarpaColors.border,
              valueColor: AlwaysStoppedAnimation(levelColor),
            ),
            const SizedBox(height: 6),
            Text(
              totalSessions >= 75
                  ? 'NIVEL MÁXIMO ALCANZADO'
                  : '$totalSessions / $nextThreshold SESIONES PARA EL SIGUIENTE NIVEL',
              style: TextStyle(
                fontFamily: ZarpaFonts.mono,
                fontSize: 10,
                color: ZarpaColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 28),

            // Estadísticas — números gigantes con retícula.
            const _SectionTitle(label: 'ESTADÍSTICAS'),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  _BigStatCell(value: '$totalSessions', label: 'SESIONES'),
                  _GridDivider(),
                  _BigStatCell(value: '$streak', label: 'RACHA'),
                  _GridDivider(),
                  _BigStatCell(value: '$bestStreak', label: 'MEJOR'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                children: [
                  _BigStatCell(value: '$totalMin', label: 'MINUTOS'),
                  _GridDivider(),
                  _BigStatCell(
                    value: '${achievements.where((a) => a.unlocked).length}',
                    label: 'LOGROS',
                  ),
                  _GridDivider(),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logros
            const _SectionTitle(label: 'LOGROS'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: achievements
                  .map((a) => _AchievementCard(achievement: a))
                  .toList(),
            ),
            const SizedBox(height: 28),

            // Cerrar sesión
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: ZarpaColors.error,
                side: const BorderSide(color: ZarpaColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              onPressed: () => widget.authService.signOut(),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(
                  fontFamily: ZarpaFonts.display,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Brand footer
            Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ZarpaColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ZARPAFIT',
                    style: TextStyle(
                      fontFamily: ZarpaFonts.mono,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3,
                      color: ZarpaColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instinto en movimiento',
                    style: TextStyle(
                      fontSize: 13,
                      color: ZarpaColors.mutedLight,
                      fontStyle: FontStyle.italic,
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

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial(this.initial);
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: ZarpaFonts.display,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ZarpaColors.foreground,
        ),
      ),
    );
  }
}

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

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  const _Achievement(this.title, this.description, this.icon, this.unlocked);
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40 - 20) / 3;
    final unlocked = achievement.unlocked;
    return SizedBox(
      width: width,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.45,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked
                ? ZarpaColors.primary.withOpacity(0.08)
                : Colors.transparent,
            border: Border.all(
              color: unlocked ? ZarpaColors.primary : ZarpaColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                unlocked ? achievement.icon : Icons.lock_outline,
                size: 26,
                color: unlocked ? ZarpaColors.primary : ZarpaColors.mutedLight,
              ),
              const Spacer(),
              Text(
                achievement.title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ZarpaFonts.display,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ZarpaColors.foreground,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                achievement.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ZarpaFonts.mono,
                  fontSize: 9,
                  color: ZarpaColors.muted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
