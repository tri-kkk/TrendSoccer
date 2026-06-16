import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class TodayPickCard extends StatelessWidget {
  const TodayPickCard({
    required this.pickCount,
    required this.updateTime,
    this.onTap,
    super.key,
  });

  final int pickCount;
  final String updateTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: semantic.interactivePrimary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Today's Premium Pick",
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.lg),
          Container(
            height: 1,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.lg),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.cardPickCount,
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.textTertiary,
                        ),
                      ),
                      const SizedBox(height: TsSpacing.xs),
                      Text(
                        '$pickCount',
                        style: TsType.headingH2.copyWith(
                          color: semantic.textPrimary,
                        ),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.cardUpdateLabel,
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.textTertiary,
                        ),
                      ),
                      const SizedBox(height: TsSpacing.xs),
                      Text(
                        updateTime,
                        style: TsType.headingH2.copyWith(
                          color: semantic.interactivePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Container(
            height: 1,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: l10n.cardCheckPickShort,
            variant: TsButtonVariant.secondary,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
