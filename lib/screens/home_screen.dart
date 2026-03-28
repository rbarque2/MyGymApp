import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import 'exercises_screen.dart';
import 'history_screen.dart';
import 'routines_screen.dart';
import 'settings_screen.dart';
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

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => setState(() => _currentIndex = index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      RoutinesScreen(
        ownerUid: _user.uid,
        routinesRepository: widget.routinesRepository,
        exercisesRepository: widget.exercisesRepository,
        workoutsRepository: widget.workoutsRepository,
        settingsService: widget.settingsService,
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
      body: Row(
        children: [
          // Menú lateral negro con letras blancas
          Container(
            width: 220,
            color: Colors.black,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Encabezado
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'MyGymApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 8),
                // Opciones del menú
                _buildNavItem(Icons.list_alt, 'Rutinas', 0),
                _buildNavItem(Icons.fitness_center, 'Ejercicios', 1),
                _buildNavItem(Icons.history, 'Historial', 2),
                _buildNavItem(Icons.bar_chart, 'Progreso', 3),
                const Spacer(),
                const Divider(color: Colors.white24, height: 1),
                // Configuración
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white70),
                  title: const Text(
                    'Configuración',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          settingsService: widget.settingsService,
                        ),
                      ),
                    );
                  },
                ),
                // Cerrar sesión
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () => widget.authService.signOut(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
        ],
      ),
    );
  }
}
