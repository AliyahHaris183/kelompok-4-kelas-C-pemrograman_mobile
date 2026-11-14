import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Kontrak pengingat lokal terjadwal (milik Orang 3).
///
/// Aturan (lihat alur 5.5):
/// - Pengingat dibuat saat Save di Let's schedule.
/// - Jika jadwal diubah, batalkan notifikasi lama lewat [cancelReminder]
///   memakai local_notification_id yang tersimpan, lalu jadwalkan yang baru.
/// - Ini notifikasi lokal di perangkat, BUKAN pengiriman otomatis dari server.
abstract class LocalNotificationService {
  Future<void> initialize();

  /// [localNotificationId] adalah nilai yang disimpan di SCHEDULE.local_notification_id.
  Future<void> scheduleReminder({
    required String localNotificationId,
    required DateTime scheduledAt,
    required String title,
    required String body,
  });

  Future<void> cancelReminder(String localNotificationId);
}

/// Scaffold implementasi flutter_local_notifications. Belum berfungsi.
class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin plugin;

  // TODO(Orang 3): inisialisasi plugin (pengaturan Android/iOS), inisialisasi
  // timezone (tambahkan paket `timezone` via `flutter pub add timezone`),
  // minta izin notifikasi, lalu implementasikan zonedSchedule.
  // Catatan: plugin memakai id int, sedangkan ERD memakai string. Tentukan satu
  // pemetaan string -> int yang konsisten dan dokumentasikan.
  @override
  Future<void> initialize() =>
      throw UnimplementedError('TODO(Orang 3): inisialisasi notifikasi lokal');

  @override
  Future<void> scheduleReminder({
    required String localNotificationId,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) =>
      throw UnimplementedError('TODO(Orang 3): jadwalkan notifikasi lokal');

  @override
  Future<void> cancelReminder(String localNotificationId) =>
      throw UnimplementedError('TODO(Orang 3): batalkan notifikasi lokal');
}
