import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/icons/sports_icon.dart';

class SportsToggle extends StatelessWidget {
  const SportsToggle({
    required this.selectedSport,
    required this.onChanged,
    super.key,
  });

  final SportType selectedSport;
  final ValueChanged<SportType> onChanged;

  static String _label(AppLocalizations l10n, SportType sport) {
    return switch (sport) {
      SportType.soccer => l10n.sportSoccer,
      SportType.baseball => l10n.sportBaseball,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    Widget segment(SportType sport) {
      final selected = selectedSport == sport;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(sport),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(
              horizontal: TsSpacing.lg,
              vertical: TsSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? semantic.textPrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TsSportsIcon(
                  sport: sport,
                  fill: SportsIconFill.primary,
                  size: 24,
                  color: selected
                      ? semantic.surfaceBase
                      : semantic.textPrimary,
                ),
                const SizedBox(width: TsSpacing.sm),
                Text(
                  _label(l10n, sport),
                  style: TsType.bodyLBold.copyWith(
                    color: selected
                        ? semantic.surfaceBase
                        : semantic.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Container(
        padding: const EdgeInsets.all(TsSpacing.xs),
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            segment(SportType.soccer),
            const SizedBox(width: TsSpacing.xs),
            segment(SportType.baseball),
          ],
        ),
      ),
    );
  }
}
