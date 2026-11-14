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
  static const String theCatApiKey = String.fromEnvironment('THE_CAT_API_KEY');

  /// Holiday Indonesia API.
  /// TODO(Orang 3): isi setelah tim mengonfirmasi API, lisensi, dan batas
  /// pemakaiannya (keputusan 7.9). Sengaja dikosongkan, tidak ditebak.
  static const String holidayApiBaseUrl = '';
}
