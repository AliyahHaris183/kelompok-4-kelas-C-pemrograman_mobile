/// Konfigurasi Cloudinary untuk unggah foto (unsigned upload).
///
/// Nilainya TIDAK ditulis di kode. Isi di env.json (tidak di-commit), lalu
/// jalankan dengan: flutter run --dart-define-from-file=env.json
///
///   "CLOUDINARY_CLOUD_NAME": "...",
///   "CLOUDINARY_UPLOAD_PRESET": "..."
///
/// Upload preset harus bertipe Unsigned di dashboard Cloudinary.
abstract final class CloudinaryConfig {
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );
}
