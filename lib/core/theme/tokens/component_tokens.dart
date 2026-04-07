import 'package:flutter/material.dart';

import 'color_tokens.dart';

// ──────────────────────────────────────────────
// Enums matching Figma component variants
// ──────────────────────────────────────────────

enum CheckboxState { unchecked, partial, checked }

enum RadioState { checked, unchecked }

enum ToggleState { on, off }

enum ButtonVariant { primary, secondary }

enum ButtonState { enabled, disabled }

enum NavigationTab { trend, analysis, fixture, report, menu }

// ──────────────────────────────────────────────
// Navigation tab metadata
// ──────────────────────────────────────────────

extension NavigationTabX on NavigationTab {
  String get label {
    switch (this) {
      case NavigationTab.trend:
        return 'Trend';
      case NavigationTab.analysis:
        return 'Analysis';
      case NavigationTab.fixture:
        return 'Fixture';
      case NavigationTab.report:
        return 'Report';
      case NavigationTab.menu:
        return 'Menu';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationTab.trend:
        return Icons.home_outlined;
      case NavigationTab.analysis:
        return Icons.analytics_outlined;
      case NavigationTab.fixture:
        return Icons.calendar_today_outlined;
      case NavigationTab.report:
        return Icons.article_outlined;
      case NavigationTab.menu:
        return Icons.menu;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case NavigationTab.trend:
        return Icons.home;
      case NavigationTab.analysis:
        return Icons.analytics;
      case NavigationTab.fixture:
        return Icons.calendar_today;
      case NavigationTab.report:
        return Icons.article;
      case NavigationTab.menu:
        return Icons.menu;
    }
  }
}

// ──────────────────────────────────────────────
// Button style resolver
// ──────────────────────────────────────────────

class ButtonTokens {
  ButtonTokens._();

  static Color backgroundColor(ButtonVariant variant, ButtonState state) {
    if (state == ButtonState.disabled) {
      return variant == ButtonVariant.primary
          ? AppColors.primary500.withAlpha(97)
          : AppColors.surfaceContainer.withAlpha(97);
    }
    return variant == ButtonVariant.primary
        ? AppColors.primary500
        : AppColors.surfaceContainer;
  }

  static Color foregroundColor(ButtonVariant variant, ButtonState state) {
    if (state == ButtonState.disabled) return AppColors.textDisabled;
    return variant == ButtonVariant.primary
        ? AppColors.textPrimary
        : AppColors.primary400;
  }
}

// ──────────────────────────────────────────────
// Analysis result color resolver
// ──────────────────────────────────────────────

enum AnalysisGrade { pick, good, pass }

class AnalysisTokens {
  AnalysisTokens._();

  static Color color(AnalysisGrade grade) {
    switch (grade) {
      case AnalysisGrade.pick:
        return AppColors.pickRed500;
      case AnalysisGrade.good:
        return AppColors.goodOrange500;
      case AnalysisGrade.pass:
        return AppColors.passGray500;
    }
  }
}

// ──────────────────────────────────────────────
// Membership tier color resolver
// ──────────────────────────────────────────────

enum MembershipTier { premium, trial, free }

class MembershipTokens {
  MembershipTokens._();

  static Color color(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.premium:
        return AppColors.premiumTeal500;
      case MembershipTier.trial:
        return AppColors.trialPurple500;
      case MembershipTier.free:
        return AppColors.freeGray500;
    }
  }
}
