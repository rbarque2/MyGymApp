import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/auth_service.dart';
import 'exercises_screen.dart';
import 'history_screen.dart';
import 'routines_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.exercisesRepository,
    required this.routinesRepository,
    required this.workoutsRepository,
  });

  final AuthService authService;
  final ExercisesRepository exercisesRepository;
  final RoutinesRepository routinesRepository;
  final WorkoutsRepository workoutsRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User get _user => widget.authService.currentUser!;

  @override
  Widget build(BuildContext context) {
    final screens = [
      RoutinesScreen(
        ownerUid: _user.uid,
        routinesRepository: widget.routinesRepository,
        exercisesRepository: widget.exercisesRepository,
        workoutsRepository: widget.workoutsRepository,
      ),
      ExercisesScreen(
        ownerUid: _user.uid,
        exercisesRepository: widget.exercisesRepository,
      ),
      HistoryScreen(
        ownerUid: _user.uid,
        workoutsRepository: widget.workoutsRepository,
      ),
      StatsScreen(
        ownerUid: _user.uid,
        workoutsRepository: widget.workoutsRepository,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyGymApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => widget.authService.signOut(),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Rutinas'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Ejercicios'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progreso'),
        ],
      ),
    );
  }
}
