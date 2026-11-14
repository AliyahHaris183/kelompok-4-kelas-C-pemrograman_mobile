import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/reminder_option.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';

void main() {
  final createdAt = DateTime.utc(2026, 1, 10, 8, 30);
  final updatedAt = DateTime.utc(2026, 2, 11, 9, 45);

  group('CareType dan ReminderOption', () {
    test('nilai Firestore sesuai ERD', () {
      expect(CareType.values.map((e) => e.value).toList(), [
        'bath',
        'flea',
        'fungal',
        'vet_visit',
        'vaccination',
        'custom',
      ]);
      expect(ReminderOption.values.map((e) => e.value).toList(), [
        'none',
        'a_week',
        '3_days',
        '1_day',
        'd_day',
      ]);
    });

    test('fromValue dan nilai tidak dikenal', () {
      expect(CareType.fromValue('vet_visit'), CareType.vetVisit);
      expect(ReminderOption.fromValue('3_days'), ReminderOption.threeDays);
      expect(() => CareType.fromValue('lainnya'), throwsFormatException);
      expect(() => ReminderOption.fromValue('2_days'), throwsFormatException);
    });

    test('daysBefore', () {
      expect(ReminderOption.none.daysBefore, isNull);
      expect(ReminderOption.aWeek.daysBefore, 7);
      expect(ReminderOption.dDay.daysBefore, 0);
    });
  });

  group('CareRecord (CARE_RECORD, log)', () {
    final record = CareRecord(
      careRecordId: 'cr-1',
      catId: 'cat-1',
      ownerId: 'uid-1',
      careType: CareType.custom,
      customName: 'Potong kuku',
      performedDate: DateTime(2026, 3, 1),
      createdAt: createdAt,
    );

    test('toMap memakai nama field ERD dan TIDAK punya updated_at', () {
      expect(record.toMap().keys.toSet(), {
        'care_record_id',
        'cat_id',
        'owner_id',
        'care_type',
        'custom_name',
        'performed_date',
        'created_at',
      });
      expect(record.toMap().containsKey('updated_at'), isFalse);
      expect(record.toMap()['care_type'], 'custom');
    });

    test('performed_date disimpan sebagai tanggal saja', () {
      expect(
        record.toMap()['performed_date'],
        Timestamp.fromDate(DateTime.utc(2026, 3, 1)),
      );
    });

    test('round trip', () {
      final restored = CareRecord.fromMap(record.toMap());
      expect(restored.careRecordId, 'cr-1');
      expect(restored.careType, CareType.custom);
      expect(restored.customName, 'Potong kuku');
      expect(restored.performedDate, DateTime(2026, 3, 1));
      expect(restored.createdAt.isAtSameMomentAs(createdAt), isTrue);
    });

    test('care_type tidak dikenal melempar FormatException', () {
      final map = record.toMap()..['care_type'] = 'unknown';
      expect(() => CareRecord.fromMap(map), throwsFormatException);
    });
  });

  group('Schedule (SCHEDULE)', () {
    final schedule = Schedule(
      scheduleId: 's-1',
      catId: 'cat-1',
      ownerId: 'uid-1',
      careType: CareType.bath,
      nextDate: DateTime(2026, 4, 20),
      reminderOption: ReminderOption.threeDays,
      localNotificationId: 'notif-1',
      isActive: true,
      updatedAt: updatedAt,
    );

    test('toMap memakai nama field persis seperti ERD', () {
      expect(schedule.toMap().keys.toSet(), {
        'schedule_id',
        'cat_id',
        'owner_id',
        'care_type',
        'custom_name',
        'next_date',
        'reminder_option',
        'local_notification_id',
        'is_active',
        'updated_at',
      });
      expect(schedule.toMap()['reminder_option'], '3_days');
    });

    test('round trip', () {
      final restored = Schedule.fromMap(schedule.toMap());
      expect(restored.scheduleId, 's-1');
      expect(restored.careType, CareType.bath);
      expect(restored.customName, isNull);
      expect(restored.nextDate, DateTime(2026, 4, 20));
      expect(restored.reminderOption, ReminderOption.threeDays);
      expect(restored.localNotificationId, 'notif-1');
      expect(restored.isActive, isTrue);
      expect(restored.updatedAt.isAtSameMomentAs(updatedAt), isTrue);
    });

    test('tanpa pengingat: local_notification_id null', () {
      final noReminder = Schedule(
        scheduleId: 's-2',
        catId: 'cat-1',
        ownerId: 'uid-1',
        careType: CareType.flea,
        nextDate: DateTime(2026, 5, 1),
        updatedAt: updatedAt,
      );
      final restored = Schedule.fromMap(noReminder.toMap());
      expect(restored.reminderOption, ReminderOption.none);
      expect(restored.localNotificationId, isNull);
      expect(restored.isActive, isTrue);
    });
  });
}
