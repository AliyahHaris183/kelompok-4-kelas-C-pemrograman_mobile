import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 11: Ringkasan profil.
///
/// Tampilkan nama, tanggal lahir, gender, dan peringatan sebelum simpan. Tombol Kembali dan Simpan: membuat USERS, onboarding_done = true, menyimpan fcm_token.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class ProfileSummaryScreen extends ConsumerWidget {
  const ProfileSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Ringkasan profil',
      screenNumber: 11,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Tampilkan nama, tanggal lahir, gender, dan peringatan sebelum simpan. Tombol Kembali dan Simpan: membuat USERS, onboarding_done = true, menyimpan fcm_token.',
    );
  }
}
