/// Nilai reminder_option pada ERD: none, a_week, 3_days, 1_day, d_day.
enum ReminderOption {
  none('none'),
  aWeek('a_week'),
  threeDays('3_days'),
  oneDay('1_day'),
  dDay('d_day');

  const ReminderOption(this.value);

  /// Nilai yang disimpan di Firestore.
  final String value;

  /// Berapa hari sebelum next_date pengingat dikirim. Null jika tidak ada pengingat.
  int? get daysBefore => switch (this) {
        ReminderOption.none => null,
        ReminderOption.aWeek => 7,
        ReminderOption.threeDays => 3,
        ReminderOption.oneDay => 1,
        ReminderOption.dDay => 0,
      };

  static ReminderOption fromValue(String value) {
    for (final option in ReminderOption.values) {
      if (option.value == value) return option;
    }
    throw FormatException('reminder_option tidak dikenal: $value');
  }
}
