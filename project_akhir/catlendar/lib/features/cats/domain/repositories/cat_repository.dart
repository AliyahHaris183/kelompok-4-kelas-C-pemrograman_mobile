import 'package:catlendar/features/cats/data/models/cat.dart';

/// Kontrak koleksi CATS. Milik Orang 2.
///
/// PENTING: Security Rules memeriksa owner_id pada setiap dokumen, dan Firestore
/// menolak query yang tidak bisa dibuktikan aman. Semua query list WAJIB memuat
/// where('owner_id', isEqualTo: uid).
abstract class CatRepository {
  /// ID dokumen baru (lokal, tanpa jaringan).
  String newId();

  Stream<List<Cat>> watchCatsByOwner(String ownerId);
  Stream<Cat?> watchCat(String catId);
  Future<Cat?> getCat(String catId);

  Future<void> createCat(Cat cat);

  /// Perbarui updated_at. owner_id tidak boleh berubah.
  Future<void> updateCat(Cat cat);

  Future<void> deleteCat(String catId);
}
