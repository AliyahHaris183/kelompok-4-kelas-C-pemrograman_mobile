import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 4: Forgot password.
///
/// Masukkan email, lalu kirim tautan reset (sendPasswordResetEmail).
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Forgot password',
      screenNumber: 4,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Masukkan email, lalu kirim tautan reset (sendPasswordResetEmail).',
    );
  }
}
