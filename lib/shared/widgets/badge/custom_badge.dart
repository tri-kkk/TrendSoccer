import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Badge types used across the TrendSoccer app.
///
/// Analysis badges: [pick], [good], [pass].
/// Membership badges: [premium], [trial], [free].
enum BadgeType { pick, good, pass, premium, trial, free }

/// A compact badge that displays a [label] with color-coded background
/// based on [BadgeType].
///
/// ```dart
/// CustomBadge(type: BadgeType.pick, label: 'PICK')
/// CustomBadge(type: BadgeType.premium, label: 'Premium')
/// ```
class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.type,
    required this.label,
  });

  /// Determines the color scheme applied to the badge.
  final BadgeType type;

  /// Text content displayed inside the badge.
  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  static (Color, Color) _colors(BadgeType type) => switch (type) {
        BadgeType.pick => (AppColors.pickRed500, Colors.white),
        BadgeType.good => (AppColors.goodOrange500, Colors.white),
        BadgeType.pass => (AppColors.passGray500, Colors.white),
        BadgeType.premium => (AppColors.premiumTeal500, AppColors.surfaceBase),
        BadgeType.trial => (AppColors.trialPurple500, Colors.white),
        BadgeType.free => (AppColors.freeGray500, AppColors.textPrimary),
      };
}
