import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:catlendar/core/constants/app_constants.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';

/// Dilempar jika data hari libur tidak bisa diambil. Kalender tetap berjalan (FR-64).
class HolidayUnavailableException implements Exception {
  const HolidayUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Klien Holiday Indonesia API: GET {base}/holidays/{year}.
class HolidayApiDataSource {
  HolidayApiDataSource(this.client, {String? baseUrl})
      : baseUrl = baseUrl ?? AppConstants.holidayApiBaseUrl;

  final http.Client client;
  final String baseUrl;

  Future<List<Holiday>> fetchHolidays({required int year}) async {
    if (baseUrl.isEmpty) {
      throw const HolidayUnavailableException(
        'Sumber data hari libur belum dikonfigurasi.',
      );
    }

    final uri = Uri.parse('$baseUrl/holidays/$year');
    final http.Response response;
    try {
      response = await client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const HolidayUnavailableException(
        'Gagal terhubung ke layanan hari libur.',
      );
    }

    if (response.statusCode != 200) {
      throw HolidayUnavailableException(
        'Data hari libur $year belum tersedia (status ${response.statusCode}).',
      );
    }

    try {
      final body = jsonDecode(response.body);
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is! List) {
        throw const FormatException('Field data tidak ditemukan.');
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(Holiday.fromJson)
          .toList(growable: false);
    } on FormatException {
      throw HolidayUnavailableException(
        'Format data hari libur $year tidak dikenali.',
      );
    }
  }
}
