import 'package:catlendar/features/auth/data/models/app_user.dart';

/// Kontrak koleksi USERS. Dokumen: USERS/{uid}. Milik Orang 1.
/// Tidak ada delete: Security Rules melarangnya (keputusan 7.7).
abstract class UserRepository {
  Future<AppUser?> getUser(String userId);
  Stream<AppUser?> watchUser(String userId);

  /// Dipanggil sekali di layar Ringkasan profil (onboarding_done = true).
  Future<void> createUser(AppUser user);

  /// Edit profil pemilik. Perbarui updated_at.
  Future<void> updateUser(AppUser user);

  /// Simpan token FCM saat login; kirim null saat log out.
  Future<void> updateFcmToken({required String userId, required String? token});
}
