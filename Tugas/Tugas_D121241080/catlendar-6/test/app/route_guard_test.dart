import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/app/router/route_guard.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';

void main() {
  final publicPaths = [
    AppRoutes.hello.path,
    AppRoutes.welcome.path,
    AppRoutes.login.path,
    AppRoutes.forgotPassword.path,
    AppRoutes.signup.path,
    AppRoutes.createPassword.path,
  ];
  final onboardingPaths = [
    AppRoutes.setupProfile.path,
    AppRoutes.dateOfBirth.path,
    AppRoutes.profileSummary.path,
  ];
  final protectedPaths = [
    AppRoutes.greeting.path,
    AppRoutes.home.path,
    AppRoutes.settings.path,
    AppRoutes.addCat.path,
    '/cats/abc123',
    '/cats/abc123/schedule',
    AppRoutes.calendar.path,
  ];
  final allPaths = [
    ...publicPaths,
    AppRoutes.emailVerification.path,
    ...onboardingPaths,
    ...protectedPaths,
  ];

  String? redirect(SessionStatus status, String location) =>
      resolveRedirect(status: status, location: location);

  group('loading', () {
    test('tidak mengarahkan ke mana pun', () {
      for (final path in allPaths) {
        expect(redirect(SessionStatus.loading, path), isNull, reason: path);
      }
    });
  });

  group('signedOut dan error (belum login)', () {
    for (final status in [SessionStatus.signedOut, SessionStatus.error]) {
      test('$status: rute publik boleh dibuka', () {
        for (final path in publicPaths) {
          expect(redirect(status, path), isNull, reason: path);
        }
      });

      test('$status: rute lain diarahkan ke Welcome', () {
        final others = [
          AppRoutes.emailVerification.path,
          ...onboardingPaths,
          ...protectedPaths,
        ];
        for (final path in others) {
          expect(redirect(status, path), AppRoutes.welcome.path, reason: path);
        }
      });
    }
  });

  group('needsVerification', () {
    test('hanya layar Verifikasi email yang boleh dibuka', () {
      expect(
        redirect(SessionStatus.needsVerification, AppRoutes.emailVerification.path),
        isNull,
      );
    });

    test('selain itu diarahkan ke Verifikasi email', () {
      final others = [...publicPaths, ...onboardingPaths, ...protectedPaths];
      for (final path in others) {
        expect(
          redirect(SessionStatus.needsVerification, path),
          AppRoutes.emailVerification.path,
          reason: path,
        );
      }
    });
  });

  group('needsProfile', () {
    test('layar onboarding boleh dibuka', () {
      for (final path in onboardingPaths) {
        expect(redirect(SessionStatus.needsProfile, path), isNull, reason: path);
      }
    });

    test('selain itu diarahkan ke Set up profile', () {
      final others = [
        ...publicPaths,
        AppRoutes.emailVerification.path,
        ...protectedPaths,
      ];
      for (final path in others) {
        expect(
          redirect(SessionStatus.needsProfile, path),
          AppRoutes.setupProfile.path,
          reason: path,
        );
      }
    });
  });

  group('ready', () {
    test('rute aplikasi boleh dibuka', () {
      for (final path in protectedPaths) {
        expect(redirect(SessionStatus.ready, path), isNull, reason: path);
      }
    });

    test('layar masuk dan verifikasi diarahkan ke Greeting', () {
      final others = [...publicPaths, AppRoutes.emailVerification.path];
      for (final path in others) {
        expect(
          redirect(SessionStatus.ready, path),
          AppRoutes.greeting.path,
          reason: path,
        );
      }
    });

    test('layar onboarding diarahkan ke Add your first cat', () {
      for (final path in onboardingPaths) {
        expect(
          redirect(SessionStatus.ready, path),
          AppRoutes.addCat.path,
          reason: path,
        );
      }
    });
  });

  group('Dev Menu', () {
    test('selalu boleh dibuka pada semua status', () {
      for (final status in SessionStatus.values) {
        expect(redirect(status, AppRoutes.devMenu.path), isNull);
      }
    });
  });

  group('tidak ada redirect loop', () {
    test('tujuan redirect selalu lolos pada pemeriksaan berikutnya', () {
      for (final status in SessionStatus.values) {
        for (final path in allPaths) {
          final first = redirect(status, path);
          if (first == null) continue;
          expect(
            redirect(status, first),
            isNull,
            reason: '$status: $path -> $first harus berhenti',
          );
        }
      }
    });
  });
}
