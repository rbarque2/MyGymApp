import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/program_model.dart';
import '../models/routine_model.dart';
import '../repositories/programs_repository.dart';
import '../repositories/routines_repository.dart';
import '../repositories/workouts_repository.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';
import 'workout_screen.dart';

/// Paleta de gradientes para tarjetas de programa.
const _cardGradients = <List<Color>>[
  [Color(0xFF6EC6FF), Color(0xFF2196F3)], // 0 azul claro
  [Color(0xFFCE93D8), Color(0xFF9C27B0)], // 1 lavanda
  [Color(0xFF80CBC4), Color(0xFF009688)], // 2 menta
  [Color(0xFFFFCC80), Color(0xFFFF9800)], // 3 melocotón
  [Color(0xFFEF9A9A), Color(0xFFE53935)], // 4 coral
  [Color(0xFFA5D6A7), Color(0xFF43A047)], // 5 verde
];

/// Pantalla de catálogo de programas predefinidos.
class ProgramsSection extends StatefulWidget {
  const ProgramsSection({
    super.key,
    required this.ownerUid,
    required this.workoutsRepository,
    required this.settingsService,
    required this.routinesRepository,
  });

  final String ownerUid;
  final WorkoutsRepository workoutsRepository;
  final SettingsService settingsService;
  final RoutinesRepository routinesRepository;

  @override
  State<ProgramsSection> createState() => _ProgramsSectionState();
}

class _ProgramsSectionState extends State<ProgramsSection> {
  String _searchQuery = '';
  String? _tagFilter;
  final _searchCtrl = TextEditingController();
  final _repo = ProgramsRepository();
  List<ProgramModel> _programs = [];
  bool _loading = true;
  bool _importing = false;

