import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/notifications/fcm_service.dart';
import 'package:catlendar/core/notifications/local_notification_service.dart';
import 'package:catlendar/core/providers/firebase_providers.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => FlutterLocalNotificationService(),
);

final fcmServiceProvider = Provider<FcmService>(
  (ref) => FirebaseMessagingFcmService(ref.watch(firebaseMessagingProvider)),
);
