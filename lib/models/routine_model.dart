import 'package:cloud_firestore/cloud_firestore.dart';

/// Un ejercicio dentro de una rutina, con series/reps/peso objetivo.
class RoutineExercise {
  RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds = 90,
    this.photoUrl,
  });

  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weightKg;
  final int restSeconds;
  final String? photoUrl;

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 90,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'restSeconds': restSeconds,
      'photoUrl': photoUrl,
    };
  }

  RoutineExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weightKg,
    int? restSeconds,
    String? photoUrl,
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      restSeconds: restSeconds ?? this.restSeconds,
      photoUrl: photoUrl ?? this.photoUrl,
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