  static const _filterTags = [
    'Fuerza',
    'Running',
    'HIIT',
    'Calistenia',
    'Movilidad',
    'Estiramientos',
    'Core',
  ];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final fromDb = await _repo.getPrograms();
    if (!mounted) return;
    setState(() {
      _programs = fromDb.isNotEmpty ? fromDb : programsCatalog.toList();
      _loading = false;
    });
  }

  Future<void> _importFromCsv() async {
    setState(() => _importing = true);
    try {
      final count = await _repo.importFromCsv();
      await _loadPrograms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count programas importados correctamente'),
          backgroundColor: const Color(0xFF43A047),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  /// Convierte ProgramModel → RoutineModel y lo guarda en Firestore.
  Future<void> _saveAsRoutine(ProgramModel program) async {
    final routine = RoutineModel(
      id: '',
      ownerUid: widget.ownerUid,
      name: program.title,
      description: program.description ?? program.subtitle,
      exercises: program.exercises
          .map((ex) => RoutineExercise(
                exerciseId: 'prog_${program.id}_${ex.order}',
                exerciseName: ex.name,
                sets: ex.sets,
                reps: ex.reps ?? 10,
                weightKg: ex.weightKg,
                durationSeconds: ex.durationSeconds,
                distanceMeters: ex.distanceMeters,
                restSeconds: ex.restSeconds,
                photoUrl: ex.gifUrl ?? ex.photoUrl,
                measurementType: ex.measurementType,
              ))
          .toList(),
      tags: program.tags,
    );
    await widget.routinesRepository.createRoutine(routine);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${program.title}" guardada como rutina'),
        backgroundColor: const Color(0xFF43A047),
      ),
    );
  }

  /// Convierte ProgramModel → RoutineModel y abre WorkoutScreen.
  void _startProgram(ProgramModel program) {
    final routine = RoutineModel(
      id: 'program_${program.id}',
      ownerUid: widget.ownerUid,
      name: program.title,
      description: program.description ?? program.subtitle,
      exercises: program.exercises
          .map((ex) => RoutineExercise(
                exerciseId: 'prog_${program.id}_${ex.order}',
                exerciseName: ex.name,
                sets: ex.sets,
                reps: ex.reps ?? 10,
                weightKg: ex.weightKg,
                durationSeconds: ex.durationSeconds,
                distanceMeters: ex.distanceMeters,
                restSeconds: ex.restSeconds,
                photoUrl: ex.gifUrl ?? ex.photoUrl,
                measurementType: ex.measurementType,
              ))
          .toList(),
      tags: program.tags,
    );

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProgramModel> _filtered() {
    var list = _programs;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(_searchQuery) ||
              (p.subtitle ?? '').toLowerCase().contains(_searchQuery) ||
              p.tags.any((t) => t.toLowerCase().contains(_searchQuery)))
          .toList();
    }
    if (_tagFilter != null) {
      list = list.where((p) => p.tags.contains(_tagFilter)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filtered();
    final hasFilter = _searchQuery.isNotEmpty || _tagFilter != null;

    return Column(
      children: [
        // ── Buscador + botón importar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Buscar programas...',
                    hintStyle: const TextStyle(
                        color: ZarpaColors.mutedLight, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, size: 20, color: ZarpaColors.muted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: ZarpaColors.surface,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ZarpaColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ZarpaColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: ZarpaColors.primary, width: 1.5),
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              // Botón importar CSV
              _importing
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: _importFromCsv,
                      icon: const Icon(Icons.cloud_download_outlined),
                      tooltip: 'Importar programas desde plantilla',
                      style: IconButton.styleFrom(
                        backgroundColor: ZarpaColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Filtros rápidos ──
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
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              ..._filterTags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      selected: _tagFilter == tag,
                      onSelected: (_) => setState(
                          () => _tagFilter = _tagFilter == tag ? null : tag),
                      selectedColor: ZarpaColors.primary.withOpacity(0.15),
                      checkmarkColor: ZarpaColors.primary,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Contenido ──
        Expanded(
          child: hasFilter ? _buildFilteredList(filtered) : _buildSections(),
        ),
      ],
    );
  }

  /// Vista filtrada — lista plana con tarjetas coloridas.
  Widget _buildFilteredList(List<ProgramModel> programs) {
    if (programs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search_off, size: 48, color: ZarpaColors.mutedLight),
            SizedBox(height: 8),
            Text('Sin resultados',
                style: TextStyle(color: ZarpaColors.muted, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: programs.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ProgramCard(
          program: programs[i],
          width: double.infinity,
          height: 160,
          onStart: _startProgram,
          onSaveAsRoutine: _saveAsRoutine,
        ),
      ),
    );
  }

  /// Vista por secciones con carrusel horizontal.
  Widget _buildSections() {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        _buildCategorySection(ProgramCategory.rapidos),
        _buildCategorySection(ProgramCategory.programas),
        _buildCategorySection(ProgramCategory.calentamientos),
        _buildCategorySection(ProgramCategory.estiramientos),
      ],
    );
  }

  Widget _buildCategorySection(ProgramCategory cat) {
    final items = _programs.where((p) => p.category == cat).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(cat.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                cat.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} entrenos',
                style: const TextStyle(
                  fontSize: 12,
                  color: ZarpaColors.mutedLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ProgramCard(
              program: items[i],
              width: 240,
              height: 180,
              onStart: _startProgram,
              onSaveAsRoutine: _saveAsRoutine,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Tarjeta de programa — estilo gradiente colorido
// ═══════════════════════════════════════════════════════════════

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.width,
    required this.height,
    required this.onStart,
    required this.onSaveAsRoutine,
  });
  final ProgramModel program;
  final double width;
  final double height;
  final void Function(ProgramModel) onStart;
  final Future<void> Function(ProgramModel) onSaveAsRoutine;

  List<Color> get _gradient =>
      _cardGradients[program.colorIndex % _cardGradients.length];

  String get _durationLabel {
    if (program.durationMin != null) return '${program.durationMin} min';
    if (program.weeks != null) return '${program.weeks} sem';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradient;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[1].withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Imagen de fondo o emoji fallback
            if (program.imageUrl != null && program.imageUrl!.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: program.imageUrl!.startsWith('assets/')
                        ? Image.asset(
                            program.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )
                        : Image.network(
                            program.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                  ),
                ),
              )
            else
              Positioned(
                right: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.15,
                  child: Text(
                    program.emoji,
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji + nivel
                  Row(
                    children: [
                      Text(program.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          program.level.label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Título
                  Text(
                    program.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  if (program.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      program.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Pill de duración con icono play
                  if (_durationLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _durationLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final colors = _gradient;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con gradiente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(program.emoji,
                            style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (program.subtitle != null)
                                Text(
                                  program.subtitle!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DetailChip(
                          icon: Icons.signal_cellular_alt,
                          label: program.level.label,
                          color: colors[1],
                        ),
                        if (program.durationMin != null)
                          _DetailChip(
                            icon: Icons.timer_outlined,
                            label: '${program.durationMin} min',
                          ),
                        if (program.weeks != null)
                          _DetailChip(
                            icon: Icons.calendar_today,
                            label: '${program.weeks} semanas',
                          ),
                        if (program.daysPerWeek != null)
                          _DetailChip(
                            icon: Icons.repeat,
                            label: '${program.daysPerWeek} días/sem',
                          ),
                        if (program.exerciseCount != null)
                          _DetailChip(
                            icon: Icons.fitness_center,
                            label: '${program.exerciseCount} ejercicios',
                          ),
                        if (program.equipment != null)
                          _DetailChip(
                            icon: Icons.inventory_2_outlined,
                            label: program.equipment!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tags
                    if (program.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: program.tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors[1].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors[1],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Lista de ejercicios ──
                    if (program.exercises.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, size: 18, color: ZarpaColors.foreground),
                          const SizedBox(width: 6),
                          Text(
                            '${program.exercises.length} ejercicios',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...program.exercises.map((ex) => _ExerciseTile(
                            exercise: ex,
                            accentColor: colors[1],
                          )),
                      const SizedBox(height: 8),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ZarpaColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ZarpaColors.border),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.construction,
                                size: 36, color: ZarpaColors.mutedLight),
                            SizedBox(height: 8),
                            Text(
                              'Próximamente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ZarpaColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Botón empezar programa
                    if (program.exercises.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onStart(program);
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(
                            'Empezar programa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors[1],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Botón guardar como rutina
                    if (program.exercises.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onSaveAsRoutine(program);
                          },
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: const Text(
                            'Guardar como rutina',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors[1],
                            side: BorderSide(color: colors[1]),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Botón cerrar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    this.color,
  });
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? ZarpaColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Tile de ejercicio dentro del detalle del programa
// ═══════════════════════════════════════════════════════════════

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.accentColor});
  final ProgramExercise exercise;
  final Color accentColor;

  IconData get _icon {
    switch (exercise.measurementType) {
      case MeasurementType.weight:
        return Icons.fitness_center;
      case MeasurementType.reps:
        return Icons.repeat;
      case MeasurementType.time:
        return Icons.timer_outlined;
      case MeasurementType.distance:
        return Icons.straighten;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZarpaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZarpaColors.border),
      ),
      child: Row(
        children: [
          // Número de orden
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${exercise.order}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Nombre + resumen
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZarpaColors.muted,
                  ),
                ),
                if (exercise.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    exercise.notes!,
                    style: TextStyle(
                      fontSize: 11,
                      color: accentColor.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Icono tipo
          Icon(_icon, size: 16, color: ZarpaColors.mutedLight),

          // Miniatura si hay foto
          if (exercise.photoUrl != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: exercise.photoUrl!.startsWith('assets/')
                  ? Image.asset(exercise.photoUrl!, width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20, color: ZarpaColors.mutedLight))
                  : Image.network(exercise.photoUrl!, width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20, color: ZarpaColors.mutedLight)),
            ),
          ],
        ],
      ),
    );
  }
}
