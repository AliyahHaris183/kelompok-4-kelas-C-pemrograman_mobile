import 'package:flutter/material.dart';

/// Maskot kucing di atas judul layar auth.

/// Path file diambil dari AppAssets.
/// Jika file tidak ditemukan, ikon cadangan akan ditampilkan.
class AuthMascot extends StatelessWidget {
  const AuthMascot({
    super.key,
    required this.assetPath,
    this.size = 56,
    this.alignment = Alignment.centerLeft,
    this.fallbackColor = Colors.black,
  });

  final String assetPath;

  /// Kotak tempat gambar digambar.
  /// Gambar mempertahankan proporsinya.
  final double size;

  /// Posisi gambar di dalam kotak.
  final AlignmentGeometry alignment;

  final Color fallbackColor;

  Widget _fallback() {
    return Icon(
      Icons.pets,
      size: size,
      color: fallbackColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Gagal memuat gambar: $assetPath');
        debugPrint('$error');

        return _fallback();
      },
    );
  }
}