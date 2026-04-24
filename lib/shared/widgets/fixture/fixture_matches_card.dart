import 'package:flutter/material.dart';

import '../../../core/models/fixture_models.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import 'fixture_match_row.dart';

/// Match list only — [AppColors.surfaceContainer] panel (Figma: separate from header).
class FixtureMatchesCard extends StatelessWidget {
  const FixtureMatchesCard({
    super.key,
    required this.matches,
    this.onMatchTap,
  });

  final List<FixtureMatch> matches;
  final void Function(FixtureMatch match)? onMatchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < matches.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            FixtureMatchRow(
              match: matches[i],
              onTap: onMatchTap == null
                  ? null
                  : () => onMatchTap!(matches[i]),
            ),
          ],
        ],
      ),
    );
  }
}
