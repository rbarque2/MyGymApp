import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/exercise_model.dart';
import '../repositories/exercises_repository.dart';
import '../theme/zarpafit_theme.dart';

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

  static const _availableTags = [
    'Pierna', 'Espalda', 'Pecho', 'Hombros', 'Brazos',
    'Core', 'HIIT', 'Cardio', 'Fuerza', 'Movilidad', 'Full Body',
  ];

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final gifCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    MuscleGroup selectedGroup = MuscleGroup.chest;
    final selectedTags = <String>{};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nuevo ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const Text('Etiquetas',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZarpaColors.muted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _availableTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (sel) {
                        setDialogState(() {
                          if (sel) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: ZarpaColors.primary.withOpacity(0.15),
                      checkmarkColor: ZarpaColors.primary,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
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
                const SizedBox(height: 12),
                TextField(
                  controller: gifCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de imagen / GIF (opcional)',
                    hintText: 'https://ejemplo.com/ejercicio.gif',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                if (gifCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      gifCtrl.text,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: linkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enlace externo (opcional)',
                    hintText: 'https://youtube.com/watch?v=...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
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
                    photoUrl: gifCtrl.text.trim().isEmpty
                        ? null
                        : gifCtrl.text.trim(),
                    linkUrl: linkCtrl.text.trim().isEmpty
                        ? null
                        : linkCtrl.text.trim(),
                    tags: selectedTags.toList(),
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

  void _showEditDialog(ExerciseModel exercise) {
    final nameCtrl = TextEditingController(text: exercise.name);
    final descCtrl = TextEditingController(text: exercise.description ?? '');
    final photoCtrl = TextEditingController(text: exercise.photoUrl ?? '');
    final linkCtrl = TextEditingController(text: exercise.linkUrl ?? '');
    var selectedGroup = exercise.muscleGroup;
    final selectedTags = <String>{...exercise.tags};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto preview
                Center(
                  child: GestureDetector(
                    onTap: () => setDialogState(() {}),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: photoCtrl.text.isNotEmpty
                          ? Image.network(
                              photoCtrl.text,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPhotoPlaceholder(),
                            )
                          : _buildPhotoPlaceholder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                const Text('Etiquetas',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZarpaColors.muted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _availableTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (sel) {
                        setDialogState(() {
                          if (sel) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: ZarpaColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: ZarpaColors.primary,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
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
                const SizedBox(height: 12),
                TextField(
                  controller: photoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de imagen / GIF (opcional)',
                    hintText: 'https://ejemplo.com/ejercicio.gif',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                if (photoCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoCtrl.text,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: linkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enlace externo (opcional)',
                    hintText: 'https://youtube.com/watch?v=...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
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
                final updated = exercise.copyWith(
                  name: name,
                  muscleGroup: selectedGroup,
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  photoUrl: photoCtrl.text.trim().isEmpty
                      ? null
                      : photoCtrl.text.trim(),
                  linkUrl: linkCtrl.text.trim().isEmpty
                      ? null
                      : linkCtrl.text.trim(),
                  tags: selectedTags.toList(),
                );
                await widget.exercisesRepository.updateExercise(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZarpaColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 32, color: ZarpaColors.muted),
          SizedBox(height: 4),
          Text('Foto', style: TextStyle(color: ZarpaColors.muted, fontSize: 12)),
        ],
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
        final photoUrl = parts.length > 3 ? parts[3].trim() : null;
        final linkUrl = parts.length > 4 ? parts[4].trim() : null;
        final tagsStr = parts.length > 5 ? parts[5].trim() : null;
        final tags = (tagsStr != null && tagsStr.isNotEmpty)
            ? tagsStr.split('|').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : <String>[];

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
            photoUrl: (photoUrl != null && photoUrl.isNotEmpty)
                ? photoUrl
                : null,
            linkUrl: (linkUrl != null && linkUrl.isNotEmpty)
                ? linkUrl
                : null,
            tags: tags,
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
        final photoUrl = parts.length > 3 ? parts[3].trim() : null;
        final linkUrl = parts.length > 4 ? parts[4].trim() : null;
        final tagsStr = parts.length > 5 ? parts[5].trim() : null;
        final tags = (tagsStr != null && tagsStr.isNotEmpty)
            ? tagsStr.split('|').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : <String>[];

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
            photoUrl: (photoUrl != null && photoUrl.isNotEmpty)
                ? photoUrl
                : null,
            linkUrl: (linkUrl != null && linkUrl.isNotEmpty)
                ? linkUrl
                : null,
            tags: tags,
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

  void _showEditPhotoDialog(ExerciseModel exercise) {
    final urlCtrl = TextEditingController(text: exercise.photoUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cambiar imagen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de imagen / GIF',
                    hintText: 'https://ejemplo.com/ejercicio.gif',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                if (urlCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      urlCtrl.text,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text('No se pudo cargar',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (exercise.photoUrl != null)
              TextButton(
                onPressed: () async {
                  await widget.exercisesRepository.updateExercise(
                    exercise.copyWith(photoUrl: ''),
                  );
                  // Workaround: Firestore doesn't support setting null, so
                  // we update the field to null via direct update.
                  await widget.exercisesRepository.removePhotoUrl(exercise.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Quitar foto',
                    style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final url = urlCtrl.text.trim();
                await widget.exercisesRepository.updateExercise(
                  exercise.copyWith(
                    photoUrl: url.isEmpty ? null : url,
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGifDialog(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                exercise.name,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                exercise.photoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No se pudo cargar el GIF'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
              subtitle: const Text('Formato: name,muscleGroup,description,photoUrl,linkUrl,tags'),
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
    return Scaffold(
      backgroundColor: ZarpaColors.surface,
      body: Column(
        children: [
          // Barra de filtros
          Container(
            color: Colors.white,
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
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showEditDialog(ex),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Foto
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ex.photoUrl != null
                                    ? Image.network(
                                        ex.photoUrl!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) =>
                                                _ExercisePlaceholder(
                                                    label: ex.muscleGroup
                                                        .label),
                                      )
                                    : _ExercisePlaceholder(
                                        label: ex.muscleGroup.label),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ex.muscleGroup.label +
                                          (ex.description != null
                                              ? ' · ${ex.description}'
                                              : ''),
                                      style: const TextStyle(
                                        color: ZarpaColors.muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (ex.tags.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: ex.tags.map((tag) =>
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
                                                fontSize: 11,
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
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: ZarpaColors.primary, size: 20),
                                tooltip: 'Editar',
                                onPressed: () => _showEditDialog(ex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.grey, size: 20),
                                tooltip: 'Eliminar',
                                onPressed: () => _deleteExercise(ex),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_exercise',
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExercisePlaceholder extends StatelessWidget {
  const _ExercisePlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZarpaColors.border),
      ),
      child: Center(
        child: Text(
          label[0],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ZarpaColors.muted,
          ),
        ),
      ),
    );
  }
}
