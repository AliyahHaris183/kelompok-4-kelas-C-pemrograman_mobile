import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';
import 'package:catlendar/features/care/data/datasources/care_record_firestore_data_source.dart';
import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/domain/repositories/care_record_repository.dart';

/// Implementasi CARE_RECORD di Firestore. Hanya create dan read.
///
/// Query tidak memakai orderBy agar tidak butuh composite index; pengurutan
/// dilakukan di Dart. Data per pengguna kecil, jadi biayanya dapat diabaikan.
class CareRecordRepositoryImpl implements CareRecordRepository {
  CareRecordRepositoryImpl(this.dataSource);

  final CareRecordFirestoreDataSource dataSource;

  CollectionReference<Map<String, dynamic>> get _col => dataSource.collection;

  @override
  String newId() => dataSource.newId();

  @override
  Future<void> addRecord(CareRecord record) =>
      _col.doc(record.careRecordId).set(record.toMap());

  @override
  Future<void> addRecords(List<CareRecord> records) async {
    if (records.isEmpty) return;
    final batch = _col.firestore.batch();
    for (final record in records) {
      batch.set(_col.doc(record.careRecordId), record.toMap());
    }
    await batch.commit();
  }

  @override
  Stream<List<CareRecord>> watchRecordsByCat({
    required String ownerId,
    required String catId,
  }) {
    return _col
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .where(FirestoreFields.catId, isEqualTo: catId)
        .snapshots()
        .map((snap) => _sorted(snap.docs));
  }

  @override
  Stream<List<CareRecord>> watchRecordsByOwner(String ownerId) {
    return _col
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .snapshots()
        .map((snap) => _sorted(snap.docs));
  }

  @override
  Future<CareRecord?> getLatestRecord({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
  }) async {
    final snap = await _col
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .where(FirestoreFields.catId, isEqualTo: catId)
        .where(FirestoreFields.careType, isEqualTo: careType.value)
        .where(FirestoreFields.customName, isEqualTo: customName)
        .get();
    final records = _sorted(snap.docs);
    return records.isEmpty ? null : records.first;
  }

  @override
  Future<bool> hasRecordOn({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
    required DateTime performedDate,
  }) async {
    final snap = await _col
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .where(FirestoreFields.catId, isEqualTo: catId)
        .where(FirestoreFields.careType, isEqualTo: careType.value)
        .where(FirestoreFields.customName, isEqualTo: customName)
        .where(
          FirestoreFields.performedDate,
          isEqualTo: dateOnlyToTimestamp(performedDate),
        )
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Urut dari performed_date terbaru (lalu created_at terbaru).
  List<CareRecord> _sorted(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final records = docs.map(CareRecord.fromFirestore).toList();
    records.sort((a, b) {
      final byDate = b.performedDate.compareTo(a.performedDate);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
    return records;
  }
}
