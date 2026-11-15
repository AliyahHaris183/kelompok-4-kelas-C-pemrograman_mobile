import 'package:firebase_auth/firebase_auth.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/features/auth/domain/repositories/auth_repository.dart';

/// Repository Firebase Authentication (email dan password). Milik Orang 1.
///
/// Error Firebase (FirebaseAuthException) sengaja tidak dibungkus di sini.
/// Pemanggil mengubahnya dengan AppException.from(error) untuk pesan pengguna.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.auth);

  final FirebaseAuth auth;

  @override
  Stream<User?> authStateChanges() => auth.authStateChanges();

  @override
  User? get currentUser => auth.currentUser;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Email yang sudah terdaftar ditolak Firebase (kode email-already-in-use).
  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.sendEmailVerification();
  }

  @override
  Future<void> sendEmailVerification() async {
    await _requireUser().sendEmailVerification();
  }

  @override
  Future<bool> reloadAndCheckEmailVerified() async {
    await _requireUser().reload();
    // Ambil ulang currentUser: objek lama bisa menyimpan status lama.
    return auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null) {
      throw const AppException(
        'Akun ini tidak memiliki email.',
        type: AppErrorType.auth,
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // TODO(Orang 1): urutan log out yang benar: hapus fcm_token di USERS DULU
  // (UserRepository.updateFcmToken dengan null), baru panggil signOut.
  // Setelah sign out, Security Rules menolak penulisan ke USERS.
  @override
  Future<void> signOut() => auth.signOut();

  User _requireUser() {
    final user = auth.currentUser;
    if (user == null) {
      throw const AppException(
        'Sesi login tidak ditemukan. Silakan log in ulang.',
        type: AppErrorType.auth,
      );
    }
    return user;
  }
}
