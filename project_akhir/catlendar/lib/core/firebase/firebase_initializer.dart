import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:catlendar/firebase_options.dart';

/// Hasil inisialisasi Firebase. Dibaca lewat [firebaseInitResultProvider].
class FirebaseInitResult {
  const FirebaseInitResult.success()
      : isInitialized = true,
        errorMessage = null;

  const FirebaseInitResult.failure(this.errorMessage) : isInitialized = false;

  final bool isInitialized;
  final String? errorMessage;
}

/// Satu-satunya tempat Firebase diinisialisasi. Fitur TIDAK boleh memanggil
/// Firebase.initializeApp sendiri.
class FirebaseInitializer {
  const FirebaseInitializer._();

  static Future<FirebaseInitResult> initialize() async {
    try {
      // Memakai konfigurasi native (google-services.json / GoogleService-Info.plist).
      //
      // TODO(setup): jika tim memakai `flutterfire configure`, file
      // lib/firebase_options.dart akan dibuat. Setelah itu ganti baris di bawah:
      //
      //   import 'package:catlendar/firebase_options.dart';
      //   await Firebase.initializeApp(
      //     options: DefaultFirebaseOptions.currentPlatform,
      //   );
      //
      // Jangan membuat firebase_options.dart secara manual atau memakai API key
      // fiktif. Lihat docs/firebase_setup.md.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return const FirebaseInitResult.success();
    } catch (error, stackTrace) {
      debugPrint('Inisialisasi Firebase gagal: $error');
      debugPrintStack(stackTrace: stackTrace);
      return FirebaseInitResult.failure(error.toString());
    }
  }
}
