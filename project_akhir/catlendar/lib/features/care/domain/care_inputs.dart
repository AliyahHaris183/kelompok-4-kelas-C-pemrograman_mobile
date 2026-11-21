import 'package:catlendar/features/care/data/models/care_type.dart';

/// Satu baris pada layar Let's schedule (satu jenis perawatan berikutnya).
class ScheduleInput {
  const ScheduleInput({
    required this.careType,
    this.customName,
    required this.nextDate,
  });

  final CareType careType;
  final String? customName;
  final DateTime nextDate;
}

/// Satu baris pada layar Fill in grooming details (riwayat yang sudah dilakukan).
class PastCareInput {
  const PastCareInput({
    required this.careType,
    this.customName,
    required this.performedDate,
  });

  final CareType careType;
  final String? customName;
  final DateTime performedDate;
}

/// Hasil simpan jadwal. Dibuat sealed agar layar wajib menangani setiap kasus.
sealed class ScheduleSaveResult {
  const ScheduleSaveResult();
}

final class ScheduleSaved extends ScheduleSaveResult {
  const ScheduleSaved({
    required this.savedCount,
    required this.remindersScheduled,
    required this.reminderDenied,
  });

  final int savedCount;
  final int remindersScheduled;

  /// True jika pengingat diminta tetapi izin notifikasi ditolak.
  final bool reminderDenied;
}

final class ScheduleInvalid extends ScheduleSaveResult {
  const ScheduleInvalid(this.messages);

  final List<String> messages;
}

final class ScheduleFailed extends ScheduleSaveResult {
  const ScheduleFailed(this.message);

  final String message;
}
