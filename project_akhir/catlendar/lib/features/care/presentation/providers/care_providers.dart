import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/notifications/local_notification_service.dart';
import 'package:catlendar/core/providers/firebase_providers.dart';
import 'package:catlendar/core/providers/http_provider.dart';
import 'package:catlendar/core/providers/notification_providers.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/care/data/datasources/care_record_firestore_data_source.dart';
import 'package:catlendar/features/care/data/datasources/holiday_api_data_source.dart';
import 'package:catlendar/features/care/data/datasources/schedule_firestore_data_source.dart';
import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/data/models/reminder_option.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/data/repositories/care_record_repository_impl.dart';
import 'package:catlendar/features/care/data/repositories/schedule_repository_impl.dart';
import 'package:catlendar/features/care/domain/care_inputs.dart';
import 'package:catlendar/features/care/domain/reminder_planner.dart';
import 'package:catlendar/features/care/domain/repositories/care_record_repository.dart';
import 'package:catlendar/features/care/domain/repositories/schedule_repository.dart';
import 'package:catlendar/features/care/presentation/utils/care_labels.dart';

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

final holidaysProvider = FutureProvider.family<List<Holiday>, int>(
  (ref, year) => ref.watch(holidayDataSourceProvider).fetchHolidays(year: year),
);

final careRecordsByCatProvider =
    StreamProvider.family<List<CareRecord>, String>((ref, catId) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <CareRecord>[]);
  return ref
      .watch(careRecordRepositoryProvider)
      .watchRecordsByCat(ownerId: ownerId, catId: catId);
});

final careRecordsByOwnerProvider = StreamProvider<List<CareRecord>>((ref) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <CareRecord>[]);
  return ref.watch(careRecordRepositoryProvider).watchRecordsByOwner(ownerId);
});

final schedulesByOwnerProvider = StreamProvider<List<Schedule>>((ref) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <Schedule>[]);
  return ref.watch(scheduleRepositoryProvider).watchSchedulesByOwner(ownerId);
});

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

const String _sessionMessage = 'Sesi login tidak ditemukan. Silakan login ulang.';
const String _reminderTitle = 'Pengingat perawatan Catlendar';

