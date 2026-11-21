import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_collections.dart';

/// Akses mentah ke koleksi SCHEDULE. Milik Orang 3.
class ScheduleFirestoreDataSource {
  ScheduleFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.schedule);

  String newId() => collection.doc().id;
}
