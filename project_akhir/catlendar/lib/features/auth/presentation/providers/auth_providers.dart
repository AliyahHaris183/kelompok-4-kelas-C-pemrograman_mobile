import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/providers/firebase_providers.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/features/auth/data/datasources/user_firestore_data_source.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:catlendar/features/auth/data/repositories/user_repository_impl.dart';
import 'package:catlendar/features/auth/domain/repositories/auth_repository.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';

final userDataSourceProvider = Provider<UserFirestoreDataSource>(
  (ref) => UserFirestoreDataSource(ref.watch(firebaseFirestoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(firebaseAuthProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.watch(userDataSourceProvider)),
);

/// Profil pemilik yang sedang login (dokumen USERS/{uid}).
/// Akan menghasilkan error sampai UserRepositoryImpl.watchUser diimplementasikan.
final currentUserProfileProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(uid);
});
