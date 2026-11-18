import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/media/cloudinary_config.dart';
import 'package:catlendar/core/media/image_picker_service.dart';
import 'package:catlendar/core/media/image_uploader.dart';
import 'package:catlendar/core/providers/http_provider.dart';

/// Pengunggah gambar bersama (Cloudinary). Fitur lain yang butuh unggah foto
/// (mis. foto kucing) memakai provider yang sama, bukan membuat sendiri.
final imageUploaderProvider = Provider<ImageUploader>(
  (ref) => CloudinaryImageUploader(
    cloudName: CloudinaryConfig.cloudName,
    uploadPreset: CloudinaryConfig.uploadPreset,
    client: ref.watch(httpClientProvider),
  ),
);

final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => GalleryImagePickerService(),
);
