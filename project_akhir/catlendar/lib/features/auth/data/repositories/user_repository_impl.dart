import 'package:catlendar/features/auth/data/datasources/user_firestore_data_source.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';

/// Repository USERS. Milik Orang 1.
/// getUser, watchUser, dan createUser sudah berfungsi.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.dataSource);

  final UserFirestoreDataSource dataSource;

  /// Mengembalikan null jika dokumen USERS/{userId} belum ada
  /// (pengguna belum menyelesaikan onboarding).
  @override
  Future<AppUser?> getUser(String userId) async {
    final snapshot = await dataSource.doc(userId).get();
    if (!snapshot.exists) return null;
    return AppUser.fromFirestore(snapshot);
  }

  @override
  Stream<AppUser?> watchUser(String userId) {
    return dataSource.doc(userId).snapshots().map<AppUser?>(
          (snapshot) =>
              snapshot.exists ? AppUser.fromFirestore(snapshot) : null,
        );
  }

  /// ID dokumen = user.userId = UID Firebase Auth (wajib, diperiksa Security Rules).
  @override
  Future<void> createUser(AppUser user) {
    return dataSource.doc(user.userId).set(user.toFirestore());
  }

  // TODO(Orang 1): update dengan updated_at baru (edit profil pemilik, layar 22).
  @override
  Future<void> updateUser(AppUser user) =>
      throw UnimplementedError('TODO(Orang 1): updateUser');

  // TODO(Orang 1): update hanya field fcm_token (+ updated_at).
  @override
  Future<void> updateFcmToken({
    required String userId,
    required String? token,
  }) =>
      throw UnimplementedError('TODO(Orang 1): updateFcmToken');
}
