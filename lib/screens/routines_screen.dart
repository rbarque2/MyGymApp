import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';
import 'exercises_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';
import 'workout_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({
    super.key,
    required this.ownerUid,
    required this.routinesRepository,
    required this.exercisesRepository,
    required this.workoutsRepository,
    required this.settingsService,
  });

  final String ownerUid;
  final RoutinesRepository routinesRepository;
  final ExercisesRepository exercisesRepository;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  int _selectedSection = 0; // 0 = Rutinas, 1 = Entreno Libre
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _tagFilter;

  static const _availableTags = [
    'Pierna', 'Espalda', 'Pecho', 'Hombros', 'Brazos',
    'Core', 'HIIT', 'Cardio', 'Fuerza', 'Movilidad', 'Full Body',
  ];

  // Maps tag names to MuscleGroup values for smart filtering
  static const _tagToMuscleGroups = <String, List<MuscleGroup>>{
    'Pierna': [MuscleGroup.legs, MuscleGroup.glutes],
    'Espalda': [MuscleGroup.back],
    'Pecho': [MuscleGroup.chest],
    'Hombros': [MuscleGroup.shoulders],
    'Brazos': [MuscleGroup.biceps, MuscleGroup.triceps],
    'Core': [MuscleGroup.abs],
    'Cardio': [MuscleGroup.cardio],
    'Full Body': [MuscleGroup.fullBody],
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEditor(BuildContext context, [RoutineModel? existing]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          ownerUid: widget.ownerUid,
          routinesRepository: widget.routinesRepository,
          exercisesRepository: widget.exercisesRepository,
          existing: existing,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, RoutineModel routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          ownerUid: widget.ownerUid,
          routine: routine,
          routinesRepository: widget.routinesRepository,
          exercisesRepository: widget.exercisesRepository,
          workoutsRepository: widget.workoutsRepository,
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  void _startWorkout(BuildContext context, RoutineModel routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          ownerUid: widget.ownerUid,
          routine: routine,
          workoutsRepository: widget.workoutsRepository,
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  Future<void> _deleteRoutine(
    BuildContext context,
    RoutineModel routine,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: Text('¿Eliminar "${routine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.routinesRepository.deleteRoutine(routine.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ENTRENA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fitness_center, size: 20),
                    tooltip: 'Gestionar ejercicios',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExercisesScreen(
                          ownerUid: widget.ownerUid,
                          exercisesRepository: widget.exercisesRepository,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: ZarpaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ZarpaColors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSection = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedSection == 0
                                ? ZarpaColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              'RUTINAS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: _selectedSection == 0
                                    ? Colors.white
                                    : ZarpaColors.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSection = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedSection == 1
                                ? ZarpaColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              'ENTRENO LIBRE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: _selectedSection == 1
                                    ? Colors.white
                                    : ZarpaColors.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _selectedSection == 0
                  ? _buildRutinasSection()
                  : _buildEntrenoLibreSection(),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedSection == 0
          ? FloatingActionButton(
              heroTag: 'add_routine',
              onPressed: () => _openEditor(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRutinasSection() {
    return StreamBuilder<List<RoutineModel>>(
      stream: widget.routinesRepository.watchRoutines(widget.ownerUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: ZarpaColors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar rutinas:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        final routines = snapshot.data ?? [];

        if (routines.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sin rutinas todavía',
                  style: TextStyle(
                    fontSize: 14,
                    color: ZarpaColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Activa tu lado salvaje',
                  style: TextStyle(
                    fontSize: 12,
                    color: ZarpaColors.mutedLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _openEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('NUEVA RUTINA'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final r = routines[index];
            return _RoutineCard(
              routine: r,
              onTap: () => _openDetail(context, r),
              onStart: r.exercises.isEmpty
                  ? null
                  : () => _startWorkout(context, r),
              onEdit: () => _openEditor(context, r),
              onDelete: () => _deleteRoutine(context, r),
            );
          },
        );
      },
    );
  }

  Widget _buildEntrenoLibreSection() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Buscar ejercicio...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: ZarpaColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ZarpaColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ZarpaColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: ZarpaColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tag filters
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: const Text('Todos', style: TextStyle(fontSize: 12)),
                  selected: _tagFilter == null,
                  onSelected: (_) => setState(() => _tagFilter = null),
                  selectedColor: ZarpaColors.primary.withOpacity(0.15),
                  checkmarkColor: ZarpaColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              ..._availableTags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      selected: _tagFilter == tag,
                      onSelected: (_) => setState(
                          () => _tagFilter = _tagFilter == tag ? null : tag),
                      selectedColor: ZarpaColors.primary.withOpacity(0.15),
                      checkmarkColor: ZarpaColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Exercises list
        Expanded(
          child: StreamBuilder<List<ExerciseModel>>(
            stream: widget.exercisesRepository
                .watchExercises(widget.ownerUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}'));
              }
              var exercises = snapshot.data ?? [];

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                exercises = exercises
                    .where((e) =>
                        e.name.toLowerCase().contains(_searchQuery) ||
                        e.muscleGroup.label
                            .toLowerCase()
                            .contains(_searchQuery))
                    .toList();
              }

              // Apply tag filter
              if (_tagFilter != null) {
                final muscleGroups = _tagToMuscleGroups[_tagFilter];
                exercises = exercises
                    .where((e) =>
                        e.tags.contains(_tagFilter) ||
                        (muscleGroups != null &&
                            muscleGroups.contains(e.muscleGroup)))
                    .toList();
              }

              if (exercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off,
                          size: 48, color: ZarpaColors.mutedLight),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty || _tagFilter != null
                            ? 'Sin resultados'
                            : 'No hay ejercicios',
                        style: const TextStyle(
                            color: ZarpaColors.muted, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return _ExerciseCard(exercise: ex);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onTap,
    this.onStart,
    required this.onEdit,
    required this.onDelete,
  });
  final RoutineModel routine;
  final VoidCallback onTap;
  final VoidCallback? onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final exCount = routine.exercises.length;
    final totalSets =
        routine.exercises.fold<int>(0, (sum, e) => sum + e.sets);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: ZarpaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ZarpaColors.border),
          ),
          child: Column(
            children: [
              // Top accent bar
              Container(
                height: 3,
                color: ZarpaColors.primary,
              ),
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Emoji
                      const Text('💪', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (routine.description != null)
                              Text(
                                routine.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ZarpaColors.muted,
                                  height: 1.3,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.fitness_center,
                                    size: 12,
                                    color: ZarpaColors.mutedLight),
                                const SizedBox(width: 4),
                                Text(
                                  '$exCount ej.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ZarpaColors.muted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.repeat,
                                    size: 12,
                                    color: ZarpaColors.mutedLight),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalSets series',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ZarpaColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            if (routine.tags.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: routine.tags.map((tag) =>
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ZarpaColors.primary
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: ZarpaColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Actions
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.chevron_right,
                            size: 18, color: ZarpaColors.darkBorder),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'start') onStart?.call();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (_) => [
                          if (onStart != null)
                            const PopupMenuItem(
                              value: 'start',
                              child: ListTile(
                                leading: Icon(Icons.play_arrow,
                                    color: ZarpaColors.primary),
                                title: Text('Empezar'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Editar'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete,
                                  color: ZarpaColors.error),
                              title: Text('Eliminar',
                                  style:
                                      TextStyle(color: ZarpaColors.error)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});
  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: ZarpaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon / photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: exercise.photoUrl != null
                  ? Image.network(
                      exercise.photoUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _ExerciseIcon(label: exercise.muscleGroup.label),
                    )
                  : _ExerciseIcon(label: exercise.muscleGroup.label),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.muscleGroup.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ZarpaColors.muted,
                    ),
                  ),
                  if (exercise.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: exercise.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      ZarpaColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: ZarpaColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseIcon extends StatelessWidget {
  const _ExerciseIcon({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: ZarpaColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label[0],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ZarpaColors.primary,
          ),
        ),
      ),
    );
  }
}
