/// Satu hari libur dari Holiday Indonesia API.
///
/// Respons (dibungkus { "meta": ..., "data": [...] }):
/// { "date": "2025-08-17", "name": "...", "type": "national_holiday",
///   "is_national": true, ... }
/// Sumber: https://indonesian-holidays.ahrulsyamil.com (lisensi MIT).
/// Bukan entitas ERD, tidak disimpan ke Firestore.
class Holiday {
  const Holiday({
    required this.date,
    required this.name,
    required this.isNational,
  });

  /// Tanggal saja, tanpa jam.
  final DateTime date;
  final String name;

  /// true: hari libur nasional. false: cuti bersama.
  final bool isNational;

  factory Holiday.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final rawName = json['name'];
    if (rawDate is! String || rawName is! String) {
      throw FormatException('Data hari libur tidak valid: $json');
    }
    final parsed = DateTime.parse(rawDate);
    final rawNational = json['is_national'];
    final isNational = rawNational is bool
        ? rawNational
        : json['type'] == 'national_holiday';
    return Holiday(
      date: DateTime(parsed.year, parsed.month, parsed.day),
      name: rawName,
      isNational: isNational,
    );
  }
}
