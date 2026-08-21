import 'package:flutter/material.dart';

abstract final class TsType {
  static const String _fontFamily = 'Poppins';
  static const List<String> _fontFamilyFallback = ['Pretendard'];

  static const TextStyle displayLg = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 36,
    height: 40 / 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.72,
  );

  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.72,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 24,
    height: 29 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.20,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.08,
  );

  static const TextStyle bodyLRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle bodyLMedium = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const TextStyle bodyLBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle bodyMRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle bodyMMedium = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const TextStyle bodyMBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle labelSRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.11,
  );

  static const TextStyle labelSMedium = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.11,
  );

  static const TextStyle labelSBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.11,
  );

  static const TextStyle labelXsRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.18,
  );

  static const TextStyle labelXsMedium = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.18,
  );

  static const TextStyle labelXsBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.18,
  );

  static TextStyle tabular(TextStyle s) =>
      s.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
