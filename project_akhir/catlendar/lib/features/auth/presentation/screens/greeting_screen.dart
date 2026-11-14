import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 8: Good to see you back.
///
/// Sapaan nama setelah Log in berhasil, lalu lanjut. Membaca USERS.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class GreetingScreen extends ConsumerWidget {
  const GreetingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Good to see you back',
      screenNumber: 8,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Sapaan nama setelah Log in berhasil, lalu lanjut. Membaca USERS.',
    );
  }
}
