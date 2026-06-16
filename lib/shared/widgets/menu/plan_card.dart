import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';
import 'package:trendsoccer/shared/widgets/menu/plan_benefit_row.dart';

enum PlanCardType { free, premium }

class PlanBenefitItem {
  const PlanBenefitItem({
    required this.text,
    this.isIncluded = true,
  });

  final String text;
  final bool isIncluded;
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.type,
    required this.benefits,
    super.key,
  });

  final PlanCardType type;
  final List<PlanBenefitItem> benefits;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final title = type == PlanCardType.free ? 'Free' : 'Premium';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              ),
              if (type == PlanCardType.premium) const TsBadge(type: TsBadgeType.premium),
            ],
          ),
          const SizedBox(height: TsSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < benefits.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.sm),
                PlanBenefitRow(
                  text: benefits[i].text,
                  isIncluded: benefits[i].isIncluded,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
