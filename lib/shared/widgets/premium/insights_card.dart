import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A card that renders a list of insight strings, one per row.
///
/// ```dart
/// InsightsCard(
///   insights: [
///     "Team Insights text",
///     "Team Insights text",
///     "Team Insights text",
///   ],
/// )
/// ```
class InsightsCard extends StatelessWidget {
  const InsightsCard({
    super.key,
    required this.insights,
  });

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minWidth: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: insights
            .map(
              (text) => Text(
                text,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            )
            .toList(),
      ),
    );
  }
}
