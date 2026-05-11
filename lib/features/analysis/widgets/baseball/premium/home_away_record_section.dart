import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '홈/원정 기록',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              '최근 10경기',
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
                  label: '원정 기록',
                  value: awayRecord,
                  teamName: awayTeam,
                  valueColor: TsColors.systemError500,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: BaseballInfoBox(
                  label: '홈 기록',
                  value: homeRecord,
                  teamName: homeTeam,
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
