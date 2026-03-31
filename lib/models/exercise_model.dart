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

class ExerciseModel {
  ExerciseModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.muscleGroup,
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
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
