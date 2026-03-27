import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workout_session_model.dart';

class WorkoutsRepository {
  WorkoutsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('workouts');

  Stream<List<WorkoutSessionModel>> watchWorkouts(String ownerUid) {
    return _col
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(WorkoutSessionModel.fromDoc).toList(growable: false));
  }

  /// Últimas N sesiones para gráficas de progreso.
  Future<List<WorkoutSessionModel>> getRecentWorkouts(
    String ownerUid, {
    int limit = 30,
  }) async {
    final snap = await _col
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map(WorkoutSessionModel.fromDoc)
        .toList(growable: false);
  }

  Future<DocumentReference<Map<String, dynamic>>> createWorkout(
    WorkoutSessionModel session,
  ) {
    return _col.add(session.toCreateJson());
  }

  Future<void> finishWorkout(
    String id, {
    required List<WorkoutSet> sets,
    required int durationMinutes,
    String? notes,
  }) {
    final data = <String, dynamic>{
      'sets': sets.map((s) => s.toMap()).toList(),
      'finishedAt': FieldValue.serverTimestamp(),
      'durationMinutes': durationMinutes,
    };
    if (notes != null) data['notes'] = notes;
    return _col.doc(id).update(data);
  }

  Future<void> deleteWorkout(String id) {
    return _col.doc(id).delete();
  }
}
