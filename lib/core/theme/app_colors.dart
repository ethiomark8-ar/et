import 'package:flutter/material.dart';

class AppColors {
  // Brand palette — AMOLED dark first
  static const Color primaryDark = Color(0xFF081124);
  static const Color primaryGradientStart = Color(0xFF2E2A72);
  static const Color primaryGradientEnd = Color(0xFF3B368F);
  static const Color secondaryAccent = Color(0xFF4C6FFF);
  static const Color notificationYellow = Color(0xFFFFC83D);

  // Text
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8A8AB0);

  // Backgrounds
  static const Color backgroundMain = Color(0xFF0B0E1A);
  static const Color cardBackground = Color(0xFF131629);
  static const Color surfaceElevated = Color(0xFF1A1E38);

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Rating
  static const Color ratingActive = Color(0xFFFFCC00);
  static const Color ratingInactive = Color(0xFF3A3A5A);

  // UI
  static const Color dividerBorder = Color(0xFF252545);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B0E1A), Color(0xFF060914)],
  );

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x18000040), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F000030), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> primaryButtonShadow = [
    BoxShadow(color: Color(0x402E2A72), blurRadius: 16, offset: Offset(0, 6)),
  ];
}