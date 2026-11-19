import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/providers/media_providers.dart';

/// Memilih foto dari galeri lalu mengunggahnya ke Cloudinary.
/// Tidak menulis ke Firestore: URL yang dikembalikan disimpan oleh pemanggil
/// (draft profil saat onboarding, atau ProfileController di Settings).
class ProfilePhotoController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// URL foto yang berhasil diunggah. Null jika pengguna membatalkan pilihan
  /// (tanpa error) atau jika gagal (error ada di state).
  Future<String?> pickAndUpload() async {
    String? url;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final picked = await ref.read(imagePickerServiceProvider).pickFromGallery();
      if (picked == null) return;
      url = await ref
          .read(imageUploaderProvider)
          .upload(bytes: picked.bytes, filename: picked.name);
    });
    return state.hasError ? null : url;
  }
}

final profilePhotoControllerProvider =
    AsyncNotifierProvider<ProfilePhotoController, void>(
  ProfilePhotoController.new,
);
