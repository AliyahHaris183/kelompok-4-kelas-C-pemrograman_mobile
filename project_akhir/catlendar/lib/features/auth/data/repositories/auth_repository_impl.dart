import 'package:firebase_auth/firebase_auth.dart';

import 'package:catlendar/features/auth/domain/repositories/auth_repository.dart';

/// Scaffold. Hanya pembungkus tipis yang sudah berfungsi (authStateChanges,
/// currentUser). Sisanya TODO Orang 1.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.auth);

  final FirebaseAuth auth;

  @override
  Stream<User?> authStateChanges() => auth.authStateChanges();

  @override
  User? get currentUser => auth.currentUser;

  // TODO(Orang 1): signInWithEmailAndPassword. Akun belum terverifikasi
  // diarahkan ke layar Verifikasi email.
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError('TODO(Orang 1): signInWithEmail');

  // TODO(Orang 1): createUserWithEmailAndPassword lalu sendEmailVerification.
  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError('TODO(Orang 1): signUpWithEmail');

  // TODO(Orang 1): currentUser.sendEmailVerification().
  @override
  Future<void> sendEmailVerification() =>
      throw UnimplementedError('TODO(Orang 1): sendEmailVerification');

  // TODO(Orang 1): currentUser.reload() lalu baca emailVerified.
  @override
  Future<bool> reloadAndCheckEmailVerified() =>
      throw UnimplementedError('TODO(Orang 1): reloadAndCheckEmailVerified');

  // TODO(Orang 1): sendPasswordResetEmail.
  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError('TODO(Orang 1): sendPasswordResetEmail');

  // TODO(Orang 1): reauthenticateWithCredential lalu updatePassword.
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError('TODO(Orang 1): changePassword');

  // TODO(Orang 1): hapus fcm_token di USERS dulu, baru signOut.
  @override
  Future<void> signOut() =>
      throw UnimplementedError('TODO(Orang 1): signOut');
}
