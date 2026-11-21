import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Kontrak pengingat lokal terjadwal (milik Orang 3).
///
/// Aturan (lihat alur 5.5):
/// - Pengingat dibuat saat Save di Let's schedule.
/// - Jika jadwal diubah, batalkan notifikasi lama lewat [cancelReminder]
///   memakai local_notification_id yang tersimpan, lalu jadwalkan yang baru.
/// - Ini notifikasi lokal di perangkat, BUKAN pengiriman otomatis dari server.
abstract class LocalNotificationService {
  Future<void> initialize();

  /// Meminta izin notifikasi (Android 13 ke atas). True jika diizinkan.
  Future<bool> requestPermission();

  /// [localNotificationId] adalah nilai yang disimpan di SCHEDULE.local_notification_id.
  /// Mengembalikan false jika [scheduledAt] sudah lewat dan tidak dijadwalkan.
  Future<bool> scheduleReminder({
    required String localNotificationId,
    required DateTime scheduledAt,
    required String title,
    required String body,
  });

  Future<void> cancelReminder(String localNotificationId);

  /// Membuat local_notification_id baru (string berisi int 1..2^31-2).
  String newNotificationId();
}

/// Implementasi flutter_local_notifications.
///
/// Pemetaan ID: ERD memakai string, plugin memakai int. local_notification_id
/// disimpan sebagai string dari int acak yang unik, lalu di-parse kembali ke int
/// saat dibatalkan. Dengan begitu tidak perlu tabel pemetaan tambahan.
class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin plugin;

  static const String _channelId = 'care_reminders';
  static const String _channelName = 'Pengingat perawatan';
  static final Random _random = Random.secure();

  bool _initialized = false;
  tz.Location? _utc;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    _utc = tz.getLocation('UTC');

    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  @override
  Future<bool> scheduleReminder({
    required String localNotificationId,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    if (!scheduledAt.isAfter(DateTime.now())) return false;

    final id = int.tryParse(localNotificationId);
    if (id == null) {
      throw ArgumentError('local_notification_id harus berisi angka: $localNotificationId');
    }

    // zonedSchedule memakai instan waktu (epoch), jadi representasi UTC sudah
    // menunjuk momen yang benar untuk perangkat di zona mana pun.
    final when = tz.TZDateTime.fromMillisecondsSinceEpoch(
      _utc ?? tz.getLocation('UTC'),
      scheduledAt.toUtc().millisecondsSinceEpoch,
    );

    await plugin.zonedSchedule(
      id: id,
      scheduledDate: when,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // inexact: tidak butuh izin alarm persis (SCHEDULE_EXACT_ALARM).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  @override
  Future<void> cancelReminder(String localNotificationId) async {
    final id = int.tryParse(localNotificationId);
    if (id == null) return;
    await plugin.cancel(id: id);
  }

  @override
  String newNotificationId() => (_random.nextInt(0x7FFFFFFE) + 1).toString();
}
