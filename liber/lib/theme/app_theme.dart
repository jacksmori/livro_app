import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light mode
  static const lightPrimary = Color(0xFF6B7C47);
  static const lightPrimaryDark = Color(0xFF4E5C32);
  static const lightBackground = Color(0xFFF5F3EE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFEAE6DC);
  static const lightText = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF5C5C5C);
  static const lightBorder = Color(0xFFD4CFC4);

  // Dark mode
  static const darkPrimary = Color(0xFF6B7C47);
  static const darkPrimaryDark = Color(0xFF4E5C32);
  static const darkBackground = Color(0xFF0D1410);
  static const darkSurface = Color(0xFF1A2218);
  static const darkCard = Color(0xFF1E2A1C);
  static const darkText = Color(0xFFE8E4DA);
  static const darkTextSecondary = Color(0xFF8A9B7A);
  static const darkBorder = Color(0xFF2E3D2C);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightPrimaryDark,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSurface: AppColors.lightText,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
      bodyLarge: GoogleFonts.lato(color: AppColors.lightText, fontSize: 16),
      bodyMedium: GoogleFonts.lato(color: AppColors.lightText, fontSize: 14),
      bodySmall:
          GoogleFonts.lato(color: AppColors.lightTextSecondary, fontSize: 12),
      titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.lightText,
          fontSize: 24,
          fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.playfairDisplay(
          color: AppColors.lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.playfairDisplay(
          color: AppColors.lightText,
          fontSize: 16,
          fontWeight: FontWeight.w600),
      labelLarge: GoogleFonts.lato(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      labelStyle: GoogleFonts.lato(color: AppColors.lightTextSecondary),
      hintStyle: GoogleFonts.lato(color: AppColors.lightBorder),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.lightText),
      titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: AppColors.lightTextSecondary,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkPrimaryDark,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSurface: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.playfairDisplayTextTheme(ThemeData.dark().textTheme)
        .copyWith(
      bodyLarge: GoogleFonts.lato(color: AppColors.darkText, fontSize: 16),
      bodyMedium: GoogleFonts.lato(color: AppColors.darkText, fontSize: 14),
      bodySmall:
          GoogleFonts.lato(color: AppColors.darkTextSecondary, fontSize: 12),
      titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.darkText, fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.playfairDisplay(
          color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.playfairDisplay(
          color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w600),
      labelLarge: GoogleFonts.lato(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      labelStyle: GoogleFonts.lato(color: AppColors.darkTextSecondary),
      hintStyle: GoogleFonts.lato(color: AppColors.darkBorder),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.darkText, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkTextSecondary,
    ),
  );
}
