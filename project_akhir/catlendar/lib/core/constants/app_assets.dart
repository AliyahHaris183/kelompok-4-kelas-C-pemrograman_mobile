/// Path aset gambar. Satu-satunya tempat nama file ditulis.
///
/// File gambarnya harus ada di folder assets/images/ (sejajar dengan lib/),
/// dan folder itu harus terdaftar di pubspec.yaml. Lihat docs/aset_gambar.md.
/// Jika file belum ada, aplikasi tetap jalan dan menampilkan ikon cadangan.
abstract final class AppAssets {
  static const String _images = 'assets/images';

  /// Kucing hitam, layar Log in.
  static const String catLogin = '$_images/cat_login.png';

  /// Kucing belang merah muda. Dipakai di Sign up, Create password, Forgot
  /// password, Verifikasi email, Settings, Edit profile, dan Change password.
  static const String catSignup = '$_images/cat_signup.png';

  /// Kucing tutul putih, layar Welcome.
  static const String catWelcome = '$_images/cat_welcome.png';
}
