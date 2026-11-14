import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 20: Summary.
///
/// Dikelompokkan per tanggal. Setiap entri: jenis perawatan (label Last atau Next), avatar dan nama kucing, tanggal. Membaca SCHEDULE, CARE_RECORD, CATS. catId opsional.
///
/// TODO(Orang 3): implementasikan UI dan logika layar ini.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, this.catId});

  /// Opsional.
  final String? catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = catId;
    return PlaceholderScreen(
      screenName: 'Summary',
      screenNumber: 20,
      featureName: 'Care',
      owner: 'Orang 3',
      description:
          'Dikelompokkan per tanggal. Setiap entri: jenis perawatan (label Last atau Next), avatar dan nama kucing, tanggal. Membaca SCHEDULE, CARE_RECORD, CATS. catId opsional.',
      details: {if (id != null) 'catId': id},
    );
  }
}
