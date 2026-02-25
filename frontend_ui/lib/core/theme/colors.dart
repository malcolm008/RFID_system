// lib/core/theme/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFF9E47FF);
  static const Color primaryDark = Color(0xFF590B7C);

  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);

  // Dark Theme Accent Colors (as specified)
  static const Color tealAccent = Color(0xFF64FFDA);      // Teal Accent
  static const Color pinkAccent = Color(0xFFFF80AB);      // Pink Accent
  static const Color deepPurpleAccent = Color(0xFFB388FF); // Deep Purple Accent

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color backgroundDark = Color(0xFF1A1A1A);   // Pure Black

  // Surface Colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF121212);      // Dark surface
  static const Color surfaceDarkElevated = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F1F1F);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  // Status Colors
  static const Color success = Color(0xFF24D7A7);
  static const Color error = Color(0xFFF86A67);
  static const Color warning = Color(0xFFFFBE5E);
  static const Color info = Color(0xFF8764FD);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF2C2C2C);

  // Card Colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6200EE),
    Color(0xFF9E47FF),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF64FFDA),
    Color(0xFFB388FF),
    Color(0xFFFF80AB),
  ];

  // Shimmer Colors
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3C3C3C);
}

// Extension for easier access to theme colors
extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).cardColor;
  Color get textPrimary => Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;
  Color get textSecondary => Theme.of(this).textTheme.bodyMedium?.color ?? Colors.grey;
}