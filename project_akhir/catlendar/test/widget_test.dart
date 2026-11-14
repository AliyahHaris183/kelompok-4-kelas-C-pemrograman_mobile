import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/app/catlendar_app.dart';
import 'package:catlendar/core/firebase/firebase_initializer.dart';
import 'package:catlendar/core/providers/firebase_providers.dart';

void main() {
  testWidgets('aplikasi menampilkan dev menu dan dapat membuka placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseInitResultProvider.overrideWithValue(
            const FirebaseInitResult.success(),
          ),
        ],
        child: const CatlendarApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catlendar Dev Menu'), findsOneWidget);

    await tester.tap(find.text('3. Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Log in to your account'), findsWidgets);
    expect(find.text('Penanggung jawab: Orang 1'), findsOneWidget);
  });
}
