import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final AuthService _authService;
  late final ExercisesRepository _exercisesRepository;
  late final RoutinesRepository _routinesRepository;
  late final WorkoutsRepository _workoutsRepository;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _exercisesRepository = ExercisesRepository();
    _routinesRepository = RoutinesRepository();
    _workoutsRepository = WorkoutsRepository();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return LoginScreen(authService: _authService);
        }

        return HomeScreen(
          authService: _authService,
          exercisesRepository: _exercisesRepository,
          routinesRepository: _routinesRepository,
          workoutsRepository: _workoutsRepository,
        );
      },
    );
  }
}
