import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 1: Hello.
///
/// Tampil dengan latar gradasi, lalu lanjut ke Welcome.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class HelloScreen extends ConsumerWidget {
  const HelloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Hello',
      screenNumber: 1,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Tampil dengan latar gradasi, lalu lanjut ke Welcome.',
    );
  }
}
