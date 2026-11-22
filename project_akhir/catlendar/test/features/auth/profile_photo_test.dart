import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/media/image_picker_service.dart';
import 'package:catlendar/core/media/image_uploader.dart';
import 'package:catlendar/core/providers/media_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_photo_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/profile_photo_picker.dart';
import 'package:catlendar/shared/widgets/avatar_image.dart';

class _FakePicker implements ImagePickerService {
  PickedImage? result;
  Object? error;

  @override
  Future<PickedImage?> pickFromGallery() async {
    final failure = error;
    if (failure != null) throw failure;
    return result;
  }
}

class _FakeUploader implements ImageUploader {
  int calls = 0;
  String url = 'https://res.cloudinary.com/demo/image/upload/foto.jpg';
  Object? error;

  @override
  Future<String> upload({
    required Uint8List bytes,
    required String filename,
  }) async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return url;
  }
}

void main() {
  final bytes = Uint8List.fromList([1, 2, 3]);

  group('CloudinaryImageUploader', () {
    test('mengirim upload_preset ke cloud yang benar dan mengembalikan secure_url', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'secure_url': 'https://res.cloudinary.com/demo/image/upload/abc.jpg',
          }),
          200,
        );
      });
      final uploader = CloudinaryImageUploader(
        cloudName: 'demo',
        uploadPreset: 'preset-x',
        client: client,
      );

      final url = await uploader.upload(bytes: bytes, filename: 'foto.jpg');

      expect(url, 'https://res.cloudinary.com/demo/image/upload/abc.jpg');
      expect(captured.method, 'POST');
      expect(
        captured.url.toString(),
        'https://api.cloudinary.com/v1_1/demo/image/upload',
      );
      final body = utf8.decode(captured.bodyBytes, allowMalformed: true);
      expect(body, contains('upload_preset'));
      expect(body, contains('preset-x'));
      expect(body, contains('foto.jpg'));
    });

    test('respons error Cloudinary dilaporkan dengan pesannya', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'error': {'message': 'Upload preset not found'},
          }),
          400,
        ),
      );
      final uploader = CloudinaryImageUploader(
        cloudName: 'demo',
        uploadPreset: 'salah',
        client: client,
      );

      expect(
        () => uploader.upload(bytes: bytes, filename: 'foto.jpg'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Upload preset not found'),
          ),
        ),
      );
    });

    test('respons sukses tanpa secure_url ditolak', () async {
      final client = MockClient((request) async => http.Response('{}', 200));
      final uploader = CloudinaryImageUploader(
        cloudName: 'demo',
        uploadPreset: 'p',
        client: client,
      );

      expect(
        () => uploader.upload(bytes: bytes, filename: 'foto.jpg'),
        throwsA(isA<AppException>()),
      );
    });

    test('konfigurasi kosong ditolak tanpa mengirim permintaan', () async {
      var requests = 0;
      final client = MockClient((request) async {
        requests++;
        return http.Response('{}', 200);
      });
      final uploader = CloudinaryImageUploader(
        cloudName: '',
        uploadPreset: '',
        client: client,
      );

      await expectLater(
        uploader.upload(bytes: bytes, filename: 'foto.jpg'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            'cloudinary-not-configured',
          ),
        ),
      );
      expect(requests, 0);
    });

    test('gangguan jaringan dilaporkan sebagai error jaringan', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('offline'),
      );
      final uploader = CloudinaryImageUploader(
        cloudName: 'demo',
        uploadPreset: 'p',
        client: client,
      );

      expect(
        () => uploader.upload(bytes: bytes, filename: 'foto.jpg'),
        throwsA(
          isA<AppException>().having(
            (e) => e.type,
            'type',
            AppErrorType.network,
          ),
        ),
      );
    });
  });

  group('ProfilePhotoController', () {
    late _FakePicker picker;
    late _FakeUploader uploader;
    late ProviderContainer container;

    setUp(() {
      picker = _FakePicker()
        ..result = PickedImage(bytes: bytes, name: 'foto.jpg');
      uploader = _FakeUploader();
      container = ProviderContainer(
        overrides: [
          imagePickerServiceProvider.overrideWithValue(picker),
          imageUploaderProvider.overrideWithValue(uploader),
        ],
      );
      addTearDown(container.dispose);
    });

    ProfilePhotoController controller() =>
        container.read(profilePhotoControllerProvider.notifier);

    test('memilih lalu mengunggah mengembalikan URL', () async {
      final url = await controller().pickAndUpload();

      expect(url, uploader.url);
      expect(uploader.calls, 1);
      expect(container.read(profilePhotoControllerProvider).hasError, isFalse);
    });

    test('pemilihan dibatalkan: null tanpa error dan tanpa unggahan', () async {
      picker.result = null;

      final url = await controller().pickAndUpload();

      expect(url, isNull);
      expect(uploader.calls, 0);
      expect(container.read(profilePhotoControllerProvider).hasError, isFalse);
    });

    test('gagal memilih gambar: null dengan error', () async {
      picker.error = StateError('galeri tidak tersedia');

      final url = await controller().pickAndUpload();

      expect(url, isNull);
      expect(container.read(profilePhotoControllerProvider).hasError, isTrue);
    });

    test('gagal mengunggah: null dengan error', () async {
      uploader.error = const AppException('Gagal mengunggah foto.');

      final url = await controller().pickAndUpload();

      expect(url, isNull);
      expect(container.read(profilePhotoControllerProvider).hasError, isTrue);
    });
  });

  group('AvatarImage', () {
    test('membedakan URL foto dari id avatar preset', () {
      expect(AvatarImage.isPhotoUrl('https://res.cloudinary.com/a.jpg'), isTrue);
      expect(AvatarImage.isPhotoUrl('http://contoh.com/a.jpg'), isTrue);
      expect(AvatarImage.isPhotoUrl('owner_1'), isFalse);
      expect(AvatarImage.isPhotoUrl(''), isFalse);
      expect(AvatarImage.isPhotoUrl(null), isFalse);
    });
  });

  group('ProfilePhotoPicker', () {
    Widget app({
      required VoidCallback onGallery,
      required ValueChanged<String> onPreset,
      bool isUploading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProfilePhotoPicker(
              avatarId: null,
              isUploading: isUploading,
              onChooseFromGallery: onGallery,
              onChoosePreset: onPreset,
            ),
          ),
        ),
      );
    }

    testWidgets('tautan membuka pilihan dan memicu galeri', (tester) async {
      var galleryCalls = 0;
      await tester.pumpWidget(
        app(onGallery: () => galleryCalls++, onPreset: (_) {}),
      );

      await tester.tap(find.text('Edit profile picture'));
      await tester.pumpAndSettle();
      expect(find.text('Choose from gallery'), findsOneWidget);
      expect(find.text('Choose a preset avatar'), findsOneWidget);

      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(galleryCalls, 1);
    });

    testWidgets('memilih avatar preset memanggil callback dengan id-nya', (
      tester,
    ) async {
      String? chosen;
      await tester.pumpWidget(
        app(onGallery: () {}, onPreset: (id) => chosen = id),
      );

      await tester.tap(find.text('Edit profile picture'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a preset avatar'));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(InkResponse),
            )
            .first,
      );
      await tester.pumpAndSettle();

      expect(chosen, 'owner_1');
    });

    testWidgets('saat mengunggah: indikator tampil dan tautan nonaktif', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(onGallery: () {}, onPreset: (_) {}, isUploading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Edit profile picture'));
      await tester.pump();
      expect(find.text('Choose from gallery'), findsNothing);
    });
  });
}
