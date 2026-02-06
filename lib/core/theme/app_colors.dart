import 'package:flutter/material.dart';

/// Running Club Tunis brand colors
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary
  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFE65100);

  // Accent
  static const Color accent = Color(0xFF00C853);
  static const Color accentLight = Color(0xFF69F0AE);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Event status
  static const Color eventUpcoming = Color(0xFFFFA726);
  static const Color eventOngoing = Color(0xFF66BB6A);
  static const Color eventCompleted = Color(0xFF78909C);
  static const Color eventCancelled = Color(0xFFE53935);
  static const Color eventPast = Color(0xFF78909C);

  // Event types
  static const Color eventRace = Color(0xFFE53935);
  static const Color eventTrail = Color(0xFF43A047);
  static const Color eventTraining = Color(0xFF1E88E5);
  static const Color eventSocial = Color(0xFFFF6F00);

  // Strava
  static const Color stravaOrange = Color(0xFFFC4C02);

  // Neutrals
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color disabled = Color(0xFFD1D5DB);

  // Dark mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // High contrast
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF000000);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcPrimary = Color(0xFF4FC3F7);
  static const Color hcSecondary = Color(0xFFFFD54F);

  // Participation
  static const Color organizer = Color(0xFFE53935);
  static const Color participant = Color(0xFF43A047);
  static const Color interested = Color(0xFFFFA726);
  static const Color participantColor = Color(0xFF43A047);
  static const Color interestedColor = Color(0xFFFFA726);

  // Group colors
  static const List<Color> groupColors = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFFF6F00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
  ];

  // Medals
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);
}
