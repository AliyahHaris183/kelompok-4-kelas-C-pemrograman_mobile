import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 22: Edit profile.
///
/// Form sama dengan Set up profile, sudah terisi. Validasi sama. Ringkasan sebelum simpan. Memperbarui USERS dan updated_at.
///
/// TODO(Orang 1): implementasikan UI dan logika layar ini.
class EditOwnerProfileScreen extends ConsumerWidget {
  const EditOwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Edit profile',
      screenNumber: 22,
      featureName: 'Auth & Settings',
      owner: 'Orang 1',
      description:
          'Form sama dengan Set up profile, sudah terisi. Validasi sama. Ringkasan sebelum simpan. Memperbarui USERS dan updated_at.',
    );
  }
}
