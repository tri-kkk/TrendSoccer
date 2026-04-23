import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Narrative pitcher analysis copy (typically four paragraphs).
class PitcherAnalysisSection extends StatelessWidget {
  const PitcherAnalysisSection({
    super.key,
    required this.paragraphs,
  });

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTypography.bodySmall.copyWith(
      color: AppColors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pitcher Analysis',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < paragraphs.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                Text(
                  paragraphs[i],
                  style: bodyStyle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
