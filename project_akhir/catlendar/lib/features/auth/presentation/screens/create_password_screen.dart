import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 6: Please create a password.
///
/// Password dan konfirmasi. Validasi: minimal 6 karakter, konfirmasi harus sama. createUserWithEmailAndPassword lalu sendEmailVerification.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class CreatePasswordScreen extends ConsumerWidget {
  const CreatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Please create a password',
      screenNumber: 6,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Password dan konfirmasi. Validasi: minimal 6 karakter, konfirmasi harus sama. createUserWithEmailAndPassword lalu sendEmailVerification.',
    );
  }
}
