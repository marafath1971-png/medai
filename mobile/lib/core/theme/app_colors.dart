import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Monochrome Base
  static const Color background = Color(0xFF000000);
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color card = Color(0xFF0A0A0A);
  static const Color cardForeground = Color(0xFFFFFFFF);
  static const Color popover = Color(0xFF0A0A0A);
  static const Color popoverForeground = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryForeground = Color(0xFF000000);
  static const Color secondary = Color(0xFF1A1A1A);
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF1A1A1A);
  static const Color mutedForeground = Color(0xFF737373);
  static const Color accent = Color(0xFF1A1A1A);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color destructive = Color(0xFFFF3333);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFF262626);
  static const Color input = Color(0xFF262626);
  static const Color ring = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Glassmorphism
  static const Color glassBackground = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFE5E5E5)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
  );

  // Status Colors for Medication
  static const Color taken = Color(0xFF22C55E);
  static const Color missed = Color(0xFFEF4444);
  static const Color snoozed = Color(0xFFF59E0B);
  static const Color pending = Color(0xFF737373);
}
