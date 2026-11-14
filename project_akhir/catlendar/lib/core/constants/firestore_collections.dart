/// Nama koleksi Firestore. Mengikuti ERD secara persis (huruf besar).
/// Jangan menulis string nama koleksi di tempat lain.
abstract final class FirestoreCollections {
  static const String users = 'USERS';
  static const String cats = 'CATS';
  static const String medicalHistory = 'MEDICAL_HISTORY';
  static const String careRecord = 'CARE_RECORD';
  static const String schedule = 'SCHEDULE';
}
