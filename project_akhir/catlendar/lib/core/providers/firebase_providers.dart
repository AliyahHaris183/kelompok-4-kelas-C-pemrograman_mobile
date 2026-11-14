import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/firebase/firebase_initializer.dart';

/// Hasil inisialisasi Firebase. Di-override di bootstrap().
final firebaseInitResultProvider = Provider<FirebaseInitResult>(
  (ref) => throw UnimplementedError(
    'firebaseInitResultProvider harus di-override di ProviderScope (bootstrap.dart).',
  ),
);

/// Instance Firebase bersama. Semua repository wajib memakai provider ini,
/// bukan FirebaseAuth.instance / FirebaseFirestore.instance secara langsung.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);
