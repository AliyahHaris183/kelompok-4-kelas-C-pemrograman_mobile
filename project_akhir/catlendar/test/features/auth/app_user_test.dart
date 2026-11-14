import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/auth/data/models/app_user.dart';

void main() {
  final createdAt = DateTime.utc(2026, 1, 10, 8, 30);
  final updatedAt = DateTime.utc(2026, 2, 11, 9, 45);

  final user = AppUser(
    userId: 'uid-1',
    email: 'budi@example.com',
    emailVerified: true,
    name: 'Budi',
    dateOfBirth: DateTime(2000, 5, 17),
    gender: 'Male',
    avatarId: 'owner_1',
    onboardingDone: true,
    fcmToken: 'token-abc',
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  group('AppUser (USERS)', () {
    test('toMap memakai nama field persis seperti ERD', () {
      expect(user.toMap().keys.toSet(), {
        'user_id',
        'email',
        'email_verified',
        'name',
        'date_of_birth',
        'gender',
        'avatar_id',
        'onboarding_done',
        'fcm_token',
        'created_at',
        'updated_at',
      });
    });

    test('date_of_birth disimpan sebagai tanggal saja (00:00 UTC)', () {
      expect(
        user.toMap()['date_of_birth'],
        Timestamp.fromDate(DateTime.utc(2000, 5, 17)),
      );
    });

    test('round trip toMap -> fromMap', () {
      final restored = AppUser.fromMap(user.toMap());
      expect(restored.userId, 'uid-1');
      expect(restored.email, 'budi@example.com');
      expect(restored.emailVerified, isTrue);
      expect(restored.name, 'Budi');
      expect(restored.dateOfBirth, DateTime(2000, 5, 17));
      expect(restored.gender, 'Male');
      expect(restored.avatarId, 'owner_1');
      expect(restored.onboardingDone, isTrue);
      expect(restored.fcmToken, 'token-abc');
      expect(restored.createdAt.isAtSameMomentAs(createdAt), isTrue);
      expect(restored.updatedAt.isAtSameMomentAs(updatedAt), isTrue);
    });

    test('fcm_token null (setelah log out) tetap valid', () {
      final loggedOut = AppUser(
        userId: 'uid-1',
        email: 'budi@example.com',
        name: 'Budi',
        dateOfBirth: DateTime(2000, 5, 17),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final restored = AppUser.fromMap(loggedOut.toMap());
      expect(restored.fcmToken, isNull);
      expect(restored.gender, isNull);
      expect(restored.onboardingDone, isFalse);
    });

    test('field wajib hilang melempar FormatException', () {
      final map = user.toMap()..remove('email');
      expect(() => AppUser.fromMap(map), throwsFormatException);
    });
  });
}
