import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 3: Log in to your account.
///
/// Email dan password. Validasi: format email, password wajib. Tautan Forgot password dan Sign up. Memakai signInWithEmailAndPassword. Akun belum terverifikasi diarahkan ke Verifikasi email.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Log in to your account',
      screenNumber: 3,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Email dan password. Validasi: format email, password wajib. Tautan Forgot password dan Sign up. Memakai signInWithEmailAndPassword. Akun belum terverifikasi diarahkan ke Verifikasi email.',
    );
  }
}
