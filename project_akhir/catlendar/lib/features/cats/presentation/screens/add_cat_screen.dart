import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 12: Add your first cat.
///
/// Avatar preset, Name, Date of birth, Breed (TheCatAPI, bawaan Domestic), Gender, Neuter status, Color (dari daftar), Medical history. Validasi: nama, tanggal lahir, breed, gender, neuter status wajib.
///
/// TODO(Orang 2): implementasikan UI dan logika layar ini.
class AddCatScreen extends ConsumerWidget {
  const AddCatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Add your first cat',
      screenNumber: 12,
      featureName: 'Cats & Home',
      owner: 'Orang 2',
      description:
          'Avatar preset, Name, Date of birth, Breed (TheCatAPI, bawaan Domestic), Gender, Neuter status, Color (dari daftar), Medical history. Validasi: nama, tanggal lahir, breed, gender, neuter status wajib.',
    );
  }
}
