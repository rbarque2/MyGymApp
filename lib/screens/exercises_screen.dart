import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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
                  value: selectedGroup,
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

  /// Obtiene los nombres de ejercicios existentes para evitar duplicados.
  Future<Set<String>> _getExistingNames() async {
    final existing = await widget.exercisesRepository
        .watchExercises(widget.ownerUid)
        .first;
    return existing.map((e) => e.name.toLowerCase()).toSet();
  }

  Future<void> _deleteAllExercises() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar todos'),
        content: const Text('¿Eliminar todos los ejercicios? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar todos'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final exercises = await widget.exercisesRepository
          .watchExercises(widget.ownerUid)
          .first;
      for (final ex in exercises) {
        await widget.exercisesRepository.deleteExercise(ex.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${exercises.length} ejercicios eliminados.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  Future<void> _importFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) return;

      final csvString = utf8.decode(bytes);
      final lines = const LineSplitter().convert(csvString);

      if (lines.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo CSV está vacío.')),
          );
        }
        return;
      }

      final existingNames = await _getExistingNames();
      int count = 0;
      int skipped = 0;

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(',');
        if (parts.length < 2) continue;

        final name = parts[0].trim();
        final muscleGroupStr = parts[1].trim();
        final description = parts.length > 2 ? parts[2].trim() : null;

        if (name.isEmpty) continue;

        // Evitar duplicados
        if (existingNames.contains(name.toLowerCase())) {
          skipped++;
          continue;
        }

        final muscleGroup = MuscleGroup.fromName(muscleGroupStr);

        await widget.exercisesRepository.createExercise(
          ExerciseModel(
            id: '',
            ownerUid: widget.ownerUid,
            name: name,
            muscleGroup: muscleGroup,
            description: (description != null && description.isNotEmpty)
                ? description
                : null,
          ),
        );
        existingNames.add(name.toLowerCase());
        count++;
      }

      if (mounted) {
        final msg = '$count ejercicios importados.'
            '${skipped > 0 ? ' $skipped duplicados omitidos.' : ''}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
  }

  Future<void> _importDefaultTemplate() async {
    try {
      final csvString = await rootBundle.loadString('assets/plantilla_ejercicios.csv');
      final lines = const LineSplitter().convert(csvString);

      final existingNames = await _getExistingNames();
      int count = 0;
      int skipped = 0;

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(',');
        if (parts.length < 2) continue;

        final name = parts[0].trim();
        final muscleGroupStr = parts[1].trim();
        final description = parts.length > 2 ? parts[2].trim() : null;

        if (name.isEmpty) continue;

        // Evitar duplicados
        if (existingNames.contains(name.toLowerCase())) {
          skipped++;
          continue;
        }

        await widget.exercisesRepository.createExercise(
          ExerciseModel(
            id: '',
            ownerUid: widget.ownerUid,
            name: name,
            muscleGroup: MuscleGroup.fromName(muscleGroupStr),
            description: (description != null && description.isNotEmpty)
                ? description
                : null,
          ),
        );
        existingNames.add(name.toLowerCase());
        count++;
      }

      if (mounted) {
        final msg = '$count ejercicios cargados.'
            '${skipped > 0 ? ' $skipped duplicados omitidos.' : ''}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar plantilla: $e')),
        );
      }
    }
  }

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Cargar plantilla predeterminada'),
              subtitle: const Text('21 ejercicios básicos de gimnasio'),
              onTap: () {
                Navigator.pop(ctx);
                _importDefaultTemplate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Importar desde archivo CSV'),
              subtitle: const Text('Formato: name,muscleGroup,description'),
              onTap: () {
                Navigator.pop(ctx);
                _importFromCsv();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar todos los ejercicios',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Elimina todos tus ejercicios'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteAllExercises();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de acciones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.upload_file),
                tooltip: 'Importar ejercicios',
                onPressed: _showImportOptions,
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
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Error al cargar ejercicios:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
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
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _showImportOptions,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Importar ejercicios'),
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
