/// Satu hari libur Indonesia untuk kalender.
///
/// TODO(Orang 3): tambahkan factory fromJson setelah tim mengonfirmasi API
/// Holiday Indonesia dan format responsnya (keputusan 7.9). Format respons
/// sengaja tidak ditebak di sini.
class Holiday {
  const Holiday({required this.date, required this.name});

  /// Tanggal saja.
  final DateTime date;
  final String name;
}
