import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/providers/firebase_providers.dart';
import 'package:catlendar/core/providers/http_provider.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/features/care/data/datasources/care_record_firestore_data_source.dart';
import 'package:catlendar/features/care/data/datasources/holiday_api_data_source.dart';
import 'package:catlendar/features/care/data/datasources/schedule_firestore_data_source.dart';
import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/data/repositories/care_record_repository_impl.dart';
import 'package:catlendar/features/care/data/repositories/schedule_repository_impl.dart';
import 'package:catlendar/features/care/domain/repositories/care_record_repository.dart';
import 'package:catlendar/features/care/domain/repositories/schedule_repository.dart';

final careRecordRepositoryProvider = Provider<CareRecordRepository>(
  (ref) => CareRecordRepositoryImpl(
    CareRecordFirestoreDataSource(ref.watch(firebaseFirestoreProvider)),
  ),
);

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepositoryImpl(
    ScheduleFirestoreDataSource(ref.watch(firebaseFirestoreProvider)),
  ),
);

final holidayDataSourceProvider = Provider<HolidayApiDataSource>(
  (ref) => HolidayApiDataSource(ref.watch(httpClientProvider)),
);

/// Hari libur Indonesia per tahun (kalender).
final holidaysProvider = FutureProvider.family<List<Holiday>, int>(
  (ref, year) => ref.watch(holidayDataSourceProvider).fetchHolidays(year: year),
);

/// Riwayat perawatan (log) satu kucing.
final careRecordsByCatProvider =
    StreamProvider.family<List<CareRecord>, String>((ref, catId) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <CareRecord>[]);
  return ref
      .watch(careRecordRepositoryProvider)
      .watchRecordsByCat(ownerId: ownerId, catId: catId);
});

/// Semua jadwal milik pengguna (kalender bulanan dan Summary).
final schedulesByOwnerProvider = StreamProvider<List<Schedule>>((ref) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <Schedule>[]);
  return ref.watch(scheduleRepositoryProvider).watchSchedulesByOwner(ownerId);
});

/// Jadwal satu kucing.
final schedulesByCatProvider = StreamProvider.family<List<Schedule>, String>((
  ref,
  catId,
) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <Schedule>[]);
  return ref
      .watch(scheduleRepositoryProvider)
      .watchSchedulesByCat(ownerId: ownerId, catId: catId);
});

/// Kerangka alur simpan jadwal.
///
/// TODO(Orang 3): implementasikan saveSchedule dengan urutan:
///  1. validasi next_date tidak sebelum tanggal terakhir (Validators.dateNotBefore)
///  2. cari jadwal sejenis (ScheduleRepository.getSchedule)
///  3. jika ada dan punya local_notification_id, batalkan notifikasi lama
///  4. create/update SCHEDULE
///  5. jadwalkan notifikasi lokal baru, simpan local_notification_id
class ScheduleSetupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
}

final scheduleSetupControllerProvider =
    AsyncNotifierProvider<ScheduleSetupController, void>(
  ScheduleSetupController.new,
);
