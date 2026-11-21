import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Gambar yang dipilih pengguna dari galeri.
class PickedImage {
  const PickedImage({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

/// Memilih gambar dari galeri perangkat.
abstract class ImagePickerService {
  /// Null jika pengguna membatalkan pemilihan.
  Future<PickedImage?> pickFromGallery();
}

/// Implementasi dengan image_picker. Di Android tidak butuh izin tambahan.
/// Gambar diperkecil (maks. 1024 px, kualitas 85) agar unggahan cepat.
class GalleryImagePickerService implements ImagePickerService {
  GalleryImagePickerService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedImage?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return null;
    return PickedImage(bytes: await file.readAsBytes(), name: file.name);
  }
}
