/// Nama field Firestore. Mengikuti ERD secara persis (snake_case).
/// Pakai konstanta ini pada model dan query agar tidak ada salah ketik.
abstract final class FirestoreFields {
  // Primary key
  static const String userId = 'user_id';
  static const String catId = 'cat_id';
  static const String historyId = 'history_id';
  static const String careRecordId = 'care_record_id';
  static const String scheduleId = 'schedule_id';

  // Foreign key
  static const String ownerId = 'owner_id';

  // USERS
  static const String email = 'email';
  static const String emailVerified = 'email_verified';
  static const String name = 'name';
  static const String dateOfBirth = 'date_of_birth';
  static const String gender = 'gender';
  static const String avatarId = 'avatar_id';
  static const String onboardingDone = 'onboarding_done';
  static const String fcmToken = 'fcm_token';

  // CATS
  static const String breed = 'breed';
  static const String neuterStatus = 'neuter_status';
  static const String color = 'color';

  // MEDICAL_HISTORY
  static const String conditionName = 'condition_name';
  static const String notes = 'notes';

  // CARE_RECORD dan SCHEDULE
  static const String careType = 'care_type';
  static const String customName = 'custom_name';
  static const String performedDate = 'performed_date';
  static const String nextDate = 'next_date';
  static const String reminderOption = 'reminder_option';
  static const String localNotificationId = 'local_notification_id';
  static const String isActive = 'is_active';

  // Timestamp
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
