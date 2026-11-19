import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:catlendar/core/errors/app_exception.dart';

/// Mengunggah gambar ke penyimpanan luar dan mengembalikan URL publiknya.
/// Firebase Storage tidak dipakai (butuh billing), jadi memakai Cloudinary.
abstract class ImageUploader {
  /// URL https gambar yang sudah diunggah.
  Future<String> upload({required Uint8List bytes, required String filename});
}

/// Unggah ke Cloudinary dengan upload preset bertipe unsigned.
/// Tidak memakai API secret, sehingga aman ditaruh di aplikasi.
class CloudinaryImageUploader implements ImageUploader {
  CloudinaryImageUploader({
    required this.cloudName,
    required this.uploadPreset,
    required this.client,
  });

  final String cloudName;
  final String uploadPreset;
  final http.Client client;

  static const Duration _timeout = Duration(seconds: 30);

  @override
  Future<String> upload({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw const AppException(
        'Cloudinary belum dikonfigurasi. Isi CLOUDINARY_CLOUD_NAME dan '
        'CLOUDINARY_UPLOAD_PRESET di env.json.',
        type: AppErrorType.validation,
        code: 'cloudinary-not-configured',
      );
    }

    final uri = Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    try {
      final streamed = await client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final json = _decode(response.body);

      if (response.statusCode != 200) {
        final error = json?['error'];
        final message = error is Map ? error['message'] : null;
        throw AppException(
          message is String
              ? 'Gagal mengunggah foto: $message'
              : 'Gagal mengunggah foto (kode ${response.statusCode}).',
          code: 'upload-failed',
        );
      }

      final url = json?['secure_url'];
      if (url is! String || url.isEmpty) {
        throw const AppException(
          'Gagal mengunggah foto: respons Cloudinary tidak berisi URL.',
          code: 'upload-failed',
        );
      }
      return url;
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        'Gagal mengunggah foto. Periksa koneksi internet.',
        type: AppErrorType.network,
        code: 'upload-network',
        cause: error,
      );
    }
  }

  Map<String, dynamic>? _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
