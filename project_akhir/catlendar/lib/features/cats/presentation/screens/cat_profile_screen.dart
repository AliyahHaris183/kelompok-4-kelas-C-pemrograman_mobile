import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 15: Profil kucing.
///
/// Nama. Satu baris info: umur, breed, warna, gender dan status steril. Tombol Edit Profile, Medical history, Calendar, Set a Schedule, Summary. Membaca CATS, MEDICAL_HISTORY, SCHEDULE.
///
/// TODO(Orang 2): implementasikan UI dan logika layar ini.
class CatProfileScreen extends ConsumerWidget {
  const CatProfileScreen({super.key, required this.catId});

  final String catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      screenName: 'Profil kucing',
      screenNumber: 15,
      featureName: 'Cats & Home',
      owner: 'Orang 2',
      description:
          'Nama. Satu baris info: umur, breed, warna, gender dan status steril. Tombol Edit Profile, Medical history, Calendar, Set a Schedule, Summary. Membaca CATS, MEDICAL_HISTORY, SCHEDULE.',
      details: {'catId': catId},
    );
  }
}
