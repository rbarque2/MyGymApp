import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine_model.dart';

class RoutinesRepository {
  RoutinesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('routines');

  Stream<List<RoutineModel>> watchRoutines(String ownerUid) {
    return _col
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(RoutineModel.fromDoc).toList(growable: false));
  }

  Future<DocumentReference<Map<String, dynamic>>> createRoutine(
    RoutineModel routine,
  ) {
    return _col.add(routine.toCreateJson());
  }

  Future<void> updateRoutine(RoutineModel routine) {
    return _col.doc(routine.id).update(routine.toUpdateJson());
  }

  Future<void> deleteRoutine(String id) {
    return _col.doc(id).delete();
  }
}
