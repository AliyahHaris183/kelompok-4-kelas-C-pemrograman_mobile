import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/features/cats/data/datasources/medical_history_firestore_data_source.dart';
import 'package:catlendar/features/cats/data/models/medical_history.dart';
import 'package:catlendar/features/cats/domain/repositories/medical_history_repository.dart';

class MedicalHistoryRepositoryImpl implements MedicalHistoryRepository {
  MedicalHistoryRepositoryImpl(this.dataSource);

  final MedicalHistoryFirestoreDataSource dataSource;

  @override
  String newId() => dataSource.newId();

  @override
  Stream<List<MedicalHistory>> watchHistoryByCat({
    required String ownerId,
    required String catId,
  }) {
    return dataSource.collection
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .where(FirestoreFields.catId, isEqualTo: catId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicalHistory.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<List<MedicalHistory>> getHistoryByCat({
    required String ownerId,
    required String catId,
  }) async {
    final snapshot = await dataSource.collection
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .where(FirestoreFields.catId, isEqualTo: catId)
        .get();

    return snapshot.docs
        .map((doc) => MedicalHistory.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addHistory(MedicalHistory history) async {
    await dataSource.collection
        .doc(history.historyId)
        .set(history.toFirestore());
  }

  @override
  Future<void> updateHistory(MedicalHistory history) async {
    final updateData = history.toFirestore();
    updateData.remove(FirestoreFields.ownerId);
    updateData.remove(FirestoreFields.catId);
    updateData[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();

    await dataSource.collection.doc(history.historyId).update(updateData);
  }

  @override
  Future<void> deleteHistory(String historyId) async {
    await dataSource.collection.doc(historyId).delete();
  }
}
