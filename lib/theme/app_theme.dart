import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF00F5D4); // Neon Cyan
  static const Color primaryDark = Color(0xFF00B4D8);
  static const Color secondary = Color(0xFF10B981); // Neon Emerald
  static const Color accentPurple = Color(0xFF8B5CF6); // Neon Purple
  static const Color accentGold = Color(0xFFFFB703); // Gold
  static const Color accentRose = Color(0xFFF43F5E); // Danger / Error
  static const Color accentOrange = Color(0xFFFB8500);

  // Background Surfaces
  static const Color background = Color(0xFF0A0E17); // Deep Night
  static const Color surface = Color(0xFF121927); // Dark Slate Surface
  static const Color surfaceCard = Color(0xFF1A2338); // Card Background
  static const Color surfaceBorder = Color(0xFF2B3A58); // Border

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Box Shadows
  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: primary.withAlpha(55),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: accentRose,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }
}
