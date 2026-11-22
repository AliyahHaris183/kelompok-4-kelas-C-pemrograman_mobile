/// Nilai care_type pada ERD: bath, flea, fungal, vet_visit, vaccination, custom.
enum CareType {
  bath('bath'),
  flea('flea'),
  fungal('fungal'),
  vetVisit('vet_visit'),
  vaccination('vaccination'),
  custom('custom');

  const CareType(this.value);

  /// Nilai yang disimpan di Firestore.
  final String value;

  static CareType fromValue(String value) {
    for (final type in CareType.values) {
      if (type.value == value) return type;
    }
    throw FormatException('care_type tidak dikenal: $value');
  }
}
