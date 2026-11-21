import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/screens/change_password_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/edit_owner_profile_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/settings_screen.dart';

void main() {
  final user = AppUser(
    userId: 'uid-1',
    email: 'anya@mail.com',
    emailVerified: true,
    name: 'Anya',
    dateOfBirth: DateTime(2001, 5, 17),
    gender: 'Female',
    avatarId: 'owner_2',
    onboardingDone: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpWithUser(WidgetTester tester, Widget screen) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    // Stream.value mengirim data pada microtask berikutnya.
    await tester.pump();
    await tester.pump();
  }

  group('SettingsScreen', () {
    testWidgets('menampilkan profil dan semua menu', (tester) async {
      await pumpWithUser(tester, const SettingsScreen());

      expect(find.text('Anya'), findsOneWidget);
      expect(find.text('anya@mail.com'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('Log out meminta konfirmasi dan dapat dibatalkan', (
      tester,
    ) async {
      await pumpWithUser(tester, const SettingsScreen());

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Yakin ingin keluar dari akun?'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Yakin ingin keluar dari akun?'), findsNothing);
      // Masih di Settings, tidak ada sign out.
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('EditOwnerProfileScreen', () {
    testWidgets('form terisi dengan data profil saat ini', (tester) async {
      await pumpWithUser(tester, const EditOwnerProfileScreen());

      expect(find.text('Anya'), findsOneWidget);
      expect(find.text('17 Mei 2001'), findsOneWidget);
    });

    testWidgets('nama yang dikosongkan ditolak', (tester) async {
      await pumpWithUser(tester, const EditOwnerProfileScreen());

      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Nama wajib diisi'), findsOneWidget);
      // Validasi gagal: dialog ringkasan tidak muncul.
      expect(find.text('Save changes?'), findsNothing);
    });

    testWidgets('data valid menampilkan ringkasan sebelum simpan', (
      tester,
    ) async {
      await pumpWithUser(tester, const EditOwnerProfileScreen());

      await tester.enterText(find.byType(TextFormField).first, 'Anya Putri');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Save changes?'), findsOneWidget);
      expect(find.textContaining('Name: Anya Putri'), findsOneWidget);

      // Batalkan: tidak ada penulisan ke Firestore.
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Save changes?'), findsNothing);
    });
  });

  group('ChangePasswordScreen', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChangePasswordScreen())),
      );
    }

    Finder field(int index) => find.byType(TextFormField).at(index);

    testWidgets('form kosong menampilkan pesan validasi', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Password lama wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(find.text('Konfirmasi password wajib diisi'), findsOneWidget);
    });

    testWidgets('password baru kurang dari 6 karakter ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(field(0), 'lama123');
      await tester.enterText(field(1), '123');
      await tester.enterText(field(2), '123');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('password baru tidak boleh sama dengan yang lama', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.enterText(field(0), 'sama1234');
      await tester.enterText(field(1), 'sama1234');
      await tester.enterText(field(2), 'sama1234');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(
        find.text('Password baru harus berbeda dari password lama'),
        findsOneWidget,
      );
    });

    testWidgets('konfirmasi yang tidak sama ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(field(0), 'lama123');
      await tester.enterText(field(1), 'baru1234');
      await tester.enterText(field(2), 'baru4321');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Konfirmasi password tidak sama'), findsOneWidget);
    });
  });
}
