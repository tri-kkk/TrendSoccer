import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/icons/sports_icon.dart';

class PremiumPickCard extends StatelessWidget {
  const PremiumPickCard({
    this.showCTA = true,
    required this.winRate,
    required this.countdown,
    required this.streak,
    required this.recentHomeTeam,
    required this.recentAwayTeam,
    required this.recentPick,
    this.onCTATap,
    super.key,
  });

  final bool showCTA;
  final String winRate;
  final String countdown;
  final String streak;
  final String recentHomeTeam;
  final String recentAwayTeam;
  final PickDirection recentPick;
  final VoidCallback? onCTATap;

  static const Color _winBadgeBackground = Color(0x3310B981);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    Widget teamLogoPlaceholder() {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: semantic.interactivePrimary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TsSportsIcon(
                sport: SportType.soccer,
                fill: SportsIconFill.primary,
                size: 24,
              ),
              const SizedBox(width: TsSpacing.sm),
              Text(
                '오늘의 추천 경기',
                style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Container(
            padding: const EdgeInsets.all(TsSpacing.sm),
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          recentHomeTeam,
                          style: TsType.labelSRegular.copyWith(
                            color: semantic.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.xs),
                      teamLogoPlaceholder(),
                      const SizedBox(width: TsSpacing.xs),
                      Text(
                        'VS',
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.textTertiary,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.xs),
                      teamLogoPlaceholder(),
                      const SizedBox(width: TsSpacing.xs),
                      Expanded(
                        child: Text(
                          recentAwayTeam,
                          style: TsType.labelSRegular.copyWith(
                            color: semantic.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PickDirectionBadge(pick: recentPick),
                    const SizedBox(width: TsSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TsSpacing.sm,
                        vertical: TsSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _winBadgeBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'WIN',
                        style: TsType.labelSBold.copyWith(
                          color: TsColors.systemSuccess500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: winRate,
                  label: '적중률',
                  valueColor: semantic.interactivePrimary,
                  semantic: semantic,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Container(
                width: 1,
                height: 40,
                color: semantic.textDisabled,
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: _StatCell(
                  value: countdown,
                  label: '다음 업데이트',
                  valueColor: semantic.textPrimary,
                  semantic: semantic,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Container(
                width: 1,
                height: 40,
                color: semantic.textDisabled,
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: _StatCell(
                  value: streak,
                  label: '연속 적중',
                  valueColor: semantic.interactivePrimary,
                  semantic: semantic,
                ),
              ),
            ],
          ),
          if (showCTA) ...[
            const SizedBox(height: TsSpacing.lg),
            Container(
              height: 1,
              color: semantic.borderSubtle,
            ),
            const SizedBox(height: TsSpacing.lg),
            TsButton(
              label: '오늘의 픽 확인하기 →',
              variant: TsButtonVariant.primary,
              onPressed: onCTATap,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.semantic,
  });

  final String value;
  final String label;
  final Color valueColor;
  final TsSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TsType.headingH1.copyWith(color: valueColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.xs),
        Text(
          label,
          style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
