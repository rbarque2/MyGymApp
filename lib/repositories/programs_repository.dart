import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/program_model.dart';

class ProgramsRepository {
  ProgramsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('programs');

  /// Observa todos los programas del catálogo en Firestore.
  Stream<List<ProgramModel>> watchPrograms() {
    return _col.orderBy('category').snapshots().map((snap) => snap.docs
        .map((d) => ProgramModel.fromMap(d.data()))
        .toList(growable: false));
  }

  /// Lee todos los programas una vez.
  Future<List<ProgramModel>> getPrograms() async {
    final snap = await _col.orderBy('category').get();
    return snap.docs
        .map((d) => ProgramModel.fromMap(d.data()))
        .toList(growable: false);
  }

  /// Importa programas desde el CSV de la plantilla.
  /// Para cada programa: si existe (mismo `id`), lo borra primero y crea el nuevo.
  Future<int> importFromCsv() async {
    // 1. Leer CSV de programas
    final csvPrograms =
        await rootBundle.loadString('assets/plantilla_programas.csv');
    final rows = csvPrograms
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (rows.isEmpty) return 0;

    // Detectar separador (primera fila = header)
    final sep = rows[0].contains(';') ? ';' : ',';

    // Parsear programas (saltar header)
    final programs = <ProgramModel>[];
    for (var i = 1; i < rows.length; i++) {
      final cols = rows[i].split(sep);
      if (cols.isEmpty || cols[0].trim().isEmpty) continue;
      programs.add(ProgramModel.fromCsvRow(cols));
    }

    // 2. Leer CSV de ejercicios por programa (si existe)
    final exercisesByProgram = <String, List<ProgramExercise>>{};
    try {
      final csvExercises = await rootBundle
          .loadString('assets/plantilla_ejercicios_programa.csv');
      final exRows = csvExercises
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (exRows.length > 1) {
        final exSep = exRows[0].contains(';') ? ';' : ',';
        for (var i = 1; i < exRows.length; i++) {
          final cols = exRows[i].split(exSep);
          if (cols.isEmpty || cols[0].trim().isEmpty) continue;
          final programId = cols[0].trim();
          final ex = ProgramExercise.fromCsvRow(cols);
          exercisesByProgram.putIfAbsent(programId, () => []).add(ex);
        }
      }
    } catch (_) {
      // CSV de ejercicios no existe, se sigue sin ejercicios
    }

    // 3. Asignar ejercicios a programas
    final fullPrograms = programs.map((p) {
      final exs = exercisesByProgram[p.id];
      if (exs != null && exs.isNotEmpty) {
        exs.sort((a, b) => a.order.compareTo(b.order));
        return p.withExercises(exs);
      }
      // Buscar ejercicios en el catálogo hardcoded como fallback
      final catalogMatch = programsCatalog.where((c) => c.id == p.id);
      if (catalogMatch.isNotEmpty && catalogMatch.first.exercises.isNotEmpty) {
        return p.withExercises(catalogMatch.first.exercises);
      }
      return p;
    }).toList();

    // 4. Upsert en Firestore: borrar existente → crear nuevo
    final batch = _firestore.batch();
    // Obtener los IDs existentes
    final existingSnap = await _col.get();
    final existingByProgramId = <String, String>{};
    for (final doc in existingSnap.docs) {
      final data = doc.data();
      final id = data['id'] as String? ?? '';
      if (id.isNotEmpty) existingByProgramId[id] = doc.id;
    }

    for (final p in fullPrograms) {
      // Eliminar duplicado si existe
      final existingDocId = existingByProgramId[p.id];
      if (existingDocId != null) {
        batch.delete(_col.doc(existingDocId));
      }
      // Crear nuevo
      batch.set(_col.doc(p.id), p.toMap());
    }

    await batch.commit();
    return fullPrograms.length;
  }
}
