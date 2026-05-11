import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_date_chip.dart';

class ComboDashboard extends StatelessWidget {
  const ComboDashboard({
    required this.dateTitle,
    required this.comboCountText,
    required this.dateTabs,
    required this.selectedDateIndex,
    required this.onDateSelected,
    required this.comboCount,
    required this.accuracy,
    required this.avgOdds,
    required this.safeHitRate,
    required this.safeHitDetail,
    required this.highOddsHitRate,
    required this.highOddsHitDetail,
    super.key,
  });

  final String dateTitle;
  final String comboCountText;
  final List<String> dateTabs;
  final int selectedDateIndex;
  final ValueChanged<int> onDateSelected;
  final int comboCount;
  final String accuracy;
  final String avgOdds;
  final String safeHitRate;
  final String safeHitDetail;
  final String highOddsHitRate;
  final String highOddsHitDetail;

  static const Color _safeBg = Color(0x0F00DF81);
  static const Color _safeBorder = Color(0x2600DF81);
  static const Color _highBg = Color(0x0FF59E0B);
  static const Color _highBorder = Color(0x26F59E0B);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  dateTitle,
                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Flexible(
                child: Text(
                  comboCountText,
                  style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.md),
          SizedBox(
            height: 23,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dateTabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: TsSpacing.sm),
              itemBuilder: (context, index) {
                return ComboDateChip(
                  label: dateTabs[index],
                  isActive: index == selectedDateIndex,
                  onTap: () => onDateSelected(index),
                );
              },
            ),
          ),
          const SizedBox(height: TsSpacing.md),
          Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TsSpacing.md),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '조합 수',
                        style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                      ),
                      Text(
                        '$comboCount',
                        style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TsSpacing.md),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '정합도',
                        style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                      ),
                      Text(
                        accuracy,
                        style: TsType.headingH2.copyWith(color: semantic.interactivePrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TsSpacing.md),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '평균 배당',
                        style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                      ),
                      Text(
                        avgOdds,
                        style: TsType.headingH2.copyWith(color: TsColors.systemWarning500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TsSpacing.md),
                  decoration: BoxDecoration(
                    color: _safeBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _safeBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: semantic.interactivePrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: TsSpacing.sm),
                          Text(
                            '안전형',
                            style: TsType.labelSBold.copyWith(color: semantic.textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            safeHitRate,
                            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                          ),
                          const SizedBox(width: TsSpacing.sm),
                          Text(
                            safeHitDetail,
                            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TsSpacing.md),
                  decoration: BoxDecoration(
                    color: _highBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _highBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: TsColors.systemWarning500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: TsSpacing.sm),
                          Text(
                            '고배당',
                            style: TsType.labelSBold.copyWith(color: semantic.textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            highOddsHitRate,
                            style: TsType.headingH3.copyWith(color: TsColors.systemWarning500),
                          ),
                          const SizedBox(width: TsSpacing.sm),
                          Text(
                            highOddsHitDetail,
                            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
