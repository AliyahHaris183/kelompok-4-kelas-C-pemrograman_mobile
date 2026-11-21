import 'package:flutter/material.dart';

import 'package:catlendar/features/care/data/models/care_type.dart';

/// Label jenis perawatan untuk layar dan notifikasi (sesuai desain Figma).
String careTypeLabel(CareType type, {String? customName}) {
  return switch (type) {
    CareType.bath => 'Bath',
    CareType.flea => 'Flea treatment',
    CareType.fungal => 'Fungal treatment',
    CareType.vetVisit => 'Vet visit',
    CareType.vaccination => 'Vaccination',
    CareType.custom => (customName == null || customName.trim().isEmpty)
        ? 'Custom event'
        : customName.trim(),
  };
}

/// Label pilihan pengingat (sesuai desain Figma "Remind me?").
String reminderLabel(String value) {
  return switch (value) {
    'a_week' => 'A week before',
    '3_days' => '3 days before',
    '1_day' => '1 day before',
    'd_day' => 'D-day',
    _ => "Don't remind me",
  };
}

/// Ikon per jenis perawatan untuk kolom tanggal (mendekati ikon Figma).
IconData careTypeIcon(CareType type) {
  return switch (type) {
    CareType.bath => Icons.shower_outlined,
    CareType.flea => Icons.bug_report_outlined,
    CareType.fungal => Icons.pets,
    CareType.vetVisit => Icons.medical_services_outlined,
    CareType.vaccination => Icons.vaccines_outlined,
    CareType.custom => Icons.add_circle_outline,
  };
}
