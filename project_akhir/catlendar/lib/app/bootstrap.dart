import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/app/catlendar_app.dart';
import 'package:catlendar/core/firebase/firebase_initializer.dart';
import 'package:catlendar/core/providers/firebase_providers.dart';

/// Inisialisasi aplikasi secara terstruktur. Tidak ada logika fitur di sini.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseResult = await FirebaseInitializer.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseInitResultProvider.overrideWithValue(firebaseResult),
      ],
      child: const CatlendarApp(),
    ),
  );
}
