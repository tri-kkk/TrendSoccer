import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens extracted from Figma.
/// - English: Poppins
/// - Korean fallback: Pretendard
///
/// Naming: {category}{Size} — fontSize/lineHeight . letterSpacing
class AppTypography {
  AppTypography._();

  static const _fallback = ['Pretendard'];

  // ──────────────────────────────────────────────
  // Display
  // ──────────────────────────────────────────────

  /// Display Large — Poppins 57/64, letterSpacing -0.25
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 64 / 57,
    letterSpacing: -0.25,
    fontFamilyFallback: _fallback,
  );

  /// Display Medium — Poppins 45/52, letterSpacing 0
  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 52 / 45,
    letterSpacing: 0,
    fontFamilyFallback: _fallback,
  );

  /// Display Small — Poppins 36/44, letterSpacing 0
  static TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 44 / 36,
    letterSpacing: 0,
    fontFamilyFallback: _fallback,
  );

  // ──────────────────────────────────────────────
  // Headline
  // ──────────────────────────────────────────────

  /// Headline Large — Poppins 32/40, letterSpacing 0
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    letterSpacing: 0,
    fontFamilyFallback: _fallback,
  );

  /// Headline Medium — Poppins 28/36, letterSpacing 0
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28,
    letterSpacing: 0,
    fontFamilyFallback: _fallback,
  );

  /// Headline Small — Poppins 24/32, letterSpacing 0
  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24,
    letterSpacing: 0,
    fontFamilyFallback: _fallback,
  );

  // ──────────────────────────────────────────────
  // Title
  // ──────────────────────────────────────────────

  /// Title Large — Poppins Regular 22/28, letterSpacing 0
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 28 / 22,
    letterSpacing: 0,
    fontFamilyFallback: _fallback,
  );

  /// Title Medium — Poppins Medium 16/24, letterSpacing +0.15
  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0.15,
    fontFamilyFallback: _fallback,
  );

  /// Title Small — Poppins Medium 14/20, letterSpacing +0.1
  static TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontFamilyFallback: _fallback,
  );

  // ──────────────────────────────────────────────
  // Label
  // ──────────────────────────────────────────────

  /// Label Large — Poppins Medium 14/20, letterSpacing +0.1
  static TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
    fontFamilyFallback: _fallback,
  );

  /// Label Medium — Poppins Medium 12/16, letterSpacing +0.5
  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.5,
    fontFamilyFallback: _fallback,
  );

  /// Label Small — Poppins Medium 11/16, letterSpacing +0.5
  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.5,
    fontFamilyFallback: _fallback,
  );

  // ──────────────────────────────────────────────
  // Body
  // ──────────────────────────────────────────────

  /// Body Large — Poppins 16/24, letterSpacing +0.5
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.5,
    fontFamilyFallback: _fallback,
  );

  /// Body Medium — Poppins 14/20, letterSpacing +0.25
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontFamilyFallback: _fallback,
  );

  /// Body Small — Poppins 12/16, letterSpacing +0.4
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    fontFamilyFallback: _fallback,
  );
}
