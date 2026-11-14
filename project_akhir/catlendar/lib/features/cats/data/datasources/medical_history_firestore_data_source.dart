import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_collections.dart';

/// Akses mentah ke koleksi MEDICAL_HISTORY. Milik Orang 2.
class MedicalHistoryFirestoreDataSource {
  MedicalHistoryFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.medicalHistory);

  String newId() => collection.doc().id;
}
