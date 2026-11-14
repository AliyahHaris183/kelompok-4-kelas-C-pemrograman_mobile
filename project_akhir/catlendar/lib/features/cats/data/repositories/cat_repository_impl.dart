import 'package:catlendar/features/cats/data/datasources/cat_firestore_data_source.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/domain/repositories/cat_repository.dart';

/// Scaffold. Hanya newId() yang berfungsi. Sisanya TODO Orang 2.
class CatRepositoryImpl implements CatRepository {
  CatRepositoryImpl(this.dataSource);

  final CatFirestoreDataSource dataSource;

  @override
  String newId() => dataSource.newId();

  // TODO(Orang 2): query where owner_id == ownerId, map Cat.fromFirestore.
  @override
  Stream<List<Cat>> watchCatsByOwner(String ownerId) =>
      throw UnimplementedError('TODO(Orang 2): watchCatsByOwner');

  // TODO(Orang 2): snapshots() dokumen CATS/{catId}.
  @override
  Stream<Cat?> watchCat(String catId) =>
      throw UnimplementedError('TODO(Orang 2): watchCat');

  // TODO(Orang 2): get() dokumen CATS/{catId}.
  @override
  Future<Cat?> getCat(String catId) =>
      throw UnimplementedError('TODO(Orang 2): getCat');

  // TODO(Orang 2): set dokumen id = cat.catId, data cat.toFirestore().
  @override
  Future<void> createCat(Cat cat) =>
      throw UnimplementedError('TODO(Orang 2): createCat');

  // TODO(Orang 2): update dengan updated_at baru; jangan ubah owner_id.
  @override
  Future<void> updateCat(Cat cat) =>
      throw UnimplementedError('TODO(Orang 2): updateCat');
}
