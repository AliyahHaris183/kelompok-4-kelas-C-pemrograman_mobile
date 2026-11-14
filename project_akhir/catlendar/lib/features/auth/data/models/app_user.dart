import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';

/// Entitas USERS. Dokumen: USERS/{user_id}, user_id = UID Firebase Auth.
/// Dinamai AppUser agar tidak bentrok dengan User milik firebase_auth.
class AppUser {
  const AppUser({
    required this.userId,
    required this.email,
    this.emailVerified = false,
    required this.name,
    required this.dateOfBirth,
    this.gender,
    this.avatarId,
    this.onboardingDone = false,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String email;
  final bool emailVerified;
  final String name;

  /// Tanggal saja, tanpa jam (keputusan 7.3).
  final DateTime dateOfBirth;
  final String? gender;

  /// Preset avatar, bukan foto (keputusan 7.8).
  final String? avatarId;
  final bool onboardingDone;

  /// Disimpan saat login, dihapus (null) saat log out.
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ID dokumen dipakai sebagai user_id.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen USERS/${doc.id} kosong atau tidak ada');
    }
    return AppUser.fromMap({...data, FirestoreFields.userId: doc.id});
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map.readRequiredString(FirestoreFields.userId),
      email: map.readRequiredString(FirestoreFields.email),
      emailVerified: map.readBool(FirestoreFields.emailVerified),
      name: map.readRequiredString(FirestoreFields.name),
      dateOfBirth: map.readRequiredDate(FirestoreFields.dateOfBirth),
      gender: map.readString(FirestoreFields.gender),
      avatarId: map.readString(FirestoreFields.avatarId),
      onboardingDone: map.readBool(FirestoreFields.onboardingDone),
      fcmToken: map.readString(FirestoreFields.fcmToken),
      createdAt: map.readRequiredDateTime(FirestoreFields.createdAt),
      updatedAt: map.readRequiredDateTime(FirestoreFields.updatedAt),
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        FirestoreFields.userId: userId,
        FirestoreFields.email: email,
        FirestoreFields.emailVerified: emailVerified,
        FirestoreFields.name: name,
        FirestoreFields.dateOfBirth: dateOnlyToTimestamp(dateOfBirth),
        FirestoreFields.gender: gender,
        FirestoreFields.avatarId: avatarId,
        FirestoreFields.onboardingDone: onboardingDone,
        FirestoreFields.fcmToken: fcmToken,
        FirestoreFields.createdAt: dateTimeToTimestamp(createdAt),
        FirestoreFields.updatedAt: dateTimeToTimestamp(updatedAt),
      };
}
