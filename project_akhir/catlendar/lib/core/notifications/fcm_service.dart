import 'package:firebase_messaging/firebase_messaging.dart';

/// Kontrak pengelolaan token FCM (milik Orang 1).
///
/// Token disimpan ke USERS.fcm_token saat akun lengkap dan dihapus saat log out
/// (lihat features/auth/presentation/providers/fcm_token_sync.dart).
/// Push dikirim manual dari Firebase Console sebagai bukti integrasi FCM.
/// Pengiriman otomatis dari server butuh Cloud Functions (tidak dipakai).
abstract class FcmService {
  /// Meminta izin notifikasi (Android 13 ke atas menampilkan dialog izin).
  /// True jika diizinkan.
  Future<bool> requestPermission();

  /// Token FCM perangkat ini, atau null jika belum tersedia.
  Future<String?> getToken();

  /// Token baru saat FCM memperbarui token.
  Stream<String> get onTokenRefresh;

  /// Menghapus token perangkat (dipakai saat log out).
  Future<void> deleteToken();
}

/// Implementasi dengan firebase_messaging.
///
/// Pesan push saat aplikasi di latar belakang atau tertutup ditampilkan sistem
/// Android otomatis. Pesan saat aplikasi sedang terbuka (foreground) tidak
/// ditampilkan otomatis di Android.
class FirebaseMessagingFcmService implements FcmService {
  FirebaseMessagingFcmService(this.messaging);

  final FirebaseMessaging messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => messaging.onTokenRefresh;

  @override
  Future<void> deleteToken() => messaging.deleteToken();
}
