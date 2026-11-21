import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';

/// Entitas CARE_RECORD: LOG RIWAYAT. Setiap aktivitas adalah dokumen baru.
/// Tidak pernah di-update atau dihapus (Security Rules juga menolaknya),
/// sehingga tidak ada updated_at.
class CareRecord {
  const CareRecord({
    required this.careRecordId,
    required this.catId,
    required this.ownerId,
    required this.careType,
    this.customName,
    required this.performedDate,
    required this.createdAt,
  });

  final String careRecordId;
  final String catId;
  final String ownerId;
  final CareType careType;

  /// Diisi jika careType == CareType.custom.
  final String? customName;

  /// Tanggal aktivitas dilakukan (tanggal saja).
  final DateTime performedDate;
  final DateTime createdAt;

  factory CareRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen CARE_RECORD/${doc.id} kosong atau tidak ada');
    }
    return CareRecord.fromMap({...data, FirestoreFields.careRecordId: doc.id});
  }

  factory CareRecord.fromMap(Map<String, dynamic> map) {
    return CareRecord(
      careRecordId: map.readRequiredString(FirestoreFields.careRecordId),
      catId: map.readRequiredString(FirestoreFields.catId),
      ownerId: map.readRequiredString(FirestoreFields.ownerId),
      careType: CareType.fromValue(
        map.readRequiredString(FirestoreFields.careType),
      ),
      customName: map.readString(FirestoreFields.customName),
      performedDate: map.readRequiredDate(FirestoreFields.performedDate),
      createdAt: map.readRequiredDateTime(FirestoreFields.createdAt),
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        FirestoreFields.careRecordId: careRecordId,
        FirestoreFields.catId: catId,
        FirestoreFields.ownerId: ownerId,
        FirestoreFields.careType: careType.value,
        FirestoreFields.customName: customName,
        FirestoreFields.performedDate: dateOnlyToTimestamp(performedDate),
        FirestoreFields.createdAt: dateTimeToTimestamp(createdAt),
      };
}
