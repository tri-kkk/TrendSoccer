import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/baseball_info_box.dart';

class HomeAwayRecordSection extends StatelessWidget {
  const HomeAwayRecordSection({
    required this.awayRecord,
    required this.homeRecord,
    required this.awayTeam,
    required this.homeTeam,
    super.key,
  });

  final String awayRecord;
  final String homeRecord;
  final String awayTeam;
  final String homeTeam;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.baseballHomeAwayRecord,
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              l10n.baseballRecent10,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: BaseballInfoBox(
                  label: l10n.labelAway,
                  value: awayRecord,
                  valueColor: TsColors.systemError500,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: BaseballInfoBox(
                  label: l10n.labelHome,
                  value: homeRecord,
                  valueColor: semantic.interactivePrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
