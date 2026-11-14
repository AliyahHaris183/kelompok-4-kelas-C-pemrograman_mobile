import 'package:catlendar/features/care/data/datasources/schedule_firestore_data_source.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/domain/repositories/schedule_repository.dart';

/// Scaffold. Hanya newId() yang berfungsi. Sisanya TODO Orang 3.
class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this.dataSource);

  final ScheduleFirestoreDataSource dataSource;

  @override
  String newId() => dataSource.newId();

  // TODO(Orang 3): where owner_id == ownerId (untuk kalender dan Summary).
  @override
  Stream<List<Schedule>> watchSchedulesByOwner(String ownerId) =>
      throw UnimplementedError('TODO(Orang 3): watchSchedulesByOwner');

  // TODO(Orang 3): where owner_id == ownerId DAN cat_id == catId.
  @override
  Stream<List<Schedule>> watchSchedulesByCat({
    required String ownerId,
    required String catId,
  }) =>
      throw UnimplementedError('TODO(Orang 3): watchSchedulesByCat');

  // TODO(Orang 3): cari jadwal sejenis (cat_id + care_type [+ custom_name]).
  @override
  Future<Schedule?> getSchedule({
    required String ownerId,
    required String catId,
    required CareType careType,
    String? customName,
  }) =>
      throw UnimplementedError('TODO(Orang 3): getSchedule');

  // TODO(Orang 3): set dokumen baru.
  @override
  Future<void> createSchedule(Schedule schedule) =>
      throw UnimplementedError('TODO(Orang 3): createSchedule');

  // TODO(Orang 3): update dengan updated_at baru.
  @override
  Future<void> updateSchedule(Schedule schedule) =>
      throw UnimplementedError('TODO(Orang 3): updateSchedule');

  // TODO(Orang 3): hapus dokumen (diizinkan Security Rules).
  @override
  Future<void> deleteSchedule(String scheduleId) =>
      throw UnimplementedError('TODO(Orang 3): deleteSchedule');
}
