import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema layar Care, diperkirakan dari screenshot desain Figma:
/// font Poppins, latar putih, teks hitam, tombol hitam berbentuk pil,
/// dan kolom berbentuk pil dengan garis abu-abu. Hanya berlaku di fitur Care.
abstract final class CareTheme {
  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF8A8A8A);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color today = Color(0xFF3A6FF7);

  static ThemeData of(BuildContext context) {
    final base = Theme.of(context);
    final text = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: ink,
      displayColor: ink,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: text,
      colorScheme: base.colorScheme.copyWith(
        primary: ink,
        onPrimary: Colors.white,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? ink : outline,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: _pill(outline),
        enabledBorder: _pill(outline),
        focusedBorder: _pill(ink),
        hintStyle: GoogleFonts.poppins(color: muted, fontSize: 15),
      ),
    );
  }

  static OutlineInputBorder _pill(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: color),
      );
}
