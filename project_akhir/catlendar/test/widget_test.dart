import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/app/catlendar_app.dart';
import 'package:catlendar/core/firebase/firebase_initializer.dart';
import 'package:catlendar/core/providers/firebase_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';

void main() {
  testWidgets('belum login: Hello, lalu Welcome, lalu Log in', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseInitResultProvider.overrideWithValue(
            const FirebaseInitResult.success(),
          ),
          // Status sesi diatur langsung agar test tidak membutuhkan Firebase.
          sessionStatusProvider.overrideWithValue(SessionStatus.signedOut),
        ],
        child: const CatlendarApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Hello.'), findsOneWidget);

    // Hello otomatis lanjut ke Welcome (1,5 detik).
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Welcome to'), findsOneWidget);

    // Welcome otomatis lanjut ke Log in (2 detik).
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
    expect(find.text('Log in to your account'), findsOneWidget);
  });
}
