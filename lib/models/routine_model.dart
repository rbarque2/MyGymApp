import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise_model.dart';

/// Un ejercicio dentro de una rutina, con series/reps/peso objetivo.
class RoutineExercise {
  RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceMeters,
    this.restSeconds = 45,
    this.photoUrl,
    this.measurementType = MeasurementType.weight,
  });

  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weightKg;
  final int? durationSeconds;
  final double? distanceMeters;
  final int restSeconds;
  final String? photoUrl;
  final MeasurementType measurementType;

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 45,
      photoUrl: map['photoUrl'] as String?,
      measurementType: MeasurementType.fromName(map['measurementType'] as String? ?? 'weight'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'restSeconds': restSeconds,
      'photoUrl': photoUrl,
      'measurementType': measurementType.name,
    };
  }

  RoutineExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    double? distanceMeters,
    int? restSeconds,
    String? photoUrl,
    MeasurementType? measurementType,
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      restSeconds: restSeconds ?? this.restSeconds,
      photoUrl: photoUrl ?? this.photoUrl,
      measurementType: measurementType ?? this.measurementType,
    );
  }
}

class RoutineModel {
  RoutineModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    this.description,
    required this.exercises,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String ownerUid;
  final String name;
  final String? description;
  final List<RoutineExercise> exercises;
  final List<String> tags;
  final Timestamp? createdAt;

  factory RoutineModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawExercises = data['exercises'] as List<dynamic>? ?? [];
    return RoutineModel(
      id: doc.id,
      ownerUid: data['ownerUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      exercises: rawExercises
          .map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'ownerUid': ownerUid,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'tags': tags,
    };
  }

  RoutineModel copyWith({
    String? id,
    String? ownerUid,
    String? name,
    String? description,
    List<RoutineExercise>? exercises,
    List<String>? tags,
    Timestamp? createdAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
