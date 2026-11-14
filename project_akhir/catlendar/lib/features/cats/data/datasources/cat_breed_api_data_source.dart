import 'package:http/http.dart' as http;

import 'package:catlendar/core/constants/app_constants.dart';
import 'package:catlendar/features/cats/data/models/cat_breed.dart';

/// Klien TheCatAPI (pendukung daftar breed). Milik Orang 2.
class CatBreedApiDataSource {
  CatBreedApiDataSource(this.client);

  final http.Client client;

  // TODO(Orang 2): GET ${AppConstants.theCatApiBaseUrl}/breeds dengan header
  // x-api-key = AppConstants.theCatApiKey (dari --dart-define), parse JSON ke
  // List<CatBreed> lewat CatBreed.fromJson. Tangani error lewat AppException.
  // Siapkan fallback bila API gagal: pengguna tetap bisa memilih Domestic.
  Future<List<CatBreed>> fetchBreeds() => throw UnimplementedError(
        'TODO(Orang 2): ambil breed dari ${AppConstants.theCatApiBaseUrl}/breeds',
      );
}
