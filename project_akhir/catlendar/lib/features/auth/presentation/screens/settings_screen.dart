import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/widgets/async_value_view.dart';
import 'package:catlendar/core/widgets/empty_view.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_photo_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/logout_confirmation.dart';
import 'package:catlendar/features/auth/presentation/widgets/profile_photo_picker.dart';

/// Layar 21: Settings. Foto profil (ambil dari galeri atau avatar preset),
/// Edit profile, Change password, dan Log out. Membaca USERS.
///
/// Change email dan Delete account pada Figma sengaja tidak ada
/// (keputusan 7.7: dihapus dari alur).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showError(BuildContext context, Object? error, String fallback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null ? fallback : AppException.from(error).message,
        ),
      ),
    );
  }

  /// Menyimpan avatar_id (id preset atau URL foto) ke USERS.
  Future<void> _saveAvatar(
    BuildContext context,
    WidgetRef ref,
    String avatarId,
  ) async {
    final ok =
        await ref.read(profileControllerProvider.notifier).updateAvatar(avatarId);
    if (ok || !context.mounted) return;
    _showError(
      context,
      ref.read(profileControllerProvider).error,
      'Gagal mengganti foto profil.',
    );
  }

  /// Pilih dari galeri, unggah ke Cloudinary, lalu simpan URL-nya.
  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final url =
        await ref.read(profilePhotoControllerProvider.notifier).pickAndUpload();
    if (!context.mounted) return;

    if (url == null) {
      // Null tanpa error berarti pengguna membatalkan pilihan.
      final error = ref.read(profilePhotoControllerProvider).error;
      if (error != null) _showError(context, error, 'Gagal mengunggah foto.');
      return;
    }
    await _saveAvatar(context, ref, url);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;
    final isPhotoBusy = ref.watch(profilePhotoControllerProvider).isLoading ||
        ref.watch(profileControllerProvider).isLoading;

    return AuthScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthMascot(assetPath: AppAssets.catSetupSettings),
          const SizedBox(height: 8),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          AsyncValueView<AppUser?>(
            value: profile,
            builder: (user) {
              if (user == null) {
                return const EmptyView(message: 'Profil tidak ditemukan');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ProfilePhotoPicker(
                      avatarId: user.avatarId,
                      isUploading: isPhotoBusy,
                      onChooseFromGallery: () => _pickPhoto(context, ref),
                      onChoosePreset: (id) => _saveAvatar(context, ref, id),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    label: 'Edit profile',
                    onPressed: () =>
                        context.push(AppRoutes.editOwnerProfile.path),
                  ),
                  const SizedBox(height: 12),
                  AuthButton(
                    label: 'Change password',
                    onPressed: () =>
                        context.push(AppRoutes.changePassword.path),
                  ),
                  const SizedBox(height: 12),
                  AuthButton(
                    label: 'Log out',
                    isOutlined: true,
                    isLoading: isLoggingOut,
                    onPressed: () => confirmAndLogout(context, ref),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
