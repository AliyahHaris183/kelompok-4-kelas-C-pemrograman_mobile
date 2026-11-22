import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_collections.dart';

/// Akses mentah ke koleksi CATS. Milik Orang 2.
class CatFirestoreDataSource {
  CatFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.cats);

  /// ID baru dibuat lokal, tanpa jaringan.
  String newId() => collection.doc().id;
}
