import 'dart:ui';

/// Design tokens extracted from Figma design system.
/// All values are actual Figma-measured hex codes.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────
  // Brand / Primary — Teal/Emerald 10-step
  // ──────────────────────────────────────────────
  static const Color primary50 = Color(0xFFE8F5F1);
  static const Color primary100 = Color(0xFFC7E8E0);
  static const Color primary200 = Color(0xFF8FD4C0);
  static const Color primary300 = Color(0xFF57BFA0);
  static const Color primary400 = Color(0xFF3BAA88);
  static const Color primary500 = Color(0xFF1F9A7A); // main brand color
  static const Color primary600 = Color(0xFF1A7A61);
  static const Color primary700 = Color(0xFF145948);
  static const Color primary800 = Color(0xFF0F4336);
  static const Color primary900 = Color(0xFF03624C);

  // ──────────────────────────────────────────────
  // Brand / Accent — Neon Green (Live, Highlight용)
  // ──────────────────────────────────────────────
  static const Color accent = Color(0xFF00DF81);

  // ──────────────────────────────────────────────
  // Semantic — Analysis / Pick (Red) 5-step
  // ──────────────────────────────────────────────
  static const Color pickRed100 = Color(0xFFFEE2E2);
  static const Color pickRed300 = Color(0xFFFCA5A5);
  static const Color pickRed500 = Color(0xFFEF4444);
  static const Color pickRed700 = Color(0xFFB91C1C);
  static const Color pickRed900 = Color(0xFF7F1D1D);

  // ──────────────────────────────────────────────
  // Semantic — Analysis / Good (Orange) 5-step
  // ──────────────────────────────────────────────
  static const Color goodOrange100 = Color(0xFFFFEDD5);
  static const Color goodOrange300 = Color(0xFFFDBA74);
  static const Color goodOrange500 = Color(0xFFFB923C); // GOOD 배지
  static const Color goodOrange700 = Color(0xFFC2410C);
  static const Color goodOrange900 = Color(0xFF7C2D12);

  // ──────────────────────────────────────────────
  // Semantic — Analysis / Pass (Gray) 5-step
  // ──────────────────────────────────────────────
  static const Color passGray100 = Color(0xFFF3F4F6);
  static const Color passGray300 = Color(0xFFD1D5DB);
  static const Color passGray500 = Color(0xFF6B7280);
  static const Color passGray700 = Color(0xFF374151);
  static const Color passGray900 = Color(0xFF111827);

  // ──────────────────────────────────────────────
  // Semantic — Membership / Premium (Neon Teal) 3-step
  // ──────────────────────────────────────────────
  static const Color premiumTeal300 = Color(0xFF4DFFB8);
  static const Color premiumTeal500 = Color(0xFF00DF81); // 프리미엄 배지
  static const Color premiumTeal700 = Color(0xFF00A861);

  // ──────────────────────────────────────────────
  // Semantic — Membership / Trial (Purple) 3-step
  // ──────────────────────────────────────────────
  static const Color trialPurple300 = Color(0xFFC4B5FD);
  static const Color trialPurple500 = Color(0xFF8B5CF6); // 체험 배지
  static const Color trialPurple700 = Color(0xFF6D28D9);

  // ──────────────────────────────────────────────
  // Semantic — Membership / Free (Gray)
  // ──────────────────────────────────────────────
  static const Color freeGray500 = Color(0xFF6B7280);

  // ──────────────────────────────────────────────
  // Semantic — System / Success (Green) 3-step
  // ──────────────────────────────────────────────
  static const Color successGreen300 = Color(0xFF6EE7B7);
  static const Color successGreen500 = Color(0xFF10B981); // 성공 메시지
  static const Color successGreen700 = Color(0xFF047857);

  // ──────────────────────────────────────────────
  // Semantic — System / Error (Red) 3-step
  // ──────────────────────────────────────────────
  static const Color errorRed300 = Color(0xFFFCA5A5);
  static const Color errorRed500 = Color(0xFFEF4444);
  static const Color errorRed700 = Color(0xFFB91C1C);

  // ──────────────────────────────────────────────
  // Semantic — System / Warning (Amber) 3-step
  // ──────────────────────────────────────────────
  static const Color warningAmber300 = Color(0xFFFCD34D);
  static const Color warningAmber500 = Color(0xFFF59E0B);
  static const Color warningAmber700 = Color(0xFFD97706);

  // ──────────────────────────────────────────────
  // Surface — Dark Mode 4-step
  // ──────────────────────────────────────────────
  static const Color surfaceBase = Color(0xFF0A0F0E);
  static const Color surfaceRaised = Color(0xFF131918);
  static const Color surfaceOverlay = Color(0xFF1C2120);
  static const Color surfaceContainer = Color(0xFF212726);

  // ──────────────────────────────────────────────
  // Text — Dark Mode 4-step
  // ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F7F6);
  static const Color textSecondary = Color(0xFFAACBC4);
  static const Color textTertiary = Color(0xFF707D7D);
  static const Color textDisabled = Color(0xFF6B7280);
}
