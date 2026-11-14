import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/features/auth/presentation/widgets/logout_confirmation.dart';
import 'package:catlendar/shared/widgets/placeholder_screen.dart';
import 'package:catlendar/shared/widgets/primary_button.dart';

/// Layar 21: Settings.
///
/// Foto profil (pilih avatar preset), Edit profile, Change password, Log out (dengan konfirmasi). Membaca USERS.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      screenName: 'Settings',
      screenNumber: 21,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Foto profil (pilih avatar preset), Edit profile, Change password, Log out (dengan konfirmasi). Membaca USERS.',
      actions: [
        PrimaryButton(
          label: 'Log out',
          isOutlined: true,
          onPressed: () => confirmAndLogout(context, ref),
        ),
      ],
    );
  }
}
