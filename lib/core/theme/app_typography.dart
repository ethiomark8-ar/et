import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Color textColor) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: textColor),
        displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: textColor),
        displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textColor),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}