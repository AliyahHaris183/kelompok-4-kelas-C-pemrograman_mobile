import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:catlendar/app/theme/app_colors.dart';
import 'package:catlendar/app/theme/app_text_styles.dart';

abstract final class AppTheme {
  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF8E8E93);
  static const Color outline = Color(0xFFD0D0D0);

  static OutlineInputBorder _pillBorder(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: color),
      );

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ink,
      brightness: Brightness.light,
    ).copyWith(
      primary: ink,
      onPrimary: Colors.white,
      surface: Colors.white,
      error: AppColors.error,
    );

    final baseTextTheme = GoogleFonts.poppinsTextTheme(AppTextStyles.textTheme).apply(
      bodyColor: ink,
      displayColor: ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        hintStyle: const TextStyle(fontSize: 13, color: muted),
        labelStyle: const TextStyle(fontSize: 13, color: muted),
        border: _pillBorder(outline),
        enabledBorder: _pillBorder(outline),
        disabledBorder: _pillBorder(outline),
        focusedBorder: _pillBorder(ink),
        errorBorder: _pillBorder(AppColors.error),
        focusedErrorBorder: _pillBorder(AppColors.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: ink),
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
      ),
    );
  }
}
