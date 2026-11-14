import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 5: Sign up.
///
/// Email. Validasi: format wajib dan belum terdaftar. Email disimpan sementara di layar, lanjut ke Create password. Tautan Already have an account? Log in.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Sign up',
      screenNumber: 5,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Email. Validasi: format wajib dan belum terdaftar. Email disimpan sementara di layar, lanjut ke Create password. Tautan Already have an account? Log in.',
    );
  }
}
