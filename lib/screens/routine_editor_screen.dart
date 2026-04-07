import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../repositories/exercises_repository.dart';
import '../repositories/routines_repository.dart';
import '../theme/zarpafit_theme.dart';

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
  static const _availableTags = [
    'Pierna', 'Espalda', 'Pecho', 'Hombros', 'Brazos',
    'Core', 'HIIT', 'Cardio', 'Fuerza', 'Movilidad', 'Full Body',
  ];

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<RoutineExercise> _exercises = [];
  final Set<String> _selectedTags = {};
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.existing!.name;
      _descCtrl.text = widget.existing!.description ?? '';
      _exercises.addAll(widget.existing!.exercises);
      _selectedTags.addAll(widget.existing!.tags);
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

    // Pedir series, reps/peso/tiempo/distancia según measurementType, descanso
    if (!mounted) return;
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController();
    final restCtrl = TextEditingController(text: '90');
    final durationCtrl = TextEditingController(text: '30');
    final distanceCtrl = TextEditingController();
    final mt = picked.measurementType;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(picked.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Measurement type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ZarpaColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mt.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ZarpaColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Series',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (mt == MeasurementType.reps || mt == MeasurementType.weight) ...[
                TextField(
                  controller: repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repeticiones',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (mt == MeasurementType.weight) ...[
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
              ],
              if (mt == MeasurementType.time) ...[
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duración (seg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (mt == MeasurementType.distance) ...[
                TextField(
                  controller: distanceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Distancia (metros)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
        durationSeconds: int.tryParse(durationCtrl.text),
        distanceMeters: double.tryParse(distanceCtrl.text.replaceAll(',', '.')),
        restSeconds: int.tryParse(restCtrl.text) ?? 90,
        photoUrl: picked.photoUrl,
        measurementType: mt,
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
        tags: _selectedTags.toList(),
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
          SnackBar(content: Text('Error al guardar la rutina: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Editar rutina' : 'Nueva rutina'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: ZarpaColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 36),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // --- Nombre ---
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la rutina',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Descripción ---
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // --- Etiquetas ---
                  const Text(
                    'Etiquetas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ZarpaColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        selectedColor: ZarpaColors.primary.withOpacity(0.15),
                        checkmarkColor: ZarpaColors.primary,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // --- Ejercicios header ---
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

                  // --- Lista de ejercicios ---
                  if (_exercises.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Añade ejercicios a la rutina.'),
                      ),
                    )
                  else
                    ..._exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ex = entry.value;
                      String detail;
                      switch (ex.measurementType) {
                        case MeasurementType.weight:
                          final w = ex.weightKg != null
                              ? '${ex.weightKg} kg'
                              : 'Sin peso';
                          detail = '${ex.sets}×${ex.reps}  ·  $w';
                        case MeasurementType.reps:
                          detail = '${ex.sets}×${ex.reps}';
                        case MeasurementType.time:
                          final secs = ex.durationSeconds ?? 30;
                          detail = '${ex.sets}×${secs}s';
                        case MeasurementType.distance:
                          final m = ex.distanceMeters ?? 0;
                          final d = m >= 1000
                              ? '${(m / 1000).toStringAsFixed(1)} km'
                              : '${m.toStringAsFixed(0)} m';
                          detail = '${ex.sets}×$d';
                      }
                      return Dismissible(
                        key: ValueKey('${ex.exerciseId}-$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: ZarpaColors.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() => _exercises.removeAt(index));
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor:
                                  ZarpaColors.primary.withOpacity(0.1),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: ZarpaColors.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              ex.exerciseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '$detail  ·  ${ex.restSeconds}s desc.',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              onPressed: () {
                                setState(() => _exercises.removeAt(index));
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
