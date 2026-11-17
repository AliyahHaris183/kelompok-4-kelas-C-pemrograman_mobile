import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';

/// Menyimpan profil pemilik ke Firestore (onboarding dan edit profil).
class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Membuat dokumen USERS dari draft (layar 11). True jika berhasil.
  ///
  /// fcm_token tidak diisi di sini: fcm_token_sync.dart menyimpannya segera
  /// setelah dokumen dibuat dan status sesi menjadi ready.
  Future<bool> saveNewProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw _noSession();

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

  /// Edit profil pemilik (layar 22). gender/avatarId null berarti tidak diubah.
  Future<bool> updateProfile({
    required String name,
    required DateTime dateOfBirth,
    String? gender,
    String? avatarId,
  }) {
    return _update(
      (current) => _withChanges(
        current,
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        avatarId: avatarId,
      ),
    );
  }

  /// Ganti avatar dari Settings (layar 21).
  Future<bool> updateAvatar(String avatarId) {
    return _update((current) => _withChanges(current, avatarId: avatarId));
  }

  /// Membaca dokumen terbaru, menerapkan perubahan, lalu menyimpannya.
  Future<bool> _update(AppUser Function(AppUser current) change) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(authRepositoryProvider).currentUser?.uid;
      if (userId == null) throw _noSession();

      final repository = ref.read(userRepositoryProvider);
      final current = await repository.getUser(userId);
      if (current == null) {
        throw const AppException(
          'Profil tidak ditemukan.',
          type: AppErrorType.notFound,
        );
      }
      await repository.updateUser(change(current));
    });
    return !state.hasError;
  }

  AppUser _withChanges(
    AppUser user, {
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? avatarId,
  }) {
    return AppUser(
      userId: user.userId,
      email: user.email,
      emailVerified: user.emailVerified,
      name: name ?? user.name,
      dateOfBirth: dateOfBirth ?? user.dateOfBirth,
      gender: gender ?? user.gender,
      avatarId: avatarId ?? user.avatarId,
      onboardingDone: user.onboardingDone,
      fcmToken: user.fcmToken,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  AppException _noSession() => const AppException(
        'Sesi login tidak ditemukan. Silakan log in ulang.',
        type: AppErrorType.auth,
      );
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);
