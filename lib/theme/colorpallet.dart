import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // --- Brand Colors ---
  static const Color primary = Color(0xFF0033A0);
  static const Color secondary = Color(0xFFFFD100);
  static const Color tertiary = Color(0xFF002855);
  static const Color alternate = Color(0xFFC5C6CC);

  // --- Utility Colors ---
  static const Color primaryText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF9CA3AF);
  static const Color primaryBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF1F4F8);

  // --- Accent Colors ---
  // Note: These appear to use the #AARRGGBB format based on the visual swatches
  static const Color accent1 = Color(0x4C4B39EF); // Dark Blue/Purple with Alpha
  static const Color accent2 = Color(0x4D39D2C0); // Teal with Alpha
  static const Color accent3 = Color(0x4DEE8B60); // Brown/Orange with Alpha
  static const Color accent4 = Color(0xCCFFFFFF); // White with Alpha

  // --- Semantic Colors ---
  static const Color success = Color(0xFF298267);
  static const Color error = Color(0xFFFF5963);
  static const Color warning = Color(0xFFE86339);
  static const Color info = Color(0xFFF9FAFB);

  // --- Custom Colors ---
  static const Color lightVibrantColor = Color(0xFFB5B1DB);
  static const Color darkVibrantColor = Color(0xFF0D018C);
  static const Color lightMutedColor = Color(0xFF847DC5);
  static const Color darkMutedColor = Color(0xFF83734D);
  static const Color customColor1 = Color(0xFF1769FF);
}