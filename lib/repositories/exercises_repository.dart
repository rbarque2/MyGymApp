import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exercise_model.dart';

class ExercisesRepository {
  ExercisesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('exercises');

  Stream<List<ExerciseModel>> watchExercises(String ownerUid) {
    return _col
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map(ExerciseModel.fromDoc).toList(growable: false));
  }

  Stream<List<ExerciseModel>> watchExercisesByMuscle(
    String ownerUid,
    MuscleGroup muscleGroup,
  ) {
    return _col
        .where('ownerUid', isEqualTo: ownerUid)
        .where('muscleGroup', isEqualTo: muscleGroup.name)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map(ExerciseModel.fromDoc).toList(growable: false));
  }

  Future<DocumentReference<Map<String, dynamic>>> createExercise(
    ExerciseModel exercise,
  ) {
    return _col.add(exercise.toCreateJson());
  }

  Future<void> updateExercise(ExerciseModel exercise) {
    return _col.doc(exercise.id).update(exercise.toUpdateJson());
  }

  Future<void> deleteExercise(String id) {
    return _col.doc(id).delete();
  }
}
