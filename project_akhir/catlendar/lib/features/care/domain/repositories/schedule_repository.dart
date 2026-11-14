import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';

/// Kontrak koleksi SCHEDULE. Milik Orang 3.
/// Satu jadwal per jenis perawatan per kucing; jadwal diperbarui, bukan diduplikasi.
/// Query wajib memuat owner_id (lihat catatan di CatRepository).
abstract class ScheduleRepository {
  String newId();

  Stream<List<Schedule>> watchSchedulesByOwner(String ownerId);

  Stream<List<Schedule>> watchSchedulesByCat({
    required String ownerId,
    required String catId,
  });

  /// Jadwal yang sudah ada untuk jenis perawatan tertentu, atau null.
  Future<Schedule?> getSchedule({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
  });

  Future<void> createSchedule(Schedule schedule);

  /// Perbarui updated_at. Notifikasi lama harus dibatalkan oleh pemanggil
  /// (lihat LocalNotificationService) sebelum yang baru dijadwalkan.
  Future<void> updateSchedule(Schedule schedule);

  Future<void> deleteSchedule(String scheduleId);
}
