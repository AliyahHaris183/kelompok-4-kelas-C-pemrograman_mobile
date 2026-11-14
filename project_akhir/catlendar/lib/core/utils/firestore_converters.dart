import 'package:cloud_firestore/cloud_firestore.dart';

/// Konversi DateTime <-> Timestamp untuk model.
///
/// Field bertipe `date` pada ERD (date_of_birth, performed_date, next_date)
/// disimpan sebagai Timestamp pukul 00:00 UTC pada tanggal kalender tersebut.
/// Saat dibaca, hanya tahun/bulan/hari UTC yang dipakai, sehingga tanggal tidak
/// bergeser walau zona waktu perangkat berbeda.
/// Field `timestamp` (created_at, updated_at) disimpan apa adanya.
Timestamp dateTimeToTimestamp(DateTime value) => Timestamp.fromDate(value);

Timestamp dateOnlyToTimestamp(DateTime value) =>
    Timestamp.fromDate(DateTime.utc(value.year, value.month, value.day));

DateTime timestampToDateOnly(Timestamp value) {
  final utc = value.toDate().toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}

/// Pembaca field yang konsisten untuk `fromMap`.
/// Field wajib yang hilang melempar [FormatException] agar bug data cepat ketahuan.
extension FirestoreMapReader on Map<String, dynamic> {
  String readRequiredString(String key) {
    final value = this[key];
    if (value is String) return value;
    throw FormatException('Field "$key" wajib berupa string, ditemukan: $value');
  }

  String? readString(String key) {
    final value = this[key];
    return value is String ? value : null;
  }

  bool readBool(String key, {bool defaultValue = false}) {
    final value = this[key];
    return value is bool ? value : defaultValue;
  }

  /// Untuk field bertipe timestamp.
  DateTime readRequiredDateTime(String key) {
    final value = this[key];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw FormatException('Field "$key" wajib berupa Timestamp, ditemukan: $value');
  }

  /// Untuk field bertipe date (tanggal saja).
  DateTime readRequiredDate(String key) {
    final value = this[key];
    if (value is Timestamp) return timestampToDateOnly(value);
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    throw FormatException('Field "$key" wajib berupa tanggal, ditemukan: $value');
  }
}