final class CareActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> saveGroomingRecords({
    required String catId,
    required List<PastCareInput> inputs,
  }) async {
    final ownerId = ref.read(currentUserIdProvider);
    if (ownerId == null) return _sessionMessage;
    if (inputs.isEmpty) return null;

    final today = AppDateUtils.dateOnly(DateTime.now());
    for (final input in inputs) {
      if (AppDateUtils.isBeforeDay(today, input.performedDate)) {
        return '${careTypeLabel(input.careType, customName: input.customName)}: '
            'tanggal tidak boleh di masa depan.';
      }
    }

    final repo = ref.read(careRecordRepositoryProvider);
    final now = DateTime.now();
    final records = [
      for (final input in inputs)
        CareRecord(
          careRecordId: repo.newId(),
          catId: catId,
          ownerId: ownerId,
          careType: input.careType,
          customName: input.customName,
          performedDate: AppDateUtils.dateOnly(input.performedDate),
          createdAt: now,
        ),
    ];
    return _run(() => repo.addRecords(records));
  }

  Future<ScheduleSaveResult> saveSchedules({
    required String catId,
    required String catName,
    required List<ScheduleInput> inputs,
    required ReminderOption reminder,
  }) async {
    final ownerId = ref.read(currentUserIdProvider);
    if (ownerId == null) return const ScheduleFailed(_sessionMessage);
    if (inputs.isEmpty) {
      return const ScheduleInvalid(['Isi minimal satu tanggal jadwal.']);
    }

    final now = DateTime.now();
    final today = AppDateUtils.dateOnly(now);
    final scheduleRepo = ref.read(scheduleRepositoryProvider);
    final careRepo = ref.read(careRecordRepositoryProvider);

    final errors = <String>[];
    for (final input in inputs) {
      final label = careTypeLabel(input.careType, customName: input.customName);
      if (AppDateUtils.isBeforeDay(input.nextDate, today)) {
        errors.add('$label: tanggal tidak boleh sebelum hari ini.');
        continue;
      }
      final last = await careRepo.getLatestRecord(
        ownerId: ownerId,
        catId: catId,
        careType: input.careType,
        customName: input.customName,
      );
      final error = Validators.dateNotBefore(
        input.nextDate,
        last?.performedDate,
        message: '$label: tanggal tidak boleh sebelum tanggal terakhir.',
      );
      if (error != null) errors.add(error);
    }
    if (errors.isNotEmpty) return ScheduleInvalid(errors);

    state = const AsyncLoading();
    try {
      final notifications = await _notifications();
      final wantsReminder = reminder != ReminderOption.none;
      final permissionOk =
          !wantsReminder || await notifications.requestPermission();

      var remindersScheduled = 0;
      final summaryLabels = <String>[];
      for (final input in inputs) {
        final existing = await scheduleRepo.getSchedule(
          ownerId: ownerId,
          catId: catId,
          careType: input.careType,
          customName: input.customName,
        );

        final oldId = existing?.localNotificationId;
        if (oldId != null) await notifications.cancelReminder(oldId);

        final at = ReminderPlanner.reminderAt(
          nextDate: input.nextDate,
          option: reminder,
          now: now,
        );
        final shouldRemind = wantsReminder && permissionOk && at != null;
        final newId = shouldRemind ? notifications.newNotificationId() : null;

        final schedule = Schedule(
          scheduleId: existing?.scheduleId ?? scheduleRepo.newId(),
          catId: catId,
          ownerId: ownerId,
          careType: input.careType,
          customName: input.customName,
          nextDate: AppDateUtils.dateOnly(input.nextDate),
          reminderOption: reminder,
          localNotificationId: newId,
          isActive: true,
          updatedAt: now,
        );
        if (existing == null) {
          await scheduleRepo.createSchedule(schedule);
        } else {
          await scheduleRepo.updateSchedule(schedule);
        }

        final label = careTypeLabel(input.careType, customName: input.customName);
        summaryLabels.add('$label (${AppDateUtils.formatDate(input.nextDate)})');

        if (shouldRemind) {
          final scheduled = await notifications.scheduleReminder(
            localNotificationId: newId!,
            scheduledAt: at,
            title: _reminderTitle,
            body: '$label untuk $catName pada ${AppDateUtils.formatDate(input.nextDate)}',
          );
          if (scheduled) remindersScheduled++;
        }
      }

      if (wantsReminder && permissionOk && summaryLabels.isNotEmpty) {
        await notifications.showImmediateNotification(
          title: 'Jadwal perawatan $catName aktif',
          body: '${summaryLabels.join(', ')} • Pengingat: ${reminderLabel(reminder.value)}',
        );
      }

      state = const AsyncData(null);
      return ScheduleSaved(
        savedCount: inputs.length,
        remindersScheduled: remindersScheduled,
        reminderDenied: wantsReminder && !permissionOk,
      );
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return ScheduleFailed(AppException.from(error).message);
    }
  }

  Future<String?> completeSchedule(Schedule schedule) => _run(() async {
        if (!schedule.isActive) return;
        final repo = ref.read(careRecordRepositoryProvider);
        final now = DateTime.now();
        final exists = await repo.hasRecordOn(
          ownerId: schedule.ownerId,
          catId: schedule.catId,
          careType: schedule.careType,
          customName: schedule.customName,
          performedDate: schedule.nextDate,
        );
        if (!exists) {
          await repo.addRecord(
            CareRecord(
              careRecordId: repo.newId(),
              catId: schedule.catId,
              ownerId: schedule.ownerId,
              careType: schedule.careType,
              customName: schedule.customName,
              performedDate: schedule.nextDate,
              createdAt: now,
            ),
          );
        }
        await _deactivate(schedule, now);
      });

  Future<String?> cancelSchedule(Schedule schedule) => _run(() async {
        if (!schedule.isActive) return;
        await _deactivate(schedule, DateTime.now());
      });

  Future<String?> deleteSchedule(Schedule schedule) => _run(() async {
        final notifications = await _notifications();
        final oldId = schedule.localNotificationId;
        if (oldId != null) await notifications.cancelReminder(oldId);
        await ref.read(scheduleRepositoryProvider).deleteSchedule(schedule.scheduleId);
      });

  Future<void> _deactivate(Schedule schedule, DateTime now) async {
    final notifications = await _notifications();
    final oldId = schedule.localNotificationId;
    if (oldId != null) await notifications.cancelReminder(oldId);
    await ref.read(scheduleRepositoryProvider).updateSchedule(
          schedule.copyWith(
            isActive: false,
            clearLocalNotificationId: true,
            updatedAt: now,
          ),
        );
  }

  Future<LocalNotificationService> _notifications() async {
    final service = ref.read(localNotificationServiceProvider);
    await service.initialize();
    return service;
  }

  Future<String?> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return null;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return AppException.from(error).message;
    }
  }
}

final careActionControllerProvider =
    AsyncNotifierProvider<CareActionController, void>(CareActionController.new);
