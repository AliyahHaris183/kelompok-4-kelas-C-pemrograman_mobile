import 'package:flutter/material.dart';

/// PLACEHOLDER: tipografi dasar. Warna sengaja tidak diset agar mengikuti theme.
/// Ganti ukuran dan font ketika desain Figma tersedia.
abstract final class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(fontSize: 16);
  static const TextStyle bodySmall = TextStyle(fontSize: 14);
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextTheme textTheme = TextTheme(
    headlineMedium: headline,
    titleLarge: title,
    bodyLarge: body,
    bodyMedium: bodySmall,
    labelLarge: label,
  );
}
