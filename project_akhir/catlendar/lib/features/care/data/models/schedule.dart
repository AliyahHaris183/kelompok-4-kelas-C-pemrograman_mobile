import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/reminder_option.dart';

/// Entitas SCHEDULE: jadwal BERIKUTNYA, satu per jenis perawatan per kucing.
/// Dokumen ini boleh diperbarui.
class Schedule {
  const Schedule({
    required this.scheduleId,
    required this.catId,
    required this.ownerId,
    required this.careType,
    this.customName,
    required this.nextDate,
    this.reminderOption = ReminderOption.none,
    this.localNotificationId,
    this.isActive = true,
    required this.updatedAt,
  });

  final String scheduleId;
  final String catId;
  final String ownerId;
  final CareType careType;

  /// Diisi jika careType == CareType.custom.
  final String? customName;

  /// Tidak boleh sebelum tanggal terakhir (divalidasi di layar/ repository).
  final DateTime nextDate;
  final ReminderOption reminderOption;

  /// Untuk membatalkan notifikasi lokal lama. Null jika tidak ada pengingat.
  final String? localNotificationId;
  final bool isActive;
  final DateTime updatedAt;

  factory Schedule.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen SCHEDULE/${doc.id} kosong atau tidak ada');
    }
    return Schedule.fromMap({...data, FirestoreFields.scheduleId: doc.id});
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      scheduleId: map.readRequiredString(FirestoreFields.scheduleId),
      catId: map.readRequiredString(FirestoreFields.catId),
      ownerId: map.readRequiredString(FirestoreFields.ownerId),
      careType: CareType.fromValue(
        map.readRequiredString(FirestoreFields.careType),
      ),
      customName: map.readString(FirestoreFields.customName),
      nextDate: map.readRequiredDate(FirestoreFields.nextDate),
      reminderOption: ReminderOption.fromValue(
        map.readRequiredString(FirestoreFields.reminderOption),
      ),
      localNotificationId: map.readString(FirestoreFields.localNotificationId),
      isActive: map.readBool(FirestoreFields.isActive, defaultValue: true),
      updatedAt: map.readRequiredDateTime(FirestoreFields.updatedAt),
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        FirestoreFields.scheduleId: scheduleId,
        FirestoreFields.catId: catId,
        FirestoreFields.ownerId: ownerId,
        FirestoreFields.careType: careType.value,
        FirestoreFields.customName: customName,
        FirestoreFields.nextDate: dateOnlyToTimestamp(nextDate),
        FirestoreFields.reminderOption: reminderOption.value,
        FirestoreFields.localNotificationId: localNotificationId,
        FirestoreFields.isActive: isActive,
        FirestoreFields.updatedAt: dateTimeToTimestamp(updatedAt),
      };
}
