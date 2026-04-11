import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';
  static const String fontFamilyMono = 'JetBrains Mono';

  static const double _textXs = 12;
  static const double _textSm = 14;
  static const double _textBase = 16;
  static const double _textLg = 18;
  static const double _textXl = 20;
  static const double _text2xl = 24;
  static const double _text3xl = 30;
  static const double _text4xl = 36;

  static const FontWeight fontNormal = FontWeight.w400;
  static const FontWeight fontMedium = FontWeight.w500;
  static const FontWeight fontSemibold = FontWeight.w600;
  static const FontWeight fontBold = FontWeight.w700;

  static TextStyle get displayLarge => const TextStyle(
    fontSize: _text4xl,
    fontWeight: fontBold,
    letterSpacing: -0.02,
    height: 1.2,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontSize: _text3xl,
    fontWeight: fontBold,
    letterSpacing: -0.02,
    height: 1.25,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontSize: _text2xl,
    fontWeight: fontSemibold,
    letterSpacing: -0.02,
    height: 1.3,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontSize: _textXl,
    fontWeight: fontSemibold,
    letterSpacing: -0.01,
    height: 1.35,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontSize: _textLg,
    fontWeight: fontMedium,
    letterSpacing: -0.01,
    height: 1.4,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontSize: _textBase,
    fontWeight: fontMedium,
    letterSpacing: -0.01,
    height: 1.4,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontSize: _textBase,
    fontWeight: fontMedium,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontSize: _textSm,
    fontWeight: fontMedium,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontSize: _textXs,
    fontWeight: fontMedium,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: _textBase,
    fontWeight: fontNormal,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: _textSm,
    fontWeight: fontNormal,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: _textXs,
    fontWeight: fontNormal,
    letterSpacing: 0.4,
    height: 1.5,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontSize: _textSm,
    fontWeight: fontMedium,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontSize: _textXs,
    fontWeight: fontMedium,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontSize: 11,
    fontWeight: fontMedium,
    letterSpacing: 0.5,
    height: 1.4,
  );
}
