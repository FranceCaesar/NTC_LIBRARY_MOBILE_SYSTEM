import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ntc_library/theme/colorpallet.dart';


class AppTypography {
  // Prevent instantiation
  AppTypography._();

  static TextTheme get textTheme {
    return TextTheme(
      // Display Styles (Roboto, SemiBold, Primary Text)
      displayLarge: GoogleFonts.robotoSerif(
        fontSize: 44,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.primaryText,
      ),
      displayMedium: GoogleFonts.robotoSerif(
        fontSize: 35,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      displaySmall: GoogleFonts.robotoSerif(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryText,
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.robotoSerif(
        fontSize: 36,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.primaryText,
      ),
      headlineMedium: GoogleFonts.robotoSerif( // Note: Roboto Serif
        fontSize: 24,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.primaryText,      // Note: Primary Color (Blue)
      ),
      headlineSmall: GoogleFonts.robotoSerif( // Note: Roboto Serif
        fontSize: 18,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.primaryBackground,
      ),

      // Title Styles
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.primaryBackground, // Using White (from image "Secondary Background" swatch)
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.primaryText,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.primaryText,
      ),

      // Label Styles (Secondary Text Color)
      labelLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.secondaryText,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.secondaryText,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Normal
        color: AppColors.secondaryText,
      ),

      // Body Styles
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.primaryText,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.primaryText,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Normal
        color: AppColors.primaryText,
      ),
    );
  }
}