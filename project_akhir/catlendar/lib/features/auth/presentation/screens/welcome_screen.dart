import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 2: Welcome to Catlendar.
///
/// Logo kucing, lalu lanjut ke Log in.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Welcome to Catlendar',
      screenNumber: 2,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Logo kucing, lalu lanjut ke Log in.',
    );
  }
}
