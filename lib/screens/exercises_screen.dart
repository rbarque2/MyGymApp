import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../repositories/exercises_repository.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({
    super.key,
    required this.ownerUid,
    required this.exercisesRepository,
  });

  final String ownerUid;
  final ExercisesRepository exercisesRepository;

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  MuscleGroup? _filter;

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    MuscleGroup selectedGroup = MuscleGroup.chest;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nuevo ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MuscleGroup>(
                  initialValue: selectedGroup,
                  decoration: const InputDecoration(
                    labelText: 'Grupo muscular',
                    border: OutlineInputBorder(),
                  ),
                  items: MuscleGroup.values
                      .map((g) =>
                          DropdownMenuItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedGroup = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                await widget.exercisesRepository.createExercise(
                  ExerciseModel(
                    id: '',
                    ownerUid: widget.ownerUid,
                    name: name,
                    muscleGroup: selectedGroup,
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteExercise(ExerciseModel exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: Text('¿Eliminar "${exercise.name}"?'),
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
      await widget.exercisesRepository.deleteExercise(exercise.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtro por grupo muscular
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              const SizedBox(width: 8),
              ...MuscleGroup.values.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(g.label),
                    selected: _filter == g,
                    onSelected: (_) => setState(() => _filter = g),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ExerciseModel>>(
            stream: _filter == null
                ? widget.exercisesRepository.watchExercises(widget.ownerUid)
                : widget.exercisesRepository
                    .watchExercisesByMuscle(widget.ownerUid, _filter!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final exercises = snapshot.data ?? [];
              if (exercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No hay ejercicios todavía.'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir ejercicio'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(ex.muscleGroup.label[0]),
                    ),
                    title: Text(ex.name),
                    subtitle: Text(ex.muscleGroup.label +
                        (ex.description != null ? ' · ${ex.description}' : '')),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteExercise(ex),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
