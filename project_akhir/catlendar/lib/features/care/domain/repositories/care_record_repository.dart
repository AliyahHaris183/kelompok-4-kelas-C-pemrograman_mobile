import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';

/// Kontrak koleksi CARE_RECORD (LOG). Milik Orang 3.
///
/// Hanya create dan read. SENGAJA tidak ada update maupun delete (RULE-07).
/// Setiap query memuat owner_id (lihat docs/architecture.md).
abstract class CareRecordRepository {
  String newId();

  /// Menambah satu baris riwayat (create saja).
  Future<void> addRecord(CareRecord record);

  /// Menambah beberapa baris sekaligus dalam satu batch (layar Fill in grooming details).
  Future<void> addRecords(List<CareRecord> records);

  Stream<List<CareRecord>> watchRecordsByCat({
    required String ownerId,
    required String catId,
  });

  Stream<List<CareRecord>> watchRecordsByOwner(String ownerId);

  /// Aktivitas terakhir untuk satu jenis perawatan (performed_date terbesar), atau null.
  Future<CareRecord?> getLatestRecord({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
  });

  /// True jika sudah ada riwayat untuk jenis dan tanggal yang sama (mencegah duplikasi FR-45).
  Future<bool> hasRecordOn({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
    required DateTime performedDate,
  });
}
