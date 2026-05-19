import 'package:flutter/material.dart';

/// v2 primitive color tokens.
abstract final class TsColors {
  // Brand Primary (0~900)
  static const Color brandPrimary0 = Color(0xFFFFFFFF);
  static const Color brandPrimary50 = Color(0xFFEDFFF6);
  static const Color brandPrimary100 = Color(0xFFD4FFE8);
  static const Color brandPrimary200 = Color(0xFFA3FFCE);
  static const Color brandPrimary300 = Color(0xFF60F8AD);
  static const Color brandPrimary400 = Color(0xFF25EE8E);
  static const Color brandPrimary500 = Color(0xFF00DF81);
  static const Color brandPrimary600 = Color(0xFF00B567);
  static const Color brandPrimary700 = Color(0xFF008A4E);
  static const Color brandPrimary800 = Color(0xFF006237);
  static const Color brandPrimary900 = Color(0xFF003D22);

  // Brand Accent (0~900)
  static const Color brandAccent0 = Color(0xFFFFFFFF);
  static const Color brandAccent50 = Color(0xFFEDFCFF);
  static const Color brandAccent100 = Color(0xFFD0F7FF);
  static const Color brandAccent200 = Color(0xFFA3EFFF);
  static const Color brandAccent300 = Color(0xFF57E3FF);
  static const Color brandAccent400 = Color(0xFF1AD1FF);
  static const Color brandAccent500 = Color(0xFF00C2FF);
  static const Color brandAccent600 = Color(0xFF009ECC);
  static const Color brandAccent700 = Color(0xFF007A99);
  static const Color brandAccent800 = Color(0xFF005566);
  static const Color brandAccent900 = Color(0xFF003540);

  // Neutral (0~900)
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFFDFCFB);
  static const Color neutral100 = Color(0xFFF0EAE7);
  static const Color neutral200 = Color(0xFFE4DDD9);
  static const Color neutral300 = Color(0xFFD5CCC8);
  static const Color neutral400 = Color(0xFFB8ADAA);
  static const Color neutral500 = Color(0xFF9E8F89);
  static const Color neutral600 = Color(0xFF6B5E58);
  static const Color neutral700 = Color(0xFF4A3E3A);
  static const Color neutral800 = Color(0xFF2E2421);
  static const Color neutral900 = Color(0xFF1A1410);

  // Canvas (dark backgrounds)
  static const Color canvas0 = Color(0xFF0A0F0E);
  static const Color canvas100 = Color(0xFF131918);
  static const Color canvas200 = Color(0xFF1C2120);
  static const Color canvas300 = Color(0xFF212726);

  // OnCanvas (dark text)
  static const Color onCanvas0 = Color(0xFFF1F7F6);
  static const Color onCanvas100 = Color(0xFFAACBC4);
  static const Color onCanvas200 = Color(0xFF707D7D);
  static const Color onCanvas300 = Color(0xFF6B7280);

  // Analysis
  static const Color analysisPick500 = Color(0xFFEF4444);
  static const Color analysisGood500 = Color(0xFFFB923C);
  static const Color analysisPass500 = Color(0xFF6B7280);

  // Membership
  static const Color membershipPremium500 = Color(0xFF00DF81);
  static const Color membershipTrial500 = Color(0xFF8B5CF6);
  static const Color membershipFree500 = Color(0xFF6B7280);

  // System
  static const Color systemSuccess500 = Color(0xFF10B981);
  static const Color systemError500 = Color(0xFFEF4444);
  static const Color systemWarning500 = Color(0xFFF59E0B);

  /// Alias for error emphasis (same as [systemError500]).
  static const Color error500 = systemError500;
}
