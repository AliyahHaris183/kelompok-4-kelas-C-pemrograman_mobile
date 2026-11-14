import 'package:firebase_auth/firebase_auth.dart';

/// Kontrak Firebase Authentication (email dan password). Milik Orang 1.
abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;

  Future<void> signInWithEmail({required String email, required String password});

  /// Membuat akun (layar Create password). Email yang sudah terdaftar akan
  /// ditolak Firebase dengan kode email-already-in-use.
  Future<void> signUpWithEmail({required String email, required String password});

  Future<void> sendEmailVerification();

  /// Reload user lalu kembalikan status emailVerified (layar Verifikasi email).
  Future<bool> reloadAndCheckEmailVerified();

  Future<void> sendPasswordResetEmail(String email);

  /// Reautentikasi dengan password lama, lalu updatePassword.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();
}
