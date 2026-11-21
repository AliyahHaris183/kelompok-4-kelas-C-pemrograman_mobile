import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_collections.dart';

class MedicalHistoryFirestoreDataSource {
  MedicalHistoryFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  late final collection =
      _firestore.collection(FirestoreCollections.medicalHistory);

  /// ID baru dibuat lokal, tanpa jaringan.
  String newId() => collection.doc().id;
}
