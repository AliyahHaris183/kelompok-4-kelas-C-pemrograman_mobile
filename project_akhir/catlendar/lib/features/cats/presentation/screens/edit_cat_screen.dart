import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 16: Edit profil kucing.
///
/// Form sama dengan Add your first cat, sudah terisi. Ringkasan sebelum simpan. Memperbarui CATS dan MEDICAL_HISTORY, updated_at diisi.
///
/// TODO(Orang 2): implementasikan UI dan logika layar ini.
class EditCatScreen extends ConsumerWidget {
  const EditCatScreen({super.key, required this.catId});

  final String catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      screenName: 'Edit profil kucing',
      screenNumber: 16,
      featureName: 'Cats & Home',
      owner: 'Orang 2',
      description:
          'Form sama dengan Add your first cat, sudah terisi. Ringkasan sebelum simpan. Memperbarui CATS dan MEDICAL_HISTORY, updated_at diisi.',
      details: {'catId': catId},
    );
  }
}
