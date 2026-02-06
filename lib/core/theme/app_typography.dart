import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system with accessibility support
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Poppins';

  // Minimum accessible font sizes (WCAG)
  static const double _minBodySize = 14.0;
  static const double _minCaptionSize = 12.0;

  static TextTheme get lightTextTheme => _buildTextTheme(AppColors.textPrimary);
  static TextTheme get darkTextTheme =>
      _buildTextTheme(AppColors.darkTextPrimary);
  static TextTheme get hcTextTheme => _buildTextTheme(AppColors.hcText);

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _minBodySize,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _minBodySize,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _minCaptionSize,
        fontWeight: FontWeight.w400,
        color: baseColor.withOpacity(0.7),
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _minBodySize,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _minCaptionSize,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor.withOpacity(0.6),
        letterSpacing: 0.5,
        height: 1.4,
      ),
    );
  }
}
