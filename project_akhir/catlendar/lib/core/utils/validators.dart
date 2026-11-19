import 'package:catlendar/core/constants/app_constants.dart';

/// Validator generik untuk FormField. Mengembalikan pesan error atau null.
abstract final class Validators {
  static String? requiredField(String? value, {String fieldName = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    final error = requiredField(value, fieldName: 'Email');
    if (error != null) return error;
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value!.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    final error = requiredField(value, fieldName: 'Password');
    if (error != null) return error;
    if (value!.length < AppConstants.minPasswordLength) {
      return 'Password minimal ${AppConstants.minPasswordLength} karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    final error = requiredField(value, fieldName: 'Konfirmasi password');
    if (error != null) return error;
    if (value != original) return 'Konfirmasi password tidak sama';
    return null;
  }

  static String? requiredDate(DateTime? value, {String fieldName = 'Tanggal'}) {
    if (value == null) return '$fieldName wajib diisi';
    return null;
  }

  /// Untuk SCHEDULE: next_date tidak boleh sebelum tanggal terakhir.
  /// Jika salah satu null, dianggap valid.
  static String? dateNotBefore(
    DateTime? value,
    DateTime? reference, {
    String message = 'Tanggal tidak boleh sebelum tanggal terakhir',
  }) {
    if (value == null || reference == null) return null;
    final v = DateTime(value.year, value.month, value.day);
    final r = DateTime(reference.year, reference.month, reference.day);
    return v.isBefore(r) ? message : null;
  }
}
