import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/core/notifications/fcm_service.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/domain/repositories/user_repository.dart';
import 'package:catlendar/features/auth/presentation/providers/fcm_token_sync.dart';

class _FakeFcm implements FcmService {
  String? token = 'token-1';
  bool granted = true;
  Object? error;
  Completer<String?>? tokenGate;
  int permissionCalls = 0;
  final refresh = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionCalls++;
    final failure = error;
    if (failure != null) throw failure;
    return granted;
  }

  @override
  Future<String?> getToken() {
    final gate = tokenGate;
    return gate != null ? gate.future : Future.value(token);
  }

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Future<void> deleteToken() async {}
}

class _FakeUsers implements UserRepository {
  final List<String> writes = [];

  @override
  Future<void> updateFcmToken({
    required String userId,
    required String? token,
  }) async {
    writes.add('$userId:$token');
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

void main() {
  late _FakeFcm fcm;
  late _FakeUsers users;
  late FcmTokenSync sync;

  setUp(() {
    fcm = _FakeFcm();
    users = _FakeUsers();
    sync = FcmTokenSync(fcm: fcm, users: users);
  });

  tearDown(() async {
    await sync.stop();
    await fcm.refresh.close();
  });

  test('start meminta izin lalu menyimpan token ke USERS', () async {
    await sync.start('uid-1');

    expect(fcm.permissionCalls, 1);
    expect(users.writes, ['uid-1:token-1']);
  });

  test('izin ditolak: token tetap disimpan', () async {
    fcm.granted = false;

    await sync.start('uid-1');

    expect(users.writes, ['uid-1:token-1']);
  });

  test('token null tidak ditulis', () async {
    fcm.token = null;

    await sync.start('uid-1');

    expect(users.writes, isEmpty);
  });

  test('token yang diperbarui FCM ikut disimpan', () async {
    await sync.start('uid-1');

    fcm.refresh.add('token-2');
    await pumpEventQueue();

    expect(users.writes, ['uid-1:token-1', 'uid-1:token-2']);
  });

  test('setelah stop, pembaruan token tidak lagi disimpan', () async {
    await sync.start('uid-1');
    await sync.stop();

    fcm.refresh.add('token-2');
    await pumpEventQueue();

    expect(users.writes, ['uid-1:token-1']);
  });

  test('kegagalan FCM tidak melempar error dan tidak menulis apa pun', () async {
    fcm.error = StateError('tanpa Google Play Services');

    await sync.start('uid-1');

    expect(users.writes, isEmpty);
  });

  test('stop di tengah start membatalkan penulisan token', () async {
    fcm.tokenGate = Completer<String?>();

    final starting = sync.start('uid-1');
    await pumpEventQueue();
    await sync.stop(); // pengguna langsung log out

    fcm.tokenGate!.complete('token-1');
    await starting;
    fcm.refresh.add('token-2');
    await pumpEventQueue();

    expect(users.writes, isEmpty);
  });
}
