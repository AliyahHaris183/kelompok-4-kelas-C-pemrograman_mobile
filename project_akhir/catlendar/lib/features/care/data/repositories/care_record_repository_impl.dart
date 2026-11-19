import 'package:catlendar/features/care/data/datasources/care_record_firestore_data_source.dart';
import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/domain/repositories/care_record_repository.dart';

/// Scaffold. Hanya newId() yang berfungsi. Sisanya TODO Orang 3.
/// Jangan menambahkan update atau delete: CARE_RECORD adalah log.
class CareRecordRepositoryImpl implements CareRecordRepository {
  CareRecordRepositoryImpl(this.dataSource);

  final CareRecordFirestoreDataSource dataSource;

  @override
  String newId() => dataSource.newId();

  // TODO(Orang 3): tambah dokumen baru (create saja).
  @override
  Future<void> addRecord(CareRecord record) =>
      throw UnimplementedError('TODO(Orang 3): addRecord');

  // TODO(Orang 3): WriteBatch, satu dokumen baru per aktivitas.
  @override
  Future<void> addRecords(List<CareRecord> records) =>
      throw UnimplementedError('TODO(Orang 3): addRecords');

  // TODO(Orang 3): where owner_id == ownerId DAN cat_id == catId.
  @override
  Stream<List<CareRecord>> watchRecordsByCat({
    required String ownerId,
    required String catId,
  }) =>
      throw UnimplementedError('TODO(Orang 3): watchRecordsByCat');

  // TODO(Orang 3): where owner_id == ownerId.
  @override
  Stream<List<CareRecord>> watchRecordsByOwner(String ownerId) =>
      throw UnimplementedError('TODO(Orang 3): watchRecordsByOwner');

  // TODO(Orang 3): query + orderBy performed_date desc + limit 1. Orderby bersama
  // filter equality membutuhkan composite index (lihat docs/architecture.md).
  @override
  Future<CareRecord?> getLatestRecord({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
  }) =>
      throw UnimplementedError('TODO(Orang 3): getLatestRecord');
}
