import 'package:flutter/material.dart';

/// NLO Design System - Theme Configuration
/// 
/// İlkeler:
/// - Minimal renk paleti
/// - Sessiz tipografi
/// - İlk bakışta sade, ikinci bakışta derin

class NLOTheme {
  // Primary colors
  static const Color primaryLight = Color(0xFF1A1A2E);
  static const Color primaryDark = Color(0xFFE8E8E8);
  
  // Surface colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  
  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // Accent color - subtle, not loud
  static const Color accent = Color(0xFF4A90A4);
  
  // Text colors
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFF999999);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: surfaceLight,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: accent,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: textPrimaryLight,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryLight,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: textSecondaryLight,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surfaceDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: accent,
      surface: surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade800),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: textPrimaryDark,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryDark,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: textSecondaryDark,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey.shade700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
