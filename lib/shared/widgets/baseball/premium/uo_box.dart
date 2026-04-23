import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Over / Under percentage tile for premium baseball O/U.
class UoBox extends StatelessWidget {
  const UoBox({
    super.key,
    required this.label,
    required this.stats,
    required this.isFavored,
  });

  final String label;
  final String stats;

  /// `true` → accent tint + border; `false` → [AppColors.surfaceContainer].
  final bool isFavored;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textTertiary,
    );
    final statsStyle = AppTypography.headlineSmall.copyWith(
      fontWeight: FontWeight.w700,
      color: isFavored ? AppColors.accent : AppColors.textPrimary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isFavored
            ? const Color.fromRGBO(0, 223, 129, 0.2)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isFavored
            ? Border.all(color: AppColors.accent, width: 1)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stats,
            textAlign: TextAlign.center,
            style: statsStyle,
          ),
        ],
      ),
    );
  }
}
