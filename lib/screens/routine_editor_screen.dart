import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({
    super.key,
    required this.ownerUid,
    required this.routinesRepository,
    required this.exercisesRepository,
    this.existing,
  });

  final String ownerUid;
  final RoutinesRepository routinesRepository;
  final ExercisesRepository exercisesRepository;
  final RoutineModel? existing;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<RoutineExercise> _exercises = [];
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.existing!.name;
      _descCtrl.text = widget.existing!.description ?? '';
      _exercises.addAll(widget.existing!.exercises);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExercise() async {
    final exercises = await widget.exercisesRepository
        .watchExercises(widget.ownerUid)
        .first;

    if (exercises.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero añade ejercicios en la pestaña Ejercicios.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    final picked = await showDialog<ExerciseModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Seleccionar ejercicio'),
        children: exercises
            .map(
              (ex) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, ex),
                child: Text('${ex.name}  (${ex.muscleGroup.label})'),
              ),
            )
            .toList(),
      ),
    );

    if (picked == null) return;

    // Pedir series, reps, peso, descanso
    if (!mounted) return;
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController();
    final restCtrl = TextEditingController(text: '90');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(picked.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Series',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repeticiones',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg) — opcional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: restCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Descanso (seg)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _exercises.add(RoutineExercise(
        exerciseId: picked.id,
        exerciseName: picked.name,
        sets: int.tryParse(setsCtrl.text) ?? 3,
        reps: int.tryParse(repsCtrl.text) ?? 10,
        weightKg: double.tryParse(weightCtrl.text.replaceAll(',', '.')),
        restSeconds: int.tryParse(restCtrl.text) ?? 90,
      ));
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio.')),
      );
      return;
    }
    setState(() => _saving = true);

    try {
      final routine = RoutineModel(
        id: widget.existing?.id ?? '',
        ownerUid: widget.ownerUid,
        name: name,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        exercises: _exercises,
      );

      if (_isEditing) {
        await widget.routinesRepository.updateRoutine(routine);
      } else {
        await widget.routinesRepository.createRoutine(routine);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la rutina.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar rutina' : 'Nueva rutina'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre de la rutina',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ejercicios',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _pickExercise,
                icon: const Icon(Icons.add),
                label: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_exercises.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Añade ejercicios a la rutina.'),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _exercises.removeAt(oldIndex);
                  _exercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final ex = _exercises[index];
                final weightStr = ex.weightKg != null
                    ? '${ex.weightKg} kg'
                    : 'Sin peso';
                return ListTile(
                  key: ValueKey('$index-${ex.exerciseId}'),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(ex.exerciseName),
                  subtitle: Text(
                    '${ex.sets}×${ex.reps}  ·  $weightStr  ·  ${ex.restSeconds}s descanso',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() => _exercises.removeAt(index));
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
