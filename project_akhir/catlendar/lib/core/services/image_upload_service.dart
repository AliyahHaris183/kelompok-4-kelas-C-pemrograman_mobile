import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  // Ganti dua nilai di bawah ini dengan milikmu dari Cloudinary
  static const String _cloudName = 'wxcijnfb';
  static const String _uploadPreset = 'lxh5wtyk';

  static final ImagePicker _picker = ImagePicker();

  /// Membuka galeri, mengompres foto, lalu meng-upload ke Cloudinary.
  /// Mengembalikan URL foto (https://...) atau null jika user membatalkan.
  static Future<String?> pickAndUploadCatImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile == null) return null;

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', pickedFile.path),
      );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['secure_url'] as String?;
    } else {
      throw Exception(
          'Gagal upload foto (${streamedResponse.statusCode}): $responseBody');
    }
  }
}
