import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/dev_menu_screen.dart';
import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/app/router/route_guard.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';
import 'package:catlendar/features/auth/presentation/screens/change_password_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/create_password_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/date_of_birth_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/edit_owner_profile_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/greeting_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/hello_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/login_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/profile_summary_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/settings_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/setup_profile_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/signup_screen.dart';
import 'package:catlendar/features/auth/presentation/screens/welcome_screen.dart';
import 'package:catlendar/features/care/presentation/screens/calendar_screen.dart';
import 'package:catlendar/features/care/presentation/screens/grooming_history_screen.dart';
import 'package:catlendar/features/care/presentation/screens/schedule_setup_screen.dart';
import 'package:catlendar/features/care/presentation/screens/summary_screen.dart';
import 'package:catlendar/features/cats/presentation/screens/add_cat_screen.dart';
import 'package:catlendar/features/cats/presentation/screens/cat_profile_screen.dart';
import 'package:catlendar/features/cats/presentation/screens/cat_summary_screen.dart';
import 'package:catlendar/features/cats/presentation/screens/edit_cat_screen.dart';
import 'package:catlendar/features/cats/presentation/screens/home_screen.dart';

/// Satu-satunya konfigurasi routing aplikasi. Fitur TIDAK boleh membuat router
/// sendiri; tambahkan rute baru di app_routes.dart lalu di sini.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.initialLocation,
    // TODO(tim): set true untuk melihat log navigasi saat debugging.
    debugLogDiagnostics: false,
    // Aturan akses ada di route_guard.dart.
    redirect: (context, state) => resolveRedirect(
      status: ref.read(sessionStatusProvider),
      location: state.matchedLocation,
    ),
    routes: [
      _route(AppRoutes.devMenu, (context, state) => const DevMenuScreen()),

      // ---- Auth & Settings (Orang 1) ----
      _route(AppRoutes.hello, (context, state) => const HelloScreen()),
      _route(AppRoutes.welcome, (context, state) => const WelcomeScreen()),
      _route(AppRoutes.login, (context, state) => const LoginScreen()),
      _route(
        AppRoutes.forgotPassword,
        (context, state) => const ForgotPasswordScreen(),
      ),
      _route(AppRoutes.signup, (context, state) => const SignupScreen()),
      _route(
        AppRoutes.createPassword,
        (context, state) => const CreatePasswordScreen(),
      ),
      _route(
        AppRoutes.emailVerification,
        (context, state) => const EmailVerificationScreen(),
      ),
      _route(AppRoutes.greeting, (context, state) => const GreetingScreen()),
      _route(
        AppRoutes.setupProfile,
        (context, state) => const SetupProfileScreen(),
      ),
      _route(
        AppRoutes.dateOfBirth,
        (context, state) => const DateOfBirthScreen(),
      ),
      _route(
        AppRoutes.profileSummary,
        (context, state) => const ProfileSummaryScreen(),
      ),
      _route(AppRoutes.settings, (context, state) => const SettingsScreen()),
      _route(
        AppRoutes.editOwnerProfile,
        (context, state) => const EditOwnerProfileScreen(),
      ),
      _route(
        AppRoutes.changePassword,
        (context, state) => const ChangePasswordScreen(),
      ),

      // ---- Cats & Home (Orang 2) ----
      // Urutan penting: /cats/add dan /cats/summary harus sebelum /cats/:catId.
      _route(AppRoutes.home, (context, state) => const HomeScreen()),
      _route(AppRoutes.addCat, (context, state) => const AddCatScreen()),
      _route(
        AppRoutes.catSummary,
        (context, state) => const CatSummaryScreen(),
      ),
      _route(
        AppRoutes.catProfile,
        (context, state) => CatProfileScreen(
          catId: state.pathParameters[AppRoutes.catIdParam]!,
        ),
      ),
      _route(
        AppRoutes.editCat,
        (context, state) => EditCatScreen(
          catId: state.pathParameters[AppRoutes.catIdParam]!,
        ),
      ),

      // ---- Care (Orang 3) ----
      _route(
        AppRoutes.groomingHistory,
        (context, state) => GroomingHistoryScreen(
          catId: state.pathParameters[AppRoutes.catIdParam]!,
        ),
      ),
      _route(
        AppRoutes.scheduleSetup,
        (context, state) => ScheduleSetupScreen(
          catId: state.pathParameters[AppRoutes.catIdParam]!,
        ),
      ),
      _route(
        AppRoutes.calendar,
        (context, state) => CalendarScreen(
          catId: state.uri.queryParameters[AppRoutes.catIdQuery],
        ),
      ),
      _route(
        AppRoutes.summary,
        (context, state) => SummaryScreen(
          catId: state.uri.queryParameters[AppRoutes.catIdQuery],
        ),
      ),
    ],
  );

  // Evaluasi ulang aturan akses setiap status sesi berubah: login, logout,
  // email terverifikasi, atau profil selesai dibuat.
  ref.listen<SessionStatus>(
    sessionStatusProvider,
    (previous, next) => router.refresh(),
  );
  ref.onDispose(router.dispose);

  return router;
});

GoRoute _route(
  AppRoute route,
  Widget Function(BuildContext context, GoRouterState state) builder,
) {
  return GoRoute(path: route.path, name: route.name, builder: builder);
}
