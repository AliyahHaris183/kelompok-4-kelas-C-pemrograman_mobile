import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';

/// Entitas MEDICAL_HISTORY. Dokumen: MEDICAL_HISTORY/{history_id}.
class MedicalHistory {
  const MedicalHistory({
    required this.historyId,
    required this.catId,
    required this.ownerId,
    required this.conditionName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String historyId;
  final String catId;
  final String ownerId;

  /// Contoh: Alergi kacang, Asma.
  final String conditionName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MedicalHistory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw FormatException(
        'Dokumen MEDICAL_HISTORY/${doc.id} kosong atau tidak ada',
      );
    }
    return MedicalHistory.fromMap({...data, FirestoreFields.historyId: doc.id});
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    return MedicalHistory(
      historyId: map.readRequiredString(FirestoreFields.historyId),
      catId: map.readRequiredString(FirestoreFields.catId),
      ownerId: map.readRequiredString(FirestoreFields.ownerId),
      conditionName: map.readRequiredString(FirestoreFields.conditionName),
      notes: map.readString(FirestoreFields.notes),
      createdAt: map.readRequiredDateTime(FirestoreFields.createdAt),
      updatedAt: map.readRequiredDateTime(FirestoreFields.updatedAt),
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        FirestoreFields.historyId: historyId,
        FirestoreFields.catId: catId,
        FirestoreFields.ownerId: ownerId,
        FirestoreFields.conditionName: conditionName,
        FirestoreFields.notes: notes,
        FirestoreFields.createdAt: dateTimeToTimestamp(createdAt),
        FirestoreFields.updatedAt: dateTimeToTimestamp(updatedAt),
      };
}
