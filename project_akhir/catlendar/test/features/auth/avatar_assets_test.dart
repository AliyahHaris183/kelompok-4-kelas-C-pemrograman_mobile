import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/shared/widgets/avatar_image.dart';
import 'package:catlendar/shared/widgets/owner_avatar.dart';

void main() {
  group('AppAssets', () {
    test('kelima gambar kucing berformat png di assets/images', () {
  final cats = [
    AppAssets.catLogin,
    AppAssets.catSignup,
    AppAssets.catSetupSettings,
    AppAssets.catWelcome,
    AppAssets.catGoodToSeeYouBack,
  ];

  for (final path in cats) {
    expect(path, startsWith('assets/images/'), reason: path);
    expect(path, endsWith('.png'), reason: path);
  }

  expect(cats.toSet().length, 5, reason: 'tiap kucing punya file sendiri');
});

    test('avatar(id) menunjuk ke folder avatars', () {
      expect(AppAssets.avatar('owner_3'), 'assets/images/avatars/owner_3.png');
    });
  });

  group('AuthMascot', () {
    testWidgets('file .png dirender dengan Image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AuthMascot(assetPath: AppAssets.catLogin)),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('file .png dirender dengan Image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthMascot(assetPath: AppAssets.avatar('owner_1')),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('OwnerAvatar', () {
    test('mendukung owner_1 sampai owner_8 saja', () {
      for (var i = 1; i <= 8; i++) {
        expect(OwnerAvatar.supports('owner_$i'), isTrue, reason: 'owner_$i');
      }
      expect(OwnerAvatar.supports('owner_9'), isFalse);
      expect(OwnerAvatar.supports('cat_1'), isFalse);
      expect(OwnerAvatar.supports(''), isFalse);
    });

    testWidgets('kedelapan avatar dapat digambar tanpa error', (tester) async {
      for (var i = 1; i <= 8; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: OwnerAvatar(avatarId: 'owner_$i'),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: 'owner_$i');
      }
    });
  });

  group('AvatarImage', () {
    testWidgets('id owner digambar lewat kode, tanpa file gambar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AvatarImage(avatarId: 'owner_1')),
        ),
      );

      expect(find.byType(OwnerAvatar), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('id non-owner memakai gambar dari folder avatars', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AvatarImage(avatarId: 'cat_1')),
        ),
      );

      final assetImage = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.avatar('cat_1'),
      );
      expect(assetImage, findsOneWidget);
      expect(find.byType(OwnerAvatar), findsNothing);
    });

    testWidgets('tanpa avatar menampilkan ikon orang', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AvatarImage(avatarId: null)),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
