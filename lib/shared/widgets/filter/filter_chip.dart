import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../league/league_icon.dart';

/// A pill-shaped chip for filtering content by league or category.
///
/// Supports two visual states via [isSelected]:
/// - **selected**: brand primary background with dark text.
/// - **unselected**: container background with secondary text.
///
/// When [leagueCode] is provided, a [LeagueIcon] is rendered before the label.
///
/// Layout follows Figma node `624:21568`.
///
/// ```dart
/// SportFilterChip(label: 'All', isSelected: true, onTap: () {})
///
/// SportFilterChip(
///   label: 'Europa League',
///   leagueCode: 'UEL',
///   isSelected: false,
///   onTap: () {},
/// )
/// ```
class SportFilterChip extends StatelessWidget {
  const SportFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.leagueCode,
    this.onTap,
  });

  /// Display text inside the chip.
  final String label;

  /// Whether this chip is currently active.
  final bool isSelected;

  /// Optional league code for the leading icon (e.g. `'EPL'`, `'KBO'`).
  /// When `null`, only the label text is shown.
  final String? leagueCode;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isSelected ? AppColors.primary500 : AppColors.surfaceContainer;
    final textColor =
        isSelected ? AppColors.surfaceBase : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leagueCode != null) ...[
              LeagueIcon(league: leagueCode!, size: 16),
              const SizedBox(width: AppSpacing.md),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
