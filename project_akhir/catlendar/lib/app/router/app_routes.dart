/// Satu rute: nama dan path. Semua rute aplikasi didefinisikan di sini dan
/// dipasang di app_router.dart.
///
/// Navigasi: context.push(AppRoutes.login.location()) atau
/// context.pushNamed(AppRoutes.login.name).
class AppRoute {
  const AppRoute(this.name, this.path);

  final String name;
  final String path;

  /// Membangun lokasi dari path dengan mengisi parameter path dan query.
  /// Contoh: AppRoutes.catProfile.location(pathParameters: {'catId': id}).
  /// Catatan: nilai tidak di-encode; ID Firestore otomatis aman dipakai.
  String location({
    Map<String, String> pathParameters = const {},
    Map<String, String>? queryParameters,
  }) {
    var result = path;
    pathParameters.forEach((key, value) {
      result = result.replaceFirst(':$key', value);
    });
    if (queryParameters != null && queryParameters.isNotEmpty) {
      result = Uri(path: result, queryParameters: queryParameters).toString();
    }
    return result;
  }
}

abstract final class AppRoutes {
  /// Kunci parameter.
  static const String catIdParam = 'catId';
  static const String catIdQuery = 'catId';

  /// Rute awal aplikasi: Hello. Redirect (route_guard.dart) lalu mengarahkan
  /// pengguna sesuai status login.
  /// Untuk memulai dari Dev Menu saat pengembangan, jalankan dengan
  /// DEV_MENU=true (lihat README).
  static const String initialLocation =
      bool.fromEnvironment('DEV_MENU') ? '/dev' : '/hello';
  static const AppRoute devMenu = AppRoute('dev-menu', '/dev');

  // ---- Auth & Settings (Orang 1) ----
  static const AppRoute hello = AppRoute('hello', '/hello');
  static const AppRoute welcome = AppRoute('welcome', '/welcome');
  static const AppRoute login = AppRoute('login', '/login');
  static const AppRoute forgotPassword =
      AppRoute('forgot-password', '/forgot-password');
  static const AppRoute signup = AppRoute('signup', '/signup');
  static const AppRoute createPassword =
      AppRoute('create-password', '/create-password');
  static const AppRoute emailVerification =
      AppRoute('email-verification', '/email-verification');
  static const AppRoute greeting = AppRoute('greeting', '/greeting');
  static const AppRoute setupProfile = AppRoute('setup-profile', '/setup-profile');
  static const AppRoute dateOfBirth = AppRoute('date-of-birth', '/date-of-birth');
  static const AppRoute profileSummary =
      AppRoute('profile-summary', '/profile-summary');
  static const AppRoute settings = AppRoute('settings', '/settings');
  static const AppRoute editOwnerProfile =
      AppRoute('edit-owner-profile', '/settings/edit-profile');
  static const AppRoute changePassword =
      AppRoute('change-password', '/settings/change-password');

  // ---- Cats & Home (Orang 2) ----
  static const AppRoute home = AppRoute('home', '/home');
  static const AppRoute addCat = AppRoute('add-cat', '/cats/add');
  static const AppRoute catSummary = AppRoute('cat-summary', '/cats/summary');
  static const AppRoute catProfile = AppRoute('cat-profile', '/cats/:catId');
  static const AppRoute editCat = AppRoute('edit-cat', '/cats/:catId/edit');

  // ---- Care (Orang 3) ----
  static const AppRoute groomingHistory =
      AppRoute('grooming-history', '/cats/:catId/grooming-history');
  static const AppRoute scheduleSetup =
      AppRoute('schedule-setup', '/cats/:catId/schedule');
  static const AppRoute calendar = AppRoute('calendar', '/calendar');
  static const AppRoute summary = AppRoute('summary', '/summary');
}
