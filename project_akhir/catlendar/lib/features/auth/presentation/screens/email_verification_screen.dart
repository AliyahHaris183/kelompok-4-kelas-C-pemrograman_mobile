import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 7: Verifikasi email.
///
/// Tautan sudah dikirim ke email. Continue memeriksa status (reload user, cek email_verified). Jika belum terverifikasi tampil pesan. Sediakan Resend email verifikasi.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Verifikasi email',
      screenNumber: 7,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Tautan sudah dikirim ke email. Continue memeriksa status (reload user, cek email_verified). Jika belum terverifikasi tampil pesan. Sediakan Resend email verifikasi.',
    );
  }
}
