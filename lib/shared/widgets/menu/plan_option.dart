import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/radio/ts_radio_button.dart';

enum PlanOptionType { oneMonth, threeMonth }

class PlanOption extends StatelessWidget {
  const PlanOption({
    required this.type,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final PlanOptionType type;
  final bool isSelected;
  final VoidCallback? onTap;

  String get _price => type == PlanOptionType.oneMonth ? '￦ 4,900' : '￦ 9,900';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final period = type == PlanOptionType.oneMonth
        ? l10n.subscribePlanMonthly
        : l10n.subscribePlanQuarterly;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x3300DF81) : semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: semantic.interactivePrimary, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TsRadioButton(selected: isSelected, onChanged: null),
                const SizedBox(width: TsSpacing.lg),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _price,
                      style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Text(
                      period,
                      style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
            if (type == PlanOptionType.threeMonth) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x3300DF81),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '33% OFF',
                  style: TsType.bodyMBold.copyWith(color: semantic.interactivePrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
