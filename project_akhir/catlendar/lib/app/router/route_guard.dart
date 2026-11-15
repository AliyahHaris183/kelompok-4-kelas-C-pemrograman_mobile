import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';

/// Rute yang boleh dibuka tanpa login.
final Set<String> _publicPaths = {
  AppRoutes.hello.path,
  AppRoutes.welcome.path,
  AppRoutes.login.path,
  AppRoutes.forgotPassword.path,
  AppRoutes.signup.path,
  AppRoutes.createPassword.path,
};

/// Rute onboarding (sudah login dan terverifikasi, profil belum dibuat).
final Set<String> _onboardingPaths = {
  AppRoutes.setupProfile.path,
  AppRoutes.dateOfBirth.path,
  AppRoutes.profileSummary.path,
};

/// Menentukan ke mana pengguna harus diarahkan.
///
/// Mengembalikan null jika [location] boleh dibuka, atau lokasi pengganti.
/// Fungsi murni (tanpa Firebase/Riverpod) agar mudah diuji. Aturan ini
/// dipanggil router setiap navigasi dan setiap status sesi berubah.
///
/// Aturan tidak boleh saling melempar (A -> B -> A), karena akan menyebabkan
/// redirect loop. Tiap tujuan di bawah selalu lolos pada pemeriksaan berikutnya.
String? resolveRedirect({
  required SessionStatus status,
  required String location,
}) {
  // TODO(tim): hapus bersama Dev Menu setelah semua layar selesai.
  if (location == AppRoutes.devMenu.path) return null;

  final isPublic = _publicPaths.contains(location);
  final isVerification = location == AppRoutes.emailVerification.path;
  final isOnboarding = _onboardingPaths.contains(location);

  switch (status) {
    case SessionStatus.loading:
      // Belum tahu status. Biarkan di layar sekarang (awalnya Hello).
      return null;

    case SessionStatus.signedOut:
    case SessionStatus.error:
      return isPublic ? null : AppRoutes.welcome.path;

    case SessionStatus.needsVerification:
      return isVerification ? null : AppRoutes.emailVerification.path;

    case SessionStatus.needsProfile:
      return isOnboarding ? null : AppRoutes.setupProfile.path;

    case SessionStatus.ready:
      // Selesai onboarding: lanjut ke Add your first cat (milik Orang 2).
      if (isOnboarding) return AppRoutes.addCat.path;
      // Sudah login: tidak perlu lagi melihat layar masuk.
      if (isPublic || isVerification) return AppRoutes.greeting.path;
      return null;
  }
}
