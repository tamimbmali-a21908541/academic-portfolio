import 'package:flutter/material.dart';

/// Application color palette - Islamic themed
class AppColors {
  AppColors._();

  // Primary Colors - Islamic Green
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003300);
  static const Color primaryVariant = Color(0xFF2E7D32);

  // Secondary Colors - Gold/Amber (Islamic architecture)
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFFFE082);
  static const Color secondaryDark = Color(0xFFB8860B);

  // Accent Colors
  static const Color accent = Color(0xFF00897B);
  static const Color accentLight = Color(0xFF4DB6AC);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Prayer Time Colors
  static const Color fajrColor = Color(0xFF1A237E);    // Deep blue - early morning
  static const Color sunriseColor = Color(0xFFFF8F00); // Orange - sunrise
  static const Color dhuhrColor = Color(0xFFFFC107);   // Yellow - noon
  static const Color asrColor = Color(0xFFFF7043);     // Deep orange - afternoon
  static const Color maghribColor = Color(0xFFE64A19); // Sunset orange
  static const Color ishaColor = Color(0xFF311B92);    // Deep purple - night

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF388E3C),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFD4AF37),
    Color(0xFFFFD700),
    Color(0xFFB8860B),
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFFF7043),
    Color(0xFFE64A19),
    Color(0xFFBF360C),
  ];

  // Overlay Colors
  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayDark = Color(0x4D000000);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Shadow Color
  static const Color shadowColor = Color(0x29000000);

  // Islamic Pattern Colors
  static const Color patternColor1 = Color(0x1A1B5E20);
  static const Color patternColor2 = Color(0x1AD4AF37);
}
