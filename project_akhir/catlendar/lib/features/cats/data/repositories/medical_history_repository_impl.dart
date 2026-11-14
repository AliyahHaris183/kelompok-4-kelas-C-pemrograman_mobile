import 'package:catlendar/features/cats/data/datasources/medical_history_firestore_data_source.dart';
import 'package:catlendar/features/cats/data/models/medical_history.dart';
import 'package:catlendar/features/cats/domain/repositories/medical_history_repository.dart';

/// Scaffold. Hanya newId() yang berfungsi. Sisanya TODO Orang 2.
class MedicalHistoryRepositoryImpl implements MedicalHistoryRepository {
  MedicalHistoryRepositoryImpl(this.dataSource);

  final MedicalHistoryFirestoreDataSource dataSource;

  @override
  String newId() => dataSource.newId();

  // TODO(Orang 2): where owner_id == ownerId DAN cat_id == catId.
  @override
  Stream<List<MedicalHistory>> watchHistoryByCat({
    required String ownerId,
    required String catId,
  }) =>
      throw UnimplementedError('TODO(Orang 2): watchHistoryByCat');

  // TODO(Orang 2): versi sekali baca dari query yang sama.
  @override
  Future<List<MedicalHistory>> getHistoryByCat({
    required String ownerId,
    required String catId,
  }) =>
      throw UnimplementedError('TODO(Orang 2): getHistoryByCat');

  // TODO(Orang 2): set dokumen baru.
  @override
  Future<void> addHistory(MedicalHistory history) =>
      throw UnimplementedError('TODO(Orang 2): addHistory');

  // TODO(Orang 2): update dengan updated_at baru.
  @override
  Future<void> updateHistory(MedicalHistory history) =>
      throw UnimplementedError('TODO(Orang 2): updateHistory');

  // TODO(Orang 2): hapus dokumen (diizinkan Security Rules).
  @override
  Future<void> deleteHistory(String historyId) =>
      throw UnimplementedError('TODO(Orang 2): deleteHistory');
}
