import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 13: Ringkasan kucing.
///
/// Tampilkan data kucing dan peringatan sebelum simpan. Tombol Kembali dan Simpan: membuat CATS dan MEDICAL_HISTORY.
///
/// TODO(Orang 2): implementasikan UI dan logika layar ini.
class CatSummaryScreen extends ConsumerWidget {
  const CatSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Ringkasan kucing',
      screenNumber: 13,
      featureName: 'Cats & Home',
      owner: 'Orang 2',
      description:
          'Tampilkan data kucing dan peringatan sebelum simpan. Tombol Kembali dan Simpan: membuat CATS dan MEDICAL_HISTORY.',
    );
  }
}
