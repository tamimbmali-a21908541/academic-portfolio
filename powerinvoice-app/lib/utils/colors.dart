import 'package:flutter/material.dart';

/// PowerInvoice Color Palette
/// Based on 777 folder screenshots
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);      // Navigation, buttons, FAB
  static const Color successGreen = Color(0xFF4CAF50);     // Paid, success, stock
  static const Color errorRed = Color(0xFFEF5350);         // Unpaid, errors
  static const Color warningOrange = Color(0xFFFF9800);    // Partial, warnings
  static const Color infoPurple = Color(0xFF9C27B0);       // Analytics, info

  // Background Colors
  static const Color backgroundDark = Color(0xFF121212);   // Main background
  static const Color surfaceDark = Color(0xFF1E1E1E);      // Cards, surfaces
  static const Color surfaceGrey = Color(0xFF424242);      // Inputs, inactive

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);        // Primary text
  static const Color textGrey = Color(0xFFBDBDBD);         // Secondary text
  static const Color textDisabled = Color(0xFF757575);     // Disabled text

  // Status Colors (Aliases for clarity)
  static const Color statusPaid = successGreen;
  static const Color statusUnpaid = errorRed;
  static const Color statusPartiallyPaid = warningOrange;
  static const Color statusDraft = textDisabled;
}
