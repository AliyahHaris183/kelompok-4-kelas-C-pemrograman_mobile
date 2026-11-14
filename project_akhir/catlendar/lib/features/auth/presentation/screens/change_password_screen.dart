import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 23: Change password.
///
/// Password lama, password baru, konfirmasi. Validasi sama dengan Create password. Reautentikasi lalu updatePassword.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Change password',
      screenNumber: 23,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Password lama, password baru, konfirmasi. Validasi sama dengan Create password. Reautentikasi lalu updatePassword.',
    );
  }
}
