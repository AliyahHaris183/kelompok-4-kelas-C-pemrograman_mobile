import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';
import 'package:catlendar/core/utils/validators.dart';

void main() {
  group('konversi tanggal (date only)', () {
    test('disimpan sebagai 00:00 UTC pada tanggal kalender yang sama', () {
      final ts = dateOnlyToTimestamp(DateTime(2026, 3, 1, 23, 59));
      expect(ts, Timestamp.fromDate(DateTime.utc(2026, 3, 1)));
    });

    test('round trip tidak menggeser tanggal', () {
      final result = timestampToDateOnly(dateOnlyToTimestamp(DateTime(2026, 3, 1)));
      expect(result, DateTime(2026, 3, 1));
    });
  });

  group('FirestoreMapReader', () {
    test('field wajib yang hilang melempar FormatException', () {
      final map = <String, dynamic>{};
      expect(() => map.readRequiredString('name'), throwsFormatException);
      expect(() => map.readRequiredDateTime('created_at'), throwsFormatException);
      expect(() => map.readRequiredDate('date_of_birth'), throwsFormatException);
    });

    test('field opsional yang hilang menghasilkan null / default', () {
      final map = <String, dynamic>{};
      expect(map.readString('notes'), isNull);
      expect(map.readBool('is_active', defaultValue: true), isTrue);
    });
  });

  group('AppDateUtils', () {
    test('formatDate dan formatMonthYear', () {
      expect(AppDateUtils.formatDate(DateTime(2026, 3, 5)), '5 Mar 2026');
      expect(AppDateUtils.formatMonthYear(DateTime(2026, 3, 5)), 'Maret 2026');
    });

    test('umur dihitung dari tanggal lahir', () {
      final now = DateTime(2026, 6, 15);
      expect(AppDateUtils.formatAge(DateTime(2026, 1, 20), now: now), '4 bulan');
      expect(AppDateUtils.formatAge(DateTime(2024, 6, 15), now: now), '2 tahun');
      expect(AppDateUtils.ageInYears(DateTime(2024, 6, 16), now: now), 1);
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('bukan-email'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('password minimal 6 karakter dan konfirmasi harus sama', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.confirmPassword('abcdef', 'abcdeg'), isNotNull);
      expect(Validators.confirmPassword('abcdef', 'abcdef'), isNull);
    });

    test('dateNotBefore untuk jadwal', () {
      final last = DateTime(2026, 3, 10);
      expect(Validators.dateNotBefore(DateTime(2026, 3, 9), last), isNotNull);
      expect(Validators.dateNotBefore(DateTime(2026, 3, 10), last), isNull);
      expect(Validators.dateNotBefore(DateTime(2026, 3, 11), null), isNull);
    });
  });
}
