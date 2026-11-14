import 'package:firebase_messaging/firebase_messaging.dart';

/// Kontrak pengelolaan token FCM (milik Orang 1; Orang 3 hanya memakai hasilnya).
///
/// Token disimpan ke USERS.fcm_token saat login dan dihapus saat log out.
/// Push dikirim manual dari Firebase Console sebagai bukti integrasi FCM.
/// Pengiriman otomatis dari server butuh Cloud Functions (tidak dipakai).
abstract class FcmService {
  Future<void> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
}

/// Scaffold implementasi FirebaseMessaging. Belum berfungsi.
class FirebaseMessagingFcmService implements FcmService {
  FirebaseMessagingFcmService(this.messaging);

  final FirebaseMessaging messaging;

  // TODO(Orang 1): implementasikan requestPermission, getToken, onTokenRefresh,
  // dan penanganan pesan foreground/background.
  @override
  Future<void> requestPermission() =>
      throw UnimplementedError('TODO(Orang 1): minta izin notifikasi FCM');

  @override
  Future<String?> getToken() =>
      throw UnimplementedError('TODO(Orang 1): ambil token FCM');

  @override
  Stream<String> get onTokenRefresh =>
      throw UnimplementedError('TODO(Orang 1): stream refresh token FCM');
}
