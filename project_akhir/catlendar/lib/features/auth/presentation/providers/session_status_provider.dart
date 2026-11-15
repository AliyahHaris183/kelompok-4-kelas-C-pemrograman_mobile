import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/providers/firebase_providers.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';

/// Status sesi pengguna. Dibaca router untuk memutuskan layar mana yang boleh
/// dibuka (lihat app/router/route_guard.dart).
enum SessionStatus {
  /// Status login atau profil belum diketahui (aplikasi baru dibuka).
  loading,

  /// Belum login.
  signedOut,

  /// Sudah login, email belum diverifikasi.
  needsVerification,

  /// Sudah login dan terverifikasi, tetapi profil (USERS) belum dibuat.
  needsProfile,

  /// Akun lengkap. Boleh memakai seluruh aplikasi.
  ready,

  /// Gagal menentukan status (mis. profil tidak bisa dibaca). Diperlakukan
  /// seperti belum login supaya pengguna bisa mencoba log in ulang.
  error,
}

/// Penanda untuk menghitung ulang [sessionStatusProvider] secara manual.
///
/// Perlu karena status verifikasi email berubah lewat user.reload() tanpa
/// memicu stream login. Panggil refresh() setelah reload.
class SessionRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

final sessionRefreshProvider = NotifierProvider<SessionRefreshNotifier, int>(
  SessionRefreshNotifier.new,
);

/// Status sesi saat ini, dihitung dari:
///  1. status login Firebase Auth,
///  2. status verifikasi email,
///  3. dokumen USERS (ada atau tidak, dan onboarding_done).
final sessionStatusProvider = Provider<SessionStatus>((ref) {
  // Firebase belum terkonfigurasi: anggap belum login agar aplikasi tetap
  // terbuka (banner peringatan ditampilkan oleh CatlendarApp).
  if (!ref.watch(firebaseInitResultProvider).isInitialized) {
    return SessionStatus.signedOut;
  }

  ref.watch(sessionRefreshProvider);

  final authState = ref.watch(authStateChangesProvider);
  if (authState.hasError) return SessionStatus.error;
  if (!authState.hasValue) return SessionStatus.loading;

  // Ambil currentUser yang terbaru, bukan nilai lama dari stream, karena
  // emailVerified bisa berubah setelah reload.
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) return SessionStatus.signedOut;
  if (!user.emailVerified) return SessionStatus.needsVerification;

  final profile = ref.watch(currentUserProfileProvider);
  if (profile.hasError) return SessionStatus.error;
  if (!profile.hasValue) return SessionStatus.loading;

  final appUser = profile.valueOrNull;
  return (appUser != null && appUser.onboardingDone)
      ? SessionStatus.ready
      : SessionStatus.needsProfile;
});
