import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
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

  static String _label(SportType sport) {
    return switch (sport) {
      SportType.soccer => '축구',
      SportType.baseball => '야구',
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

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
                  ? semantic.interactivePrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TsSportsIcon(
                  sport: sport,
                  fill: selected
                      ? SportsIconFill.onPrimary
                      : SportsIconFill.primary,
                  size: 24,
                ),
                const SizedBox(width: TsSpacing.sm),
                Text(
                  _label(sport),
                  style: TsType.bodyLBold.copyWith(
                    color: selected
                        ? semantic.surfaceBase
                        : semantic.textSecondary,
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
