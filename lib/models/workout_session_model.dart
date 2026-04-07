import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise_model.dart';

/// Una serie realizada durante un entrenamiento.
class WorkoutSet {
  WorkoutSet({
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceMeters,
    this.completed = false,
    this.measurementType = MeasurementType.weight,
  });

  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  int reps;
  double? weightKg;
  int? durationSeconds;
  double? distanceMeters;
  bool completed;
  final MeasurementType measurementType;

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      completed: map['completed'] as bool? ?? false,
      measurementType: MeasurementType.fromName(map['measurementType'] as String? ?? 'weight'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'completed': completed,
      'measurementType': measurementType.name,
    };
  }
}

/// Una sesión de entrenamiento completa.
class WorkoutSessionModel {
  WorkoutSessionModel({
    required this.id,
    required this.ownerUid,
    required this.routineId,
    required this.routineName,
    required this.sets,
    this.startedAt,
    this.finishedAt,
    this.durationMinutes,
    this.notes,
  });

  final String id;
  final String ownerUid;
  final String routineId;
  final String routineName;
  final List<WorkoutSet> sets;
  final Timestamp? startedAt;
  final Timestamp? finishedAt;
  final int? durationMinutes;
  final String? notes;

  factory WorkoutSessionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawSets = data['sets'] as List<dynamic>? ?? [];
    return WorkoutSessionModel(
      id: doc.id,
      ownerUid: data['ownerUid'] as String? ?? '',
      routineId: data['routineId'] as String? ?? '',
      routineName: data['routineName'] as String? ?? '',
      sets: rawSets
          .map((e) => WorkoutSet.fromMap(e as Map<String, dynamic>))
          .toList(),
      startedAt: data['startedAt'] as Timestamp?,
      finishedAt: data['finishedAt'] as Timestamp?,
      durationMinutes: (data['durationMinutes'] as num?)?.toInt(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'ownerUid': ownerUid,
      'routineId': routineId,
      'routineName': routineName,
      'sets': sets.map((s) => s.toMap()).toList(),
      'startedAt': startedAt ?? FieldValue.serverTimestamp(),
      'finishedAt': finishedAt,
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }

  /// Volumen total = sum(reps * peso) de todas las series completadas.
  double get totalVolume {
    double vol = 0;
    for (final s in sets) {
      if (s.completed && s.weightKg != null) {
        vol += s.reps * s.weightKg!;
      }
    }
    return vol;
  }

  int get completedSets => sets.where((s) => s.completed).length;
}
