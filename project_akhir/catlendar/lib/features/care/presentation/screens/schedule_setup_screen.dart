import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 18: Schedule next grooming.
///
/// Next bath, flea, fungal, vet visit, vaccination, custom event. Remind me: a week, 3 days, 1 day, D-day, atau tidak. Validasi: tanggal berikutnya tidak sebelum tanggal terakhir. Save: SCHEDULE, batalkan notifikasi lama, jadwalkan notifikasi lokal baru, simpan local_notification_id.
///
/// TODO(Orang 3): implementasikan UI dan logika layar ini.
class ScheduleSetupScreen extends ConsumerWidget {
  const ScheduleSetupScreen({super.key, required this.catId});

  final String catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      screenName: 'Schedule next grooming',
      screenNumber: 18,
      featureName: 'Care',
      owner: 'Orang 3',
      description:
          'Next bath, flea, fungal, vet visit, vaccination, custom event. Remind me: a week, 3 days, 1 day, D-day, atau tidak. Validasi: tanggal berikutnya tidak sebelum tanggal terakhir. Save: SCHEDULE, batalkan notifikasi lama, jadwalkan notifikasi lokal baru, simpan local_notification_id.',
      details: {'catId': catId},
    );
  }
}
