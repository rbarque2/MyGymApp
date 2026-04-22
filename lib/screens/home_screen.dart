import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';
import 'home_tab_screen.dart';
import 'profile_screen.dart';
import 'routines_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.exercisesRepository,
    required this.routinesRepository,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final AuthService authService;
  final ExercisesRepository exercisesRepository;
  final RoutinesRepository routinesRepository;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User get _user => widget.authService.currentUser!;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeTabScreen(
        ownerUid: _user.uid,
        userName: _user.displayName ?? 'Atleta',
        routinesRepository: widget.routinesRepository,
        exercisesRepository: widget.exercisesRepository,
        workoutsRepository: widget.workoutsRepository,
        settingsService: widget.settingsService,
      ),
      RoutinesScreen(
        ownerUid: _user.uid,
        routinesRepository: widget.routinesRepository,
        exercisesRepository: widget.exercisesRepository,
        workoutsRepository: widget.workoutsRepository,
        settingsService: widget.settingsService,
      ),
      StatsScreen(
        ownerUid: _user.uid,
        workoutsRepository: widget.workoutsRepository,
      ),
      ProfileScreen(
        user: _user,
        authService: widget.authService,
        workoutsRepository: widget.workoutsRepository,
        settingsService: widget.settingsService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ZarpaColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined),
              selectedIcon: Icon(Icons.local_fire_department),
              label: 'Entrena',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Progreso',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
