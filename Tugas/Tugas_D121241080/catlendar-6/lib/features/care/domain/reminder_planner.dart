import 'package:catlendar/features/care/data/models/reminder_option.dart';

/// Menghitung waktu pengingat lokal (FR-42, FR-70).
///
/// Pengingat dikirim pukul [reminderHour] waktu perangkat pada hari
/// (next_date dikurangi pilihan hari). Jam ini asumsi tim dan belum
/// diputuskan di dokumen desain.
abstract final class ReminderPlanner {
  static const int reminderHour = 8;

  /// Waktu pengingat, atau null jika tidak ada pengingat atau waktunya sudah lewat.
  static DateTime? reminderAt({
    required DateTime nextDate,
    required ReminderOption option,
    required DateTime now,
  }) {
    final days = option.daysBefore;
    if (days == null) return null;
    final at = DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day - days,
      reminderHour,
    );
    return at.isAfter(now) ? at : null;
  }
}
