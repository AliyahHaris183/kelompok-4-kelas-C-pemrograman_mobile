import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';

enum AppErrorType { auth, permission, network, notFound, validation, unknown }

/// Representasi error aplikasi yang aman ditampilkan ke pengguna.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.type = AppErrorType.unknown,
    this.code,
    this.cause,
  });

  /// Pesan untuk pengguna (Bahasa Indonesia).
  final String message;
  final AppErrorType type;
  final String? code;
  final Object? cause;

  /// Mengubah error apa pun (Firebase atau lainnya) menjadi [AppException].
  factory AppException.from(Object error) {
    if (error is AppException) return error;

    if (error is FirebaseAuthException) {
      return AppException(
        _authMessage(error.code),
        type: AppErrorType.auth,
        code: error.code,
        cause: error,
      );
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return AppException(
            'Kamu tidak punya akses ke data ini.',
            type: AppErrorType.permission,
            code: error.code,
            cause: error,
          );
        case 'unavailable':
          return AppException(
            'Layanan tidak dapat dihubungi. Periksa koneksi internet.',
            type: AppErrorType.network,
            code: error.code,
            cause: error,
          );
        case 'not-found':
          return AppException(
            'Data tidak ditemukan.',
            type: AppErrorType.notFound,
            code: error.code,
            cause: error,
          );
      }
    }

    return AppException('Terjadi kesalahan tak terduga.', cause: error);
  }

  @override
  String toString() => 'AppException($type, $code): $message';
}

String _authMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Format email tidak valid.';
    case 'user-disabled':
      return 'Akun ini dinonaktifkan.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email atau password salah.';
    case 'email-already-in-use':
      return 'Email sudah terdaftar.';
    case 'weak-password':
      return 'Password terlalu lemah.';
    case 'requires-recent-login':
      return 'Masukkan ulang password untuk melanjutkan.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    case 'network-request-failed':
      return 'Koneksi internet bermasalah.';
    default:
      return 'Autentikasi gagal ($code).';
  }
}
