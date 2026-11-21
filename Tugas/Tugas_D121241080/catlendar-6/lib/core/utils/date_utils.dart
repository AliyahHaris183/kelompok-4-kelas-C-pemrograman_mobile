/// Fungsi tanggal umum. Disebut AppDateUtils agar tidak bentrok dengan
/// DateUtils milik Flutter.
abstract final class AppDateUtils {
  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des', //
  ];

  static const List<String> _longMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember', //
  ];

  /// Membuang komponen jam. Dipakai untuk field bertipe date pada ERD.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// True jika hari [a] lebih awal dari hari [b] (jam diabaikan).
  static bool isBeforeDay(DateTime a, DateTime b) =>
      dateOnly(a).isBefore(dateOnly(b));

  /// Contoh: 5 Mar 2026
  static String formatDate(DateTime value) =>
      '${value.day} ${_shortMonths[value.month - 1]} ${value.year}';

  /// Contoh: Maret 2026 (untuk header kalender)
  static String formatMonthYear(DateTime value) =>
      '${_longMonths[value.month - 1]} ${value.year}';

  /// Contoh: 2026-03-05 (untuk query API)
  static String toIsoDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static int ageInMonths(DateTime dateOfBirth, {DateTime? now}) {
    final today = now ?? DateTime.now();
    var months = (today.year - dateOfBirth.year) * 12 +
        (today.month - dateOfBirth.month);
    if (today.day < dateOfBirth.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  static int ageInYears(DateTime dateOfBirth, {DateTime? now}) =>
      ageInMonths(dateOfBirth, now: now) ~/ 12;

  /// Contoh: "5 bulan" atau "2 tahun".
  static String formatAge(DateTime dateOfBirth, {DateTime? now}) {
    final months = ageInMonths(dateOfBirth, now: now);
    if (months < 12) return '$months bulan';
    return '${months ~/ 12} tahun';
  }
}

extension DateTimeFormatting on DateTime {
  /// Contoh: 5 Mar 2026
  String get formatted => AppDateUtils.formatDate(this);

  /// Tanggal tanpa jam.
  DateTime get dateOnly => AppDateUtils.dateOnly(this);
}
