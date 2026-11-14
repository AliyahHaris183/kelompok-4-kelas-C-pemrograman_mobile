import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_collections.dart';

/// Akses mentah ke koleksi USERS. Milik Orang 1.
class UserFirestoreDataSource {
  UserFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.users);

  DocumentReference<Map<String, dynamic>> doc(String userId) =>
      collection.doc(userId);
}
