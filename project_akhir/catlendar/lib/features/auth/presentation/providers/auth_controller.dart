import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/providers/notification_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/fcm_token_sync.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';

/// Tujuan setelah log in atau verifikasi email berhasil.
enum PostLoginDestination {
  /// Email belum diverifikasi -> layar Verifikasi email.
  verifyEmail,

  /// Akun sudah terverifikasi tetapi profil belum dibuat -> Set up profile.
  setupProfile,

  /// Akun lengkap -> Greeting, lalu Home.
  greeting,
}

/// Controller aksi autentikasi. Layar hanya membaca state (AsyncValue) dan
/// memanggil method di sini; tidak ada logika Firebase di layar.
///
/// Catatan: satu controller dipakai bersama oleh banyak layar. Baca
/// state.error segera setelah aksi selesai, jangan disimpan antar layar.
///
/// Catatan: router (route_guard.dart) kini juga mengarahkan pengguna sesuai
/// status sesi. Navigasi eksplisit di layar tetap dipertahankan dan selalu
/// menuju tujuan yang sama dengan redirect.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Menjalankan [action] dengan state loading/error. True jika berhasil.
  Future<bool> _runVoid(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }

  Future<PostLoginDestination> _resolveDestination(User? user) async {
    if (user == null) {
      throw const AppException(
        'Sesi login tidak ditemukan. Silakan log in ulang.',
        type: AppErrorType.auth,
      );
    }
    if (!user.emailVerified) return PostLoginDestination.verifyEmail;

    final profile = await ref.read(userRepositoryProvider).getUser(user.uid);
    return (profile != null && profile.onboardingDone)
        ? PostLoginDestination.greeting
        : PostLoginDestination.setupProfile;
  }

  /// Tujuan navigasi jika berhasil, null jika gagal (error ada di state).
  /// fcm_token disimpan oleh fcm_token_sync.dart saat status sesi menjadi ready.
  Future<PostLoginDestination?> signIn({
    required String email,
    required String password,
  }) async {
    PostLoginDestination? destination;
    final ok = await _runVoid(() async {
      final auth = ref.read(authRepositoryProvider);
      await auth.signInWithEmail(email: email, password: password);
      destination = await _resolveDestination(auth.currentUser);
    });
    return ok ? destination : null;
  }

  /// Membuat akun dan mengirim email verifikasi. Email yang sudah terdaftar
  /// gagal dengan kode email-already-in-use.
  Future<bool> signUp({required String email, required String password}) async {
    final ok = await _runVoid(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmail(email: email, password: password),
    );
    // Dibersihkan di sini (bukan di layar), karena router bisa memindahkan
    // pengguna dari layar Create password sebelum fungsi ini selesai.
    if (ok) ref.read(signUpEmailProvider.notifier).clear();
    return ok;
  }

  /// Memeriksa status verifikasi (reload user).
  /// Hasil [PostLoginDestination.verifyEmail] berarti email masih belum
  /// diverifikasi (bukan error). Null berarti gagal.
  Future<PostLoginDestination?> checkEmailVerified() async {
    PostLoginDestination? destination;
    final ok = await _runVoid(() async {
      final auth = ref.read(authRepositoryProvider);
      await auth.reloadAndCheckEmailVerified();
      // Status verifikasi berubah tanpa memicu stream login, jadi router perlu
      // diberi tahu agar menghitung ulang aturan aksesnya.
      ref.read(sessionRefreshProvider.notifier).refresh();
      destination = await _resolveDestination(auth.currentUser);
    });
    return ok ? destination : null;
  }

  Future<bool> resendVerification() {
    return _runVoid(() => ref.read(authRepositoryProvider).sendEmailVerification());
  }

  Future<bool> sendPasswordReset(String email) {
    return _runVoid(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
  }

  /// Hanya aman dipakai sebelum ada fcm_token (mis. layar Verifikasi email).
  /// Untuk Log out dari Settings pakai [logout].
  Future<bool> signOut() {
    return _runVoid(() => ref.read(authRepositoryProvider).signOut());
  }

  /// Ubah password (layar 23): reautentikasi dengan password lama, lalu
  /// updatePassword. Password lama salah gagal dengan kode wrong-password
  /// atau invalid-credential.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _runVoid(
      () => ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
    );
  }

  /// Log out (layar 24). Urutan:
  ///  1. hentikan sinkronisasi token agar tidak menulis ulang saat logout,
  ///  2. hapus USERS.fcm_token (harus sebelum signOut, karena setelah sign out
  ///     Security Rules menolak penulisan ke USERS),
  ///  3. hapus token di perangkat agar tidak terbawa ke akun berikutnya,
  ///  4. signOut. Router lalu mengarahkan ke Welcome.
  ///
  /// Langkah 2 dan 3 best effort (batas waktu 5 detik): jika offline atau
  /// gagal, pengguna tetap bisa keluar.
  Future<bool> logout() {
    return _runVoid(() async {
      final auth = ref.read(authRepositoryProvider);
      final userId = auth.currentUser?.uid;

      await ref.read(fcmTokenSyncProvider).stop();

      if (userId != null) {
        try {
          await ref
              .read(userRepositoryProvider)
              .updateFcmToken(userId: userId, token: null)
              .timeout(const Duration(seconds: 5));
        } catch (_) {
          // Sengaja diabaikan: gagal menghapus token tidak boleh menghalangi
          // pengguna keluar dari akun.
        }
      }

      try {
        await ref
            .read(fcmServiceProvider)
            .deleteToken()
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Sama seperti di atas.
      }

      await auth.signOut();
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
