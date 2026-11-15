import 'package:flutter/material.dart';

class CatAvatar extends StatelessWidget {
  const CatAvatar({
    super.key,
    required this.avatarId,
    this.radius = 36,
    this.isSelected = false,
    this.showBorder = false,
    this.fallbackName,
  });

  final String? avatarId;
  final double radius;
  final bool isSelected;
  final bool showBorder;
  final String? fallbackName;

  /// Pemetaan gaya duo-tone & ikon unik untuk setiap preset ID
  /// sebelum aset final dari Figma tersedia.
  static ({Color bg, Color fg, IconData icon}) _styleForId(String? id) {
    return switch (id) {
      'cat_1' => (
          bg: const Color(0xFFFFE0B2),
          fg: const Color(0xFFE65100),
          icon: Icons.pets,
        ),
      'cat_2' => (
          bg: const Color(0xFFB3E5FC),
          fg: const Color(0xFF0277BD),
          icon: Icons.cruelty_free,
        ),
      'cat_3' => (
          bg: const Color(0xFFC8E6C9),
          fg: const Color(0xFF2E7D32),
          icon: Icons.eco_rounded,
        ),
      'cat_4' => (
          bg: const Color(0xFFF8BBD0),
          fg: const Color(0xFFC2185B),
          icon: Icons.favorite_rounded,
        ),
      'cat_5' => (
          bg: const Color(0xFFE1BEE7),
          fg: const Color(0xFF6A1B9A),
          icon: Icons.nightlight_round,
        ),
      'cat_6' => (
          bg: const Color(0xFFFFF9C4),
          fg: const Color(0xFFF57F17),
          icon: Icons.wb_sunny_rounded,
        ),
      _ => (
          bg: Colors.grey.shade200,
          fg: Colors.grey.shade600,
          icon: Icons.pets,
        ),
    };
  }

  /// Jika aset PNG/SVG dari Figma sudah masuk ke folder assets/avatars/,
  /// aktifkan path di bawah ini dan render dengan Image.asset.
  static String? _assetPathForId(String? id) {
    if (id == null || id.isEmpty) return null;
    // Contoh saat aset sudah siap:
    // return 'assets/avatars/$id.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleForId(avatarId);
    final assetPath = _assetPathForId(avatarId);
    final diameter = radius * 2;
    final hasRing = isSelected || showBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.bg,
        border: hasRing
            ? Border.all(
                color: isSelected ? Colors.black : Colors.white,
                width: isSelected ? 2.5 : 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: assetPath != null
          ? Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallbackContent(style),
            )
          : _buildFallbackContent(style),
    );
  }

  Widget _buildFallbackContent(({Color bg, Color fg, IconData icon}) style) {
    // Jika avatarId null tetapi nama kucing tersedia, tampilkan inisial huruf pertama
    if (avatarId == null &&
        fallbackName != null &&
        fallbackName!.trim().isNotEmpty) {
      return Center(
        child: Text(
          fallbackName!.trim()[0].toUpperCase(),
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.bold,
            color: style.fg,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        style.icon,
        size: radius * 0.9,
        color: style.fg,
      ),
    );
  }
}
