import 'package:flutter/material.dart';

/// v2 typography. Apply color via [TextStyle.copyWith] on widgets.
/// Fonts are bundled separately (Poppins + Pretendard).
abstract final class TsType {
  static const String _fontFamily = 'Poppins';
  static const List<String> _fontFamilyFallback = ['Pretendard'];

  static const TextStyle displayHero = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.72,
  );

  static const TextStyle headingH1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 29 / 24,
    letterSpacing: -0.24,
  );

  static const TextStyle headingH2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
    letterSpacing: -0.20,
  );

  static const TextStyle headingH3 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 21 / 16,
    letterSpacing: -0.08,
  );

  static const TextStyle bodyLBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static const TextStyle bodyLRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 21 / 14,
    letterSpacing: 0,
  );

  static const TextStyle bodyMBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 17 / 12,
    letterSpacing: 0,
  );

  static const TextStyle bodyMRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );

  static const TextStyle labelSBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 15 / 11,
    letterSpacing: 0.11,
  );

  static const TextStyle labelSRegular = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 17 / 11,
    letterSpacing: 0.11,
  );

  static const TextStyle labelXsBold = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 11 / 9,
    letterSpacing: 0.18,
  );
}
