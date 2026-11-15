import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/auth/presentation/screens/login_screen.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester) {
    return tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
  }

  testWidgets('menampilkan elemen layar sesuai desain', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Log in to your account'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('form kosong menampilkan pesan validasi tanpa memanggil Firebase', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('format email salah menampilkan pesan validasi', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).first, 'bukan-email');
    await tester.enterText(find.byType(TextFormField).last, 'rahasia');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsNothing);
  });
}
