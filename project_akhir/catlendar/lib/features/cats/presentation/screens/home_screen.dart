import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/placeholder_screen.dart';

/// Layar 14: Home.
///
/// Sapaan nama dan umur, gender. Carousel avatar kucing. Tombol Add. Settings. Kartu pengingat cek kalender. Membaca USERS dan CATS milik pengguna.
///
/// TODO(Orang 2): implementasikan UI dan logika layar ini.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlaceholderScreen(
      screenName: 'Home',
      screenNumber: 14,
      featureName: 'Cats & Home',
      owner: 'Orang 2',
      description:
          'Sapaan nama dan umur, gender. Carousel avatar kucing. Tombol Add. Settings. Kartu pengingat cek kalender. Membaca USERS dan CATS milik pengguna.',
    );
  }
}
