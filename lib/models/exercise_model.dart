import 'package:cloud_firestore/cloud_firestore.dart';

/// Grupos musculares disponibles.
enum MuscleGroup {
  chest('Pecho'),
  back('Espalda'),
  shoulders('Hombros'),
  biceps('Bíceps'),
  triceps('Tríceps'),
  legs('Piernas'),
  glutes('Glúteos'),
  abs('Abdominales'),
  cardio('Cardio'),
  fullBody('Cuerpo completo');

  const MuscleGroup(this.label);
  final String label;

  static MuscleGroup fromName(String name) =>
      MuscleGroup.values.firstWhere((e) => e.name == name, orElse: () => MuscleGroup.fullBody);
}

/// Categoría del ejercicio.
enum ExerciseCategory {
  warmup('Calentamiento', '🔥'),
  mobility('Movilidad', '🧘'),
  strength('Fuerza', '🏋️'),
  bodyweight('Peso corporal', '💪'),
  cardio('Cardio', '🏃'),
  hiit('HIIT', '⚡'),
  recovery('Recuperación', '🧊');

  const ExerciseCategory(this.label, this.icon);
  final String label;
  final String icon;

  static ExerciseCategory fromName(String name) =>
      ExerciseCategory.values.firstWhere((e) => e.name == name, orElse: () => ExerciseCategory.strength);
}

/// Cómo se mide el ejercicio.
enum MeasurementType {
  reps('Repeticiones'),
  weight('Peso + Reps'),
  time('Tiempo'),
  distance('Distancia');

  const MeasurementType(this.label);
  final String label;

  static MeasurementType fromName(String name) =>
      MeasurementType.values.firstWhere((e) => e.name == name, orElse: () => MeasurementType.weight);
}

class ExerciseModel {
  ExerciseModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.muscleGroup,
    this.category = ExerciseCategory.strength,
    this.measurementType = MeasurementType.weight,
    this.description,
    this.photoUrl,
    this.linkUrl,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String ownerUid;
  final String name;
  final MuscleGroup muscleGroup;
  final ExerciseCategory category;
  final MeasurementType measurementType;
  final String? description;
  final String? photoUrl;
  final String? linkUrl;
  final List<String> tags;
  final Timestamp? createdAt;

  factory ExerciseModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ExerciseModel(
      id: doc.id,
      ownerUid: data['ownerUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      muscleGroup: MuscleGroup.fromName(data['muscleGroup'] as String? ?? ''),
      category: ExerciseCategory.fromName(data['category'] as String? ?? 'strength'),
      measurementType: MeasurementType.fromName(data['measurementType'] as String? ?? 'weight'),
      description: data['description'] as String?,
      photoUrl: data['photoUrl'] as String?,
      linkUrl: data['linkUrl'] as String?,
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'ownerUid': ownerUid,
      'name': name,
      'muscleGroup': muscleGroup.name,
      'category': category.name,
      'measurementType': measurementType.name,
      'description': description,
      'photoUrl': photoUrl,
      'linkUrl': linkUrl,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup.name,
      'category': category.name,
      'measurementType': measurementType.name,
      'description': description,
      'photoUrl': photoUrl,
      'linkUrl': linkUrl,
      'tags': tags,
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? ownerUid,
    String? name,
    MuscleGroup? muscleGroup,
    ExerciseCategory? category,
    MeasurementType? measurementType,
    String? description,
    String? photoUrl,
    String? linkUrl,
    List<String>? tags,
    Timestamp? createdAt,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      category: category ?? this.category,
      measurementType: measurementType ?? this.measurementType,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
