import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';

/// Menyimpan profil pemilik ke Firestore.
///
/// TODO(Orang 1): updateProfile untuk Edit profile (layar 22).
class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Membuat dokumen USERS dari draft (layar 11). True jika berhasil.
  ///
  /// TODO(Orang 1): isi fcm_token di sini setelah FcmService selesai (tahap FCM).
  Future<bool> saveNewProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw const AppException(
          'Sesi login tidak ditemukan. Silakan log in ulang.',
          type: AppErrorType.auth,
        );
      }

      final draft = ref.read(profileDraftProvider);
      final dateOfBirth = draft.dateOfBirth;
      if (draft.name.isEmpty || dateOfBirth == null) {
        throw const AppException(
          'Nama dan tanggal lahir wajib diisi.',
          type: AppErrorType.validation,
        );
      }

      final now = DateTime.now();
      await ref.read(userRepositoryProvider).createUser(
            AppUser(
              userId: user.uid,
              email: user.email ?? '',
              emailVerified: user.emailVerified,
              name: draft.name,
              dateOfBirth: dateOfBirth,
              gender: draft.gender,
              avatarId: draft.avatarId,
              onboardingDone: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    if (state.hasError) return false;
    ref.read(profileDraftProvider.notifier).clear();
    return true;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);
