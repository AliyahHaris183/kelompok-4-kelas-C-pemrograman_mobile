import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 17: Last grooming details.
///
/// Last bath, flea, fungal, vet visit, vaccination, custom event. Semua opsional. Setiap tanggal yang diisi menjadi satu baris CARE_RECORD baru (log, tidak menimpa).
///
/// TODO(Orang 3): implementasikan UI dan logika layar ini.
class GroomingHistoryScreen extends ConsumerWidget {
  const GroomingHistoryScreen({super.key, required this.catId});

  final String catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      screenName: 'Last grooming details',
      screenNumber: 17,
      featureName: 'Care',
      owner: 'Orang 3',
      description:
          'Last bath, flea, fungal, vet visit, vaccination, custom event. Semua opsional. Setiap tanggal yang diisi menjadi satu baris CARE_RECORD baru (log, tidak menimpa).',
      details: {'catId': catId},
    );
  }
}
