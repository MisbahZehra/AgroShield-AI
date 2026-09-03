import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color splashDark = Color(0xFF0E3B21);
  static const Color background = Color(0xFFF6F8F4);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E2B22);
  static const Color textSecondary = Color(0xFF6B7A6F);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFD93025);
  static const Color dangerLight = Color(0xFFFDECEA);
  static const Color warningLight = Color(0xFFFEF6E7);
  static const Color successLight = Color(0xFFE6F4EA);
}

class AppTheme {
  static ThemeData build(Locale locale) {
    return _buildTheme(locale, false);
  }

  static ThemeData buildDark(Locale locale) {
    return _buildTheme(locale, true);
  }

  static ThemeData _buildTheme(Locale locale, bool dark) {
    final isRtl =
        locale.languageCode == 'ur' || locale.languageCode == 'sd';
    final seed = dark
        ? ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.surface,
          );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: seed,
      scaffoldBackgroundColor: dark ? const Color(0xFF121A14) : AppColors.background,
      fontFamily: isRtl ? null : null,
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF121A14) : AppColors.background,
        foregroundColor: dark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1E2B22) : AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1E2B22) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? const Color(0xFF1E2B22) : Colors.white,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
