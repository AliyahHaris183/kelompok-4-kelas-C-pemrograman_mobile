import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 10: Date of birth.
///
/// Pemilih tanggal saja, tanpa jam (keputusan 7.3). Gender. Continue.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class DateOfBirthScreen extends ConsumerWidget {
  const DateOfBirthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Date of birth',
      screenNumber: 10,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Pemilih tanggal saja, tanpa jam (keputusan 7.3). Gender. Continue.',
    );
  }
}
