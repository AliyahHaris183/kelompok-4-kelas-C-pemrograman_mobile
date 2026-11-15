/// Nilai gender yang disimpan di field `gender` (USERS dan CATS).
/// ERD hanya menyebut tipe string; nilai ini disepakati agar konsisten
/// (contoh pada alur: "Male Neutered").
abstract final class GenderOptions {
  static const String male = 'Male';
  static const String female = 'Female';
  static const List<String> values = [male, female];
}
