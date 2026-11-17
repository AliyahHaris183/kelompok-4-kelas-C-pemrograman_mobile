import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/constants/avatar_presets.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/widgets/async_value_view.dart';
import 'package:catlendar/core/widgets/empty_view.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/logout_confirmation.dart';
import 'package:catlendar/shared/widgets/avatar_selector.dart';

/// Layar 21: Settings. Foto profil (pilih avatar preset), Edit profile,
/// Change password, dan Log out. Membaca USERS.
///
/// TODO(Orang 1): ganti tampilan avatar bawaan (ikon) dengan aset avatar dari
/// Figma lewat parameter avatarBuilder pada AvatarSelector.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _changeAvatar(
    BuildContext context,
    WidgetRef ref,
    String avatarId,
  ) async {
    final ok =
        await ref.read(profileControllerProvider.notifier).updateAvatar(avatarId);
    if (ok || !context.mounted) return;

    final error = ref.read(profileControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? 'Gagal mengganti avatar.'
              : AppException.from(error).message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthMascot(assetPath: AppAssets.catSignup),
          const SizedBox(height: 8),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          AsyncValueView<AppUser?>(
            value: profile,
            builder: (user) {
              if (user == null) {
                return const EmptyView(message: 'Profil tidak ditemukan');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Profile picture', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  AvatarSelector(
                    avatarIds: AvatarPresets.ownerAvatarIds,
                    selectedId: user.avatarId,
                    onChanged: (id) => _changeAvatar(context, ref, id),
                    size: 48,
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
