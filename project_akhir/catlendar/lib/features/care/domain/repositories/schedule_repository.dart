import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';

/// Kontrak koleksi SCHEDULE. Milik Orang 3.
/// Satu jadwal per jenis perawatan per kucing; jadwal diperbarui, bukan diduplikasi.
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

  /// Menimpa dokumen dengan nilai terbaru (termasuk updated_at).
  Future<void> updateSchedule(Schedule schedule);

  Future<void> deleteSchedule(String scheduleId);
}
