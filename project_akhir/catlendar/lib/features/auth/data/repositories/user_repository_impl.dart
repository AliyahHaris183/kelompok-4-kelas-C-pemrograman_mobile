import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';
import 'package:catlendar/features/auth/data/datasources/user_firestore_data_source.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';

/// Repository USERS. Milik Orang 1. Semua method sudah berfungsi.
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

  /// Memperbarui dokumen yang sudah ada dan mengisi updated_at dengan waktu
  /// sekarang. Gagal (not-found) jika dokumen belum ada, tidak membuat baru.
  @override
  Future<void> updateUser(AppUser user) {
    return dataSource.doc(user.userId).update({
      ...user.toFirestore(),
      FirestoreFields.updatedAt: dateTimeToTimestamp(DateTime.now()),
    });
  }

  /// Menyimpan token FCM (login) atau menghapusnya dengan null (log out).
  @override
  Future<void> updateFcmToken({
    required String userId,
    required String? token,
  }) {
    return dataSource.doc(userId).update({
      FirestoreFields.fcmToken: token,
      FirestoreFields.updatedAt: dateTimeToTimestamp(DateTime.now()),
    });
  }
}
