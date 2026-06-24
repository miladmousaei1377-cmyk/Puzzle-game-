import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFEDE6D6);
  static const ink = Color(0xFF231F1B);
  static const accent = Color(0xFF3C5A4A);
  static const muted = Color(0xFFC9BFA8);
  static const error = Color(0xFF8C5A3C);
  static const surface = Color(0xFFF5F0E8);
}

class AppFonts {
  static const display = 'Lalezar';
  static const body = 'Vazirmatn';
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          surface: AppColors.background,
          primary: AppColors.ink,
          secondary: AppColors.accent,
          error: AppColors.error,
          onSurface: AppColors.ink,
          onPrimary: AppColors.background,
        ),
        fontFamily: AppFonts.body,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 40,
            color: AppColors.ink,
            fontWeight: FontWeight.w400,
          ),
          titleLarge: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 24,
            color: AppColors.ink,
          ),
          bodyLarge: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 16,
            color: AppColors.ink,
          ),
          bodyMedium: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 14,
            color: AppColors.ink,
          ),
          labelMedium: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.background,
            textStyle: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.ink, width: 1.5),
            textStyle: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}
