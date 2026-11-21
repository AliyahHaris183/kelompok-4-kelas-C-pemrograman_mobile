import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/care/data/models/reminder_option.dart';
import 'package:catlendar/features/care/domain/reminder_planner.dart';

void main() {
  final now = DateTime(2026, 11, 21, 9, 0);

  group('ReminderPlanner.reminderAt', () {
    test('tanpa pengingat mengembalikan null', () {
      expect(
        ReminderPlanner.reminderAt(
          nextDate: DateTime(2026, 12, 20),
          option: ReminderOption.none,
          now: now,
        ),
        isNull,
      );
    });

    test('satu minggu sebelum pukul 08.00', () {
      expect(
        ReminderPlanner.reminderAt(
          nextDate: DateTime(2026, 12, 20),
          option: ReminderOption.aWeek,
          now: now,
        ),
        DateTime(2026, 12, 13, 8),
      );
    });

    test('tiga hari, satu hari, dan D-day', () {
      final nextDate = DateTime(2026, 12, 20);
      expect(
        ReminderPlanner.reminderAt(nextDate: nextDate, option: ReminderOption.threeDays, now: now),
        DateTime(2026, 12, 17, 8),
      );
      expect(
        ReminderPlanner.reminderAt(nextDate: nextDate, option: ReminderOption.oneDay, now: now),
        DateTime(2026, 12, 19, 8),
      );
      expect(
        ReminderPlanner.reminderAt(nextDate: nextDate, option: ReminderOption.dDay, now: now),
        DateTime(2026, 12, 20, 8),
      );
    });

    test('waktu yang sudah lewat tidak dijadwalkan', () {
      // D-day hari ini pukul 08.00 sudah lewat ketika sekarang 09.00.
      expect(
        ReminderPlanner.reminderAt(
          nextDate: DateTime(2026, 11, 21),
          option: ReminderOption.dDay,
          now: now,
        ),
        isNull,
      );
    });

    test('pengingat melintasi batas bulan', () {
      expect(
        ReminderPlanner.reminderAt(
          nextDate: DateTime(2027, 1, 2),
          option: ReminderOption.aWeek,
          now: now,
        ),
        DateTime(2026, 12, 26, 8),
      );
    });
  });
}
