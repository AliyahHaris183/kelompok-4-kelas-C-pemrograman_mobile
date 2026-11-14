import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';

/// Contoh pola AsyncNotifier untuk aksi autentikasi. Layar cukup membaca
/// state (AsyncValue) dan memanggil method; tidak ada logika di layar.
///
/// TODO(Orang 1): tambahkan signUp, createPassword, resendVerification,
/// checkVerified, sendPasswordReset, changePassword, signOut, dan simpan profil.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password),
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
