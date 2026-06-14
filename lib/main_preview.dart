// Entrypoint de preview con datos falsos para revisar el diseño del Home
// sin pasar por login. Solo para desarrollo:
//   flutter build web -t lib/main_preview.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/routine_model.dart';
import 'models/workout_session_model.dart';
import 'repositories/exercises_repository.dart';
import 'repositories/routines_repository.dart';
import 'repositories/workouts_repository.dart';
import 'screens/home_tab_screen.dart';
import 'screens/login_screen.dart';
import 'screens/routine_detail_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/workout_completion_screen.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'theme/zarpafit_theme.dart';

RoutineExercise _ex(String name, {int sets = 4}) => RoutineExercise(
      exerciseId: name,
      exerciseName: name,
      sets: sets,
      reps: 10,
    );

final _routines = [
  RoutineModel(
    id: 'r1',
    ownerUid: 'preview',
    name: 'Empuje · Día 3',
    description: 'Pecho, hombro y tríceps',
    exercises: [
      _ex('Press banca'),
      _ex('Press militar'),
      _ex('Fondos'),
      _ex('Aperturas', sets: 3),
      _ex('Pushdown', sets: 3),
      _ex('Elevaciones laterales', sets: 3),
    ],
  ),
  RoutineModel(
    id: 'r2',
    ownerUid: 'preview',
    name: 'Tirón pesado',
    exercises: [_ex('Dominadas'), _ex('Remo'), _ex('Curl')],
  ),
  RoutineModel(
    id: 'r3',
    ownerUid: 'preview',
    name: 'Pierna brutal',
    exercises: [_ex('Sentadilla'), _ex('Peso muerto'), _ex('Zancadas')],
  ),
  RoutineModel(
    id: 'r4',
    ownerUid: 'preview',
    name: 'Core y movilidad',
    exercises: [_ex('Plancha'), _ex('Dead bug')],
  ),
];

class _FakeRoutinesRepository extends RoutinesRepository {
  @override
  Stream<List<RoutineModel>> watchRoutines(String ownerUid) =>
      Stream.value(_routines);
}

class _FakeWorkoutsRepository extends WorkoutsRepository {
  // Sin escrituras reales: .doc() solo crea la referencia, no escribe.
  @override
  Future<DocumentReference<Map<String, dynamic>>> createWorkout(
    WorkoutSessionModel session,
  ) async =>
      FirebaseFirestore.instance.collection('preview_only').doc();

  @override
  Future<void> finishWorkout(
    String id, {
    required List<WorkoutSet> sets,
    required int durationMinutes,
    String? notes,
  }) async {}

  @override
  Future<void> deleteWorkout(String id) async {}

  @override
  Future<List<WorkoutSessionModel>> getRecentWorkouts(
    String ownerUid, {
    int limit = 30,
  }) async {
    final now = DateTime.now();
    List<WorkoutSet> fakeSets() => List.generate(
          18,
          (i) => WorkoutSet(
            exerciseId: 'e$i',
            exerciseName: 'Ejercicio ${i + 1}',
            setNumber: i + 1,
            reps: 10,
            weightKg: 40,
            completed: true,
          ),
        );
    WorkoutSessionModel session(int daysAgo, String name, int minutes) =>
        WorkoutSessionModel(
          id: 'w$daysAgo',
          ownerUid: 'preview',
          routineId: 'r1',
          routineName: name,
          sets: fakeSets(),
          startedAt: Timestamp.fromDate(now.subtract(Duration(days: daysAgo))),
          durationMinutes: minutes,
        );
    return [
      session(0, 'Empuje · Día 3', 47),
      session(1, 'Tirón pesado', 52),
      session(2, 'Pierna brutal', 61),
      session(3, 'Empuje · Día 3', 44),
      session(4, 'Core y movilidad', 25),
    ];
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ZarpaColors.apply(Brightness.dark);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: zarpaFitTheme(),
      darkTheme: zarpaFitThemeDark(),
      themeMode: ThemeMode.dark,
      home: const _PreviewLauncher(),
    ),
  );
}

/// Menú para revisar las pantallas del rediseño sin login.
class _PreviewLauncher extends StatelessWidget {
  const _PreviewLauncher();

  @override
  Widget build(BuildContext context) {
    Widget btn(String label, Widget screen) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => screen),
              ),
              child: Text(label),
            ),
          ),
        );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              btn(
                'HOME PÓSTER',
                HomeTabScreen(
                  ownerUid: 'preview',
                  userName: 'Rafa Barquero',
                  routinesRepository: _FakeRoutinesRepository(),
                  exercisesRepository: ExercisesRepository(),
                  workoutsRepository: _FakeWorkoutsRepository(),
                  settingsService: SettingsService(),
                ),
              ),
              btn(
                'STATS ASFALTO',
                StatsScreen(
                  ownerUid: 'preview',
                  workoutsRepository: _FakeWorkoutsRepository(),
                ),
              ),
              btn(
                'CIERRE PÓSTER',
                const WorkoutCompletionScreen(
                  routineName: 'Empuje · Día 3',
                  completedSets: 19,
                  totalSets: 21,
                  durationMinutes: 47,
                  exerciseCount: 6,
                ),
              ),
              btn('LOGIN PÓSTER', LoginScreen(authService: AuthService())),
              btn(
                'DETALLE RUTINA',
                RoutineDetailScreen(
                  ownerUid: 'preview',
                  routine: _routines.first,
                  routinesRepository: _FakeRoutinesRepository(),
                  exercisesRepository: ExercisesRepository(),
                  workoutsRepository: _FakeWorkoutsRepository(),
                  settingsService: SettingsService(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
