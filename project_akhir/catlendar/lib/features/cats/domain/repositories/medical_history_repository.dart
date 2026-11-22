import 'package:catlendar/features/cats/data/models/medical_history.dart';

/// Kontrak koleksi MEDICAL_HISTORY. Milik Orang 2.
/// Query wajib memuat owner_id (lihat catatan di CatRepository).
abstract class MedicalHistoryRepository {
  String newId();

  Stream<List<MedicalHistory>> watchHistoryByCat({
    required String ownerId,
    required String catId,
  });

  Future<List<MedicalHistory>> getHistoryByCat({
    required String ownerId,
    required String catId,
  });

  Future<void> addHistory(MedicalHistory history);
  Future<void> updateHistory(MedicalHistory history);
  Future<void> deleteHistory(String historyId);
}
