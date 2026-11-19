import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_collections.dart';

/// Akses mentah ke koleksi CARE_RECORD (log). Milik Orang 3.
class CareRecordFirestoreDataSource {
  CareRecordFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.careRecord);

  String newId() => collection.doc().id;
}
