import 'package:flutter/material.dart';

/// Maskot kucing di atas judul layar auth.
///
/// Ekspor ilustrasi dari Figma ke assets/images/ dan daftarkan folder tersebut
/// di pubspec.yaml. Nama file yang dipakai:
/// cat_login.png, cat_signup.png (juga untuk layar lain), cat_welcome.png.
/// Selama aset belum ada, ikon cadangan ditampilkan.
class AuthMascot extends StatelessWidget {
  const AuthMascot({
    super.key,
    required this.assetPath,
    this.size = 44,
    this.fallbackColor = Colors.black,
  });

  final String assetPath;
  final double size;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.pets, size: size, color: fallbackColor),
    );
  }
}
