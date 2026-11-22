/// Path aset gambar. Satu-satunya tempat nama file ditulis.
///
/// File ada di folder assets/images/ (sejajar dengan lib/) dan harus terdaftar
/// di pubspec.yaml. Lihat docs/aset_gambar.md.
abstract final class AppAssets {
  static const String _images = 'assets/images';
  static const String _avatars = '$_images/avatars';

  /// Kucing layar Log in.
  static const String catLogin = '$_images/cat_login.png';

  /// Kucing layar Sign up. Juga dipakai di Create password, Forgot password,
  /// dan Verifikasi email.
  static const String catSignup = '$_images/cat_signup.png';

  /// Kucing layar Set up profile dan Settings. Juga dipakai di Edit profile
  /// dan Change password.
  static const String catSetupSettings = '$_images/cat_setup_settings.png';

  /// Kucing layar Welcome to Catlendar.
  static const String catWelcome = '$_images/cat_welcome.png';

  /// Kucing layar Greeting (Good to see you back).
  static const String catGoodToSeeYouBack =
      '$_images/cat_good_to_see_you_back.png';

  /// Gambar avatar preset untuk sebuah avatar_id (mis. owner_1).
  /// File: assets/images/avatars/avatar_id.png
  static String avatar(String avatarId) => '$_avatars/$avatarId.png';

  /// Kucing layar Home (bagian daftar kucing).
  static const String catHomeMembers = '$_images/cat_home_members.png';

  /// Kucing layar Home (bagian pengingat kalender).
  static const String catHomeCalendar = '$_images/cat_home_calendar.png';
}
