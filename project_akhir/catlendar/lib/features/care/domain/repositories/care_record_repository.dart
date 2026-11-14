import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';

/// Kontrak koleksi CARE_RECORD (LOG). Milik Orang 3.
///
/// Hanya create dan read. SENGAJA tidak ada update maupun delete.
/// Query wajib memuat owner_id (lihat catatan di CatRepository).
/// Tanggal terakhir per jenis perawatan didapat dengan query performed_date.
abstract class CareRecordRepository {
  String newId();

  Future<void> addRecord(CareRecord record);

  /// Menyimpan beberapa baris sekaligus (layar Fill in last grooming details).
  Future<void> addRecords(List<CareRecord> records);

  Stream<List<CareRecord>> watchRecordsByCat({
    required String ownerId,
    required String catId,
  });

  Stream<List<CareRecord>> watchRecordsByOwner(String ownerId);

  /// Aktivitas terakhir untuk satu jenis perawatan (performed_date terbesar).
  Future<CareRecord?> getLatestRecord({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
  });
}
