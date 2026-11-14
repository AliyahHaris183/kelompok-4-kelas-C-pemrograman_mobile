import 'package:catlendar/features/auth/data/datasources/user_firestore_data_source.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';

/// Scaffold. Belum terhubung ke Firestore. Semua TODO Orang 1.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.dataSource);

  final UserFirestoreDataSource dataSource;

  // TODO(Orang 1): dataSource.doc(userId).get() -> AppUser.fromFirestore.
  @override
  Future<AppUser?> getUser(String userId) =>
      throw UnimplementedError('TODO(Orang 1): getUser');

  // TODO(Orang 1): dataSource.doc(userId).snapshots() -> AppUser.fromFirestore.
  @override
  Stream<AppUser?> watchUser(String userId) =>
      throw UnimplementedError('TODO(Orang 1): watchUser');

  // TODO(Orang 1): set dokumen dengan id = user.userId, data user.toFirestore().
  @override
  Future<void> createUser(AppUser user) =>
      throw UnimplementedError('TODO(Orang 1): createUser');

  // TODO(Orang 1): update dengan updated_at baru.
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
