import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/core/notifications/fcm_service.dart';
import 'package:catlendar/core/providers/notification_providers.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/domain/repositories/auth_repository.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';

class _FakeUser implements User {
  @override
  String get uid => 'uid-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.events, {this.signOutFails = false});

  final List<String> events;
  final bool signOutFails;

  @override
  User? get currentUser => _FakeUser();

  @override
  Future<void> signOut() async {
    events.add('signOut');
    if (signOutFails) throw StateError('sign out gagal');
  }

  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<bool> reloadAndCheckEmailVerified() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError();
}

class _FakeUsers implements UserRepository {
  _FakeUsers(this.events, {this.updateFails = false});

  final List<String> events;
  final bool updateFails;

  @override
  Future<void> updateFcmToken({
    required String userId,
    required String? token,
  }) async {
    events.add('updateFcmToken:$userId:$token');
    if (updateFails) throw StateError('offline');
  }

  @override
  Future<AppUser?> getUser(String userId) => throw UnimplementedError();

  @override
  Stream<AppUser?> watchUser(String userId) => throw UnimplementedError();

  @override
  Future<void> createUser(AppUser user) => throw UnimplementedError();

  @override
  Future<void> updateUser(AppUser user) => throw UnimplementedError();
}

class _FakeFcm implements FcmService {
  _FakeFcm(this.events);

  final List<String> events;

  @override
  Future<void> deleteToken() async => events.add('deleteToken');

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> getToken() async => 'token';

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}

void main() {
  ProviderContainer makeContainer(
    List<String> events, {
    bool updateFails = false,
    bool signOutFails = false,
  }) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(events, signOutFails: signOutFails),
        ),
        userRepositoryProvider.overrideWithValue(
          _FakeUsers(events, updateFails: updateFails),
        ),
        fcmServiceProvider.overrideWithValue(_FakeFcm(events)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('logout menghapus token di USERS dan perangkat SEBELUM signOut', () async {
    final events = <String>[];
    final container = makeContainer(events);

    final ok = await container.read(authControllerProvider.notifier).logout();

    expect(ok, isTrue);
    expect(events, ['updateFcmToken:uid-1:null', 'deleteToken', 'signOut']);
  });

  test('gagal menghapus token tidak menghalangi logout', () async {
    final events = <String>[];
    final container = makeContainer(events, updateFails: true);

    final ok = await container.read(authControllerProvider.notifier).logout();

    expect(ok, isTrue);
    expect(events.last, 'signOut');
    expect(events, contains('updateFcmToken:uid-1:null'));
  });

  test('signOut yang gagal dilaporkan sebagai gagal', () async {
    final events = <String>[];
    final container = makeContainer(events, signOutFails: true);

    final ok = await container.read(authControllerProvider.notifier).logout();

    expect(ok, isFalse);
    expect(container.read(authControllerProvider).hasError, isTrue);
  });
}
