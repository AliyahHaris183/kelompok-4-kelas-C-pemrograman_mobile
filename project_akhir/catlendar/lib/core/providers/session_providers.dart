import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/providers/firebase_providers.dart';

/// Stream status login. Dipakai router (redirect) dan semua fitur.
final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

/// UID pengguna yang sedang login, atau null jika belum login.
/// Dipakai sebagai owner_id pada query CATS, MEDICAL_HISTORY, CARE_RECORD, SCHEDULE.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateChangesProvider).valueOrNull?.uid,
);
