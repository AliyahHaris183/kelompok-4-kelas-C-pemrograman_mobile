import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/features/cats/data/datasources/cat_firestore_data_source.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/domain/repositories/cat_repository.dart';

class CatRepositoryImpl implements CatRepository {
  CatRepositoryImpl(this.dataSource);

  final CatFirestoreDataSource dataSource;

  @override
  String newId() => dataSource.newId();

  @override
  Stream<List<Cat>> watchCatsByOwner(String ownerId) {
    return dataSource.collection
        .where(FirestoreFields.ownerId, isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Cat.fromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<Cat?> watchCat(String catId) {
    return dataSource.collection.doc(catId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Cat.fromFirestore(doc);
    });
  }

  @override
  Future<Cat?> getCat(String catId) async {
    final doc = await dataSource.collection.doc(catId).get();
    if (!doc.exists) return null;
    return Cat.fromFirestore(doc);
  }

  @override
  Future<void> createCat(Cat cat) async {
    await dataSource.collection.doc(cat.catId).set(cat.toFirestore());
  }

  @override
  Future<void> updateCat(Cat cat) async {
    final updateData = cat.toFirestore();
    updateData.remove(FirestoreFields.ownerId);
    updateData[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();

    await dataSource.collection.doc(cat.catId).update(updateData);
  }
}
