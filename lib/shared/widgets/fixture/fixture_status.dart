import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum FixtureMatchStatus { scheduled, live, finished }

class FixtureStatus extends StatelessWidget {
  const FixtureStatus({
    required this.status,
    this.timeText,
    super.key,
  });

  final FixtureMatchStatus status;
  final String? timeText;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      width: 56,
      child: switch (status) {
        FixtureMatchStatus.scheduled => Center(
            child: Text(
              timeText ?? 'HH:MM',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        FixtureMatchStatus.live => Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: TsColors.systemError500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: TsSpacing.sm),
                Text(
                  'LIVE',
                  style: TsType.labelSRegular.copyWith(color: TsColors.systemError500),
                ),
              ],
            ),
          ),
        FixtureMatchStatus.finished => Center(
            child: Text(
              timeText ?? 'FT',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
      },
    );
  }
}
