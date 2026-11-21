/// Konstanta umum aplikasi.
abstract final class AppConstants {
  static const String appName = 'Catlendar';

  /// Nilai breed bawaan (keputusan 7.5 pada dokumen alur).
  static const String defaultBreed = 'Domestic';

  /// Validasi password minimal (layar Create password).
  static const int minPasswordLength = 6;

  /// TheCatAPI (pendukung daftar breed). API key TIDAK disimpan di repository.
  /// Jalankan dengan: flutter run --dart-define=THE_CAT_API_KEY=xxxx
  static const String theCatApiBaseUrl = 'https://api.thecatapi.com/v1';
  static const String theCatApiKey = String.fromEnvironment(
    'THE_CAT_API_KEY',
    defaultValue:
        'live_a8WBvWVXV7V38TFyKk2WOQ66GpH1wzfIwflml5r0CKmyqRq6dRUSSQEPz2d5lbPa',
  );

  /// Holiday Indonesia API (open source, lisensi MIT, endpoint /holidays/:year).
  /// Masih menunggu konfirmasi dosen (OI-02) dan verifikasi cakupan tahun (OI-01).
  static const String holidayApiBaseUrl =
      'https://indonesian-holidays.ahrulsyamil.com';
}
