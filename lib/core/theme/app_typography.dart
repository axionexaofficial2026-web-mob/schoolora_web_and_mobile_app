import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Plus Jakarta Sans';

  static TextTheme createTextTheme(Color textColor, Color secondaryTextColor) {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    return base.copyWith(
      // Display / H1 -> 700
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),

      // H2 / H3 -> 600
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.35,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.35,
      ),

      // Titles / Subheadings -> 600
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: secondaryTextColor,
        height: 1.4,
      ),

      // Body -> 400
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        height: 1.5,
      ),

      // Labels -> 500
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0.2,
      ),
    );
  }

  // Button text style -> 600
  static TextStyle buttonTextStyle(Color color) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.2,
    );
  }

  // Table header -> 500
  static TextStyle tableHeaderStyle(Color color) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13.0,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.1,
    );
  }

  // Table cell -> 400
  static TextStyle tableCellStyle(Color color) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13.0,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
