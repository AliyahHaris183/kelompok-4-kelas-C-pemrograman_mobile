import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class LocalNotificationService {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<bool> scheduleReminder({
    required String localNotificationId,
    required DateTime scheduledAt,
    required String title,
    required String body,
  });

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  });

  Future<void> cancelReminder(String localNotificationId);

  String newNotificationId();
}

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

    final when = tz.TZDateTime.fromMillisecondsSinceEpoch(
      _utc ?? tz.getLocation('UTC'),
      scheduledAt.toUtc().millisecondsSinceEpoch,
    );

    try {
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
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    try {
      await initialize();
      final id = _random.nextInt(0x7FFFFFFE) + 1;
      await plugin.show(
        id: id,
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
      );
    } catch (_) {
      // Abaikan pada environment unit test tanpa platform channel.
    }
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
