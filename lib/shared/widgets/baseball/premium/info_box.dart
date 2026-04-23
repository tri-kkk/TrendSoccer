import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Premium baseball stat tile (e.g. win % with optional away/home line).
class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.label,
    required this.stats,
    this.team,
    required this.isAway,
  });

  /// Top caption (e.g. `'Win %'`, `'Away Win'`).
  final String label;

  /// Main value (e.g. `'60.5%'`, `'45%'`).
  final String stats;

  /// Optional third line (e.g. `'Away'`, `'Home'`).
  final String? team;

  /// `true` → [AppColors.errorRed500] for [stats]; `false` → [AppColors.primary500].
  final bool isAway;

  @override
  Widget build(BuildContext context) {
    final tertiarySmall = AppTypography.labelSmall.copyWith(
      color: AppColors.textTertiary,
    );
    final statsStyle = AppTypography.headlineSmall.copyWith(
      fontWeight: FontWeight.w700,
      color: isAway ? AppColors.errorRed500 : AppColors.primary500,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: tertiarySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stats,
            textAlign: TextAlign.center,
            style: statsStyle,
          ),
          if (team != null && team!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              team!,
              textAlign: TextAlign.center,
              style: tertiarySmall,
            ),
          ],
        ],
      ),
    );
  }
}
