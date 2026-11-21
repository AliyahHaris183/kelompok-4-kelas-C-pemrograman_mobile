import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/data/models/reminder_option.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/presentation/utils/care_labels.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';

Cat _cat(String id, String name) => Cat(
      catId: id,
      ownerId: 'u1',
      name: name,
      dateOfBirth: DateTime(2024, 1, 1),
      gender: 'Male',
      neuterStatus: 'Neutered',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

Schedule _schedule(String id, String catId, DateTime next, {bool active = true}) =>
    Schedule(
      scheduleId: id,
      catId: catId,
      ownerId: 'u1',
      careType: CareType.bath,
      nextDate: next,
      reminderOption: ReminderOption.aWeek,
      isActive: active,
      updatedAt: DateTime.utc(2026),
    );

CareRecord _record(String id, String catId, DateTime performed) => CareRecord(
      careRecordId: id,
      catId: catId,
      ownerId: 'u1',
      careType: CareType.flea,
      performedDate: performed,
      createdAt: DateTime.utc(2026),
    );

void main() {
  group('Holiday.fromJson', () {
    test('membaca tanggal saja dan flag nasional', () {
      final holiday = Holiday.fromJson({
        'date': '2025-08-17',
        'name': 'Hari Kemerdekaan Republik Indonesia',
        'type': 'national_holiday',
        'is_national': true,
      });
      expect(holiday.date, DateTime(2025, 8, 17));
      expect(holiday.isNational, isTrue);
    });

    test('cuti bersama bukan nasional', () {
      final holiday = Holiday.fromJson({
        'date': '2026-12-24',
        'name': 'Cuti Bersama',
        'type': 'joint_leave',
        'is_national': false,
      });
      expect(holiday.isNational, isFalse);
    });

    test('field wajib hilang melempar FormatException', () {
      expect(() => Holiday.fromJson({'name': 'x'}), throwsFormatException);
    });
  });

  group('buildSummaryEntries', () {
    final now = DateTime(2026, 11, 21, 10);
    final cats = [_cat('c1', 'Fred'), _cat('c2', 'Bello')];

    test('jadwal nonaktif dilewati dan jadwal lewat ditandai overdue', () {
      final entries = buildSummaryEntries(
        schedules: [
          _schedule('s1', 'c1', DateTime(2026, 12, 1)),
          _schedule('s2', 'c1', DateTime(2026, 11, 1)),
          _schedule('s3', 'c2', DateTime(2026, 12, 5), active: false),
        ],
        records: const [],
        cats: cats,
        now: now,
      );
      expect(entries.length, 2);
      expect(entries.first.date, DateTime(2026, 11, 1));
      expect(entries.first.overdue, isTrue);
      expect(entries.last.overdue, isFalse);
    });

    test('riwayat dan jadwal diurutkan per tanggal, Last sebelum Next pada hari sama', () {
      final entries = buildSummaryEntries(
        schedules: [_schedule('s1', 'c1', DateTime(2026, 12, 1))],
        records: [
          _record('r1', 'c1', DateTime(2026, 12, 1)),
          _record('r2', 'c1', DateTime(2026, 10, 1)),
        ],
        cats: cats,
        now: now,
      );
      expect(entries.map((e) => e.kind).toList(), [
        SummaryKind.last,
        SummaryKind.last,
        SummaryKind.next,
      ]);
      expect(entries.first.date, DateTime(2026, 10, 1));
    });

    test('filter catId dan entri yatim dilewati', () {
      final entries = buildSummaryEntries(
        schedules: [
          _schedule('s1', 'c1', DateTime(2026, 12, 1)),
          _schedule('s2', 'c2', DateTime(2026, 12, 2)),
          _schedule('s3', 'tidak-ada', DateTime(2026, 12, 3)),
        ],
        records: const [],
        cats: cats,
        catId: 'c2',
        now: now,
      );
      expect(entries.map((e) => e.catName).toList(), ['Bello']);
    });
  });

  group('careTypeLabel', () {
    test('custom memakai nama kegiatan, atau cadangan jika kosong', () {
      expect(careTypeLabel(CareType.custom, customName: ' Grooming '), 'Grooming');
      expect(careTypeLabel(CareType.custom), 'Custom event');
      expect(careTypeLabel(CareType.vetVisit), 'Vet visit');
    });
  });
}
