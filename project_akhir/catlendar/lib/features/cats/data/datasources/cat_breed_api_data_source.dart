import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:catlendar/core/constants/app_constants.dart';
import 'package:catlendar/features/cats/data/models/cat_breed.dart';

/// Klien TheCatAPI (pendukung daftar breed). Milik Orang 2.
class CatBreedApiDataSource {
  CatBreedApiDataSource(this.client);

  final http.Client client;

  Future<List<CatBreed>> fetchBreeds() async {
    try {
      final uri = Uri.parse('${AppConstants.theCatApiBaseUrl}/breeds');
      final headers = <String, String>{
        if (AppConstants.theCatApiKey.isNotEmpty)
          'x-api-key': AppConstants.theCatApiKey,
      };

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => CatBreed.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Fallback jika API gagal: dropdown di UI tetap menampilkan 'Domestic'
      return const [];
    } catch (_) {
      // Fallback jika offline / error jaringan agar pengguna tetap bisa memilih 'Domestic'
      return const [];
    }
  }
}
