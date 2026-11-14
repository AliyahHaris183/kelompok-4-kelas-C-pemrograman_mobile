import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 19: Calendar.
///
/// Kalender bulanan dengan avatar kucing pada tanggal berjadwal, navigasi bulan, ketuk tanggal untuk melihat jadwal. Hari libur Indonesia (asumsi, perlu dikonfirmasi, keputusan 7.9). catId opsional: jika ada, tampilkan kalender satu kucing.
///
/// TODO(Orang 3): implementasikan UI dan logika layar ini.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key, this.catId});

  /// Opsional.
  final String? catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = catId;
    return PlaceholderScreen(
      screenName: 'Calendar',
      screenNumber: 19,
      featureName: 'Care',
      owner: 'Orang 3',
      description:
          'Kalender bulanan dengan avatar kucing pada tanggal berjadwal, navigasi bulan, ketuk tanggal untuk melihat jadwal. Hari libur Indonesia (asumsi, perlu dikonfirmasi, keputusan 7.9). catId opsional: jika ada, tampilkan kalender satu kucing.',
      details: {if (id != null) 'catId': id},
    );
  }
}
