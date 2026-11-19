import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/screens/create_password_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/setup_profile_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/signup_screen.dart';

void main() {
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  group('SignupScreen', () {
    Widget app() {
      final router = GoRouter(
        initialLocation: AppRoutes.signup.path,
        routes: [
          GoRoute(
            path: AppRoutes.signup.path,
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: AppRoutes.createPassword.path,
            builder: (context, state) =>
                const Scaffold(body: Text('halaman create password')),
          ),
        ],
      );
      return ProviderScope(child: MaterialApp.router(routerConfig: router));
    }

    testWidgets('email tidak valid menampilkan pesan validasi', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(app());

      await tester.enterText(find.byType(TextFormField), 'bukan-email');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('email valid disimpan ke draft lalu lanjut', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(app());

      await tester.enterText(find.byType(TextFormField), ' anya@mail.com ');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('halaman create password'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.text('halaman create password')),
      );
      expect(container.read(signUpEmailProvider), 'anya@mail.com');
    });
  });

  group('CreatePasswordScreen', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CreatePasswordScreen())),
      );
    }

    testWidgets('password kurang dari 6 karakter ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField).first, '123');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('konfirmasi yang tidak sama ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.enterText(find.byType(TextFormField).last, '654321');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Konfirmasi password tidak sama'), findsOneWidget);
    });
  });

  group('SetupProfileScreen', () {
    testWidgets('nama dan tanggal lahir wajib diisi', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SetupProfileScreen())),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Nama wajib diisi'), findsOneWidget);
      expect(find.text('Tanggal lahir wajib diisi'), findsOneWidget);
    });
  });
}
