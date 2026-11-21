import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/care/data/models/care_record.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/presentation/utils/care_labels.dart';

/// Label Last (riwayat, CARE_RECORD) atau Next (jadwal, SCHEDULE).
enum SummaryKind { last, next }

/// Satu entri pada Summary dan daftar aktivitas kalender.
class SummaryEntry {
  const SummaryEntry({
    required this.date,
    required this.kind,
    required this.careType,
    this.customName,
    required this.catId,
    required this.catName,
    this.avatarId,
    this.schedule,
    this.overdue = false,
  });

  final DateTime date;
  final SummaryKind kind;
  final CareType careType;
  final String? customName;
  final String catId;
  final String catName;
  final String? avatarId;

  /// Terisi untuk entri Next, agar layar bisa menyelesaikan atau membatalkannya.
  final Schedule? schedule;

  /// Jadwal Next yang tanggalnya sudah lewat tetapi belum diselesaikan (OI-05).
  final bool overdue;

  String get label => careTypeLabel(careType, customName: customName);
}

/// Menggabungkan jadwal aktif dan riwayat menjadi entri yang diurutkan per tanggal.
///
/// Jadwal yang sudah selesai atau dibatalkan (is_active = false) tidak ditampilkan
/// sebagai Next. Entri yatim (kucing sudah tidak ada) dilewati.
List<SummaryEntry> buildSummaryEntries({
  required List<Schedule> schedules,
  required List<CareRecord> records,
  required List<Cat> cats,
  String? catId,
  DateTime? now,
}) {
  final today = AppDateUtils.dateOnly(now ?? DateTime.now());
  final catById = {for (final cat in cats) cat.catId: cat};
  final entries = <SummaryEntry>[];

  for (final schedule in schedules) {
    if (!schedule.isActive) continue;
    if (catId != null && schedule.catId != catId) continue;
    final cat = catById[schedule.catId];
    if (cat == null) continue;
    entries.add(
      SummaryEntry(
        date: schedule.nextDate,
        kind: SummaryKind.next,
        careType: schedule.careType,
        customName: schedule.customName,
        catId: cat.catId,
        catName: cat.name,
        avatarId: cat.avatarId,
        schedule: schedule,
        overdue: schedule.nextDate.isBefore(today),
      ),
    );
  }

  for (final record in records) {
    if (catId != null && record.catId != catId) continue;
    final cat = catById[record.catId];
    if (cat == null) continue;
    entries.add(
      SummaryEntry(
        date: record.performedDate,
        kind: SummaryKind.last,
        careType: record.careType,
        customName: record.customName,
        catId: cat.catId,
        catName: cat.name,
        avatarId: cat.avatarId,
      ),
    );
  }

  entries.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.kind.index.compareTo(b.kind.index);
  });
  return entries;
}
