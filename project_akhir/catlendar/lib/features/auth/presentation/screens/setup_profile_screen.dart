import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 9: Set up your profile.
///
/// Pilih avatar preset, Name, Date of birth, Gender. Validasi: nama dan tanggal lahir wajib. Belum menulis ke Firestore sampai Simpan.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class SetupProfileScreen extends ConsumerWidget {
  const SetupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Set up your profile',
      screenNumber: 9,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Pilih avatar preset, Name, Date of birth, Gender. Validasi: nama dan tanggal lahir wajib. Belum menulis ke Firestore sampai Simpan.',
    );
  }
}
