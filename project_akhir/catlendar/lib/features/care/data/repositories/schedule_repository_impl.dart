import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/features/care/data/datasources/schedule_firestore_data_source.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/domain/repositories/schedule_repository.dart';

/// Implementasi SCHEDULE di Firestore. Semua query memuat owner_id (Security Rules).
class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this.dataSource);

  final ScheduleFirestoreDataSource dataSource;

  CollectionReference<Map<String, dynamic>> get _col => dataSource.collection;

  @override
  String newId() => dataSource.newId();

  @override
  Stream<List<Schedule>> watchSchedulesByOwner(String ownerId) {
    return _col
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .snapshots()
        .map((snap) => _mapDocs(snap.docs));
  }

  @override
  Stream<List<Schedule>> watchSchedulesByCat({
    required String ownerId,
    required String catId,
  }) {
    return _col
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .where(FirestoreFields.catId, isEqualTo: catId)
        .snapshots()
        .map((snap) => _mapDocs(snap.docs));
  }

  @override
  Future<Schedule?> getSchedule({
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
    final matches = _mapDocs(snap.docs);
    for (final schedule in matches) {
      if (schedule.isActive) return schedule;
    }
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<void> createSchedule(Schedule schedule) =>
      _col.doc(schedule.scheduleId).set(schedule.toMap());

  @override
  Future<void> updateSchedule(Schedule schedule) =>
      _col.doc(schedule.scheduleId).set(schedule.toMap());

  @override
  Future<void> deleteSchedule(String scheduleId) =>
      _col.doc(scheduleId).delete();

  List<Schedule> _mapDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final schedules = docs.map(Schedule.fromFirestore).toList();
    schedules.sort((a, b) => a.nextDate.compareTo(b.nextDate));
    return schedules;
  }
}
