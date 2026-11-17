import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, debugPrintStack;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/notifications/fcm_service.dart';
import 'package:catlendar/core/providers/notification_providers.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';

/// Menyimpan token FCM perangkat ke USERS.fcm_token dan menjaganya tetap baru.
///
/// Kegagalan (izin ditolak, tanpa Google Play Services, platform yang tidak
/// mendukung FCM) hanya dicatat dan tidak pernah melempar error ke pengguna.
class FcmTokenSync {
  FcmTokenSync({required FcmService fcm, required UserRepository users})
      : _fcm = fcm,
        _users = users;

  final FcmService _fcm;
  final UserRepository _users;

  StreamSubscription<String>? _refreshSubscription;

  /// Naik setiap start/stop. Dipakai membatalkan start yang sedang berjalan
  /// bila stop dipanggil di tengah jalan (mis. pengguna langsung log out).
  int _generation = 0;

  Future<void> start(String userId) async {
    final generation = ++_generation;
    await _cancelSubscription();

    try {
      final granted = await _fcm.requestPermission();
      if (generation != _generation) return;
      if (!granted) {
        debugPrint('Izin notifikasi tidak diberikan. Token tetap disimpan.');
      }

      final token = await _fcm.getToken();
      if (generation != _generation) return;
      if (token != null) {
        await _users.updateFcmToken(userId: userId, token: token);
        if (generation != _generation) return;
      }

      _refreshSubscription = _fcm.onTokenRefresh.listen(
        (newToken) => _save(userId, newToken),
      );
    } catch (error, stackTrace) {
      debugPrint('Sinkronisasi token FCM gagal: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Berhenti mendengarkan dan membatalkan start yang sedang berjalan.
  Future<void> stop() async {
    _generation++;
    await _cancelSubscription();
  }

  Future<void> _cancelSubscription() async {
    final subscription = _refreshSubscription;
    _refreshSubscription = null;
    await subscription?.cancel();
  }

  Future<void> _save(String userId, String token) async {
    try {
      await _users.updateFcmToken(userId: userId, token: token);
    } catch (error) {
      debugPrint('Gagal memperbarui token FCM: $error');
    }
  }
}

final fcmTokenSyncProvider = Provider<FcmTokenSync>(
  (ref) => FcmTokenSync(
    fcm: ref.watch(fcmServiceProvider),
    users: ref.watch(userRepositoryProvider),
  ),
);

/// Menghubungkan status sesi ke [FcmTokenSync]: mulai saat status menjadi
/// ready (login, buka aplikasi, atau selesai onboarding), berhenti selain itu.
/// Dipasang sekali di CatlendarApp.
final fcmSessionBindingProvider = Provider<void>((ref) {
  FcmTokenSync? active;

  void stopActive() {
    final current = active;
    active = null;
    if (current != null) unawaited(current.stop());
  }

  ref.listen<SessionStatus>(sessionStatusProvider, (previous, next) {
    if (next == SessionStatus.ready) {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        final sync = ref.read(fcmTokenSyncProvider);
        active = sync;
        unawaited(sync.start(userId));
        return;
      }
    }
    stopActive();
  }, fireImmediately: true);

  ref.onDispose(stopActive);
});
