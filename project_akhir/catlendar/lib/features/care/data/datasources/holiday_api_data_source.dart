import 'package:http/http.dart' as http;

import 'package:catlendar/features/care/data/models/holiday.dart';

/// Klien Holiday Indonesia API. Milik Orang 3.
class HolidayApiDataSource {
  HolidayApiDataSource(this.client);

  final http.Client client;

  // TODO(Orang 3): konfirmasi API, lisensi, dan batas pemakaian (keputusan 7.9),
  // isi AppConstants.holidayApiBaseUrl, lalu parse respons ke List<Holiday>.
  // Disarankan cache hasil per tahun agar tidak menyentuh batas pemakaian.
  Future<List<Holiday>> fetchHolidays({required int year}) =>
      throw UnimplementedError('TODO(Orang 3): ambil hari libur tahun $year');
}
