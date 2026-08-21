import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';

enum TsComboResult { inProgress, hit, miss }

class TsComboMatchRow extends StatelessWidget {
  const TsComboMatchRow({
    required this.homeTeam,
    required this.awayTeam,
    required this.timeLabel,
    required this.result,
    this.resultLabel,
    this.homeScore,
    this.awayScore,
    this.homeEmblemId,
    this.awayEmblemId,
    super.key,
  });

  final String homeTeam;
  final String awayTeam;
  final String timeLabel;
  final TsComboResult result;
  final String? resultLabel;
  final String? homeScore;
  final String? awayScore;
  final String? homeEmblemId;
  final String? awayEmblemId;

  String get _defaultResultLabel => switch (result) {
        TsComboResult.inProgress => 'In progress',
        TsComboResult.hit => 'Match',
        TsComboResult.miss => 'Mismatch',
      };

  TsBadgeTone get _resultTone => switch (result) {
        TsComboResult.inProgress => TsBadgeTone.neutral,
        TsComboResult.hit => TsBadgeTone.positive,
        TsComboResult.miss => TsBadgeTone.negative,
      };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final timeColor =
        result == TsComboResult.inProgress ? c.error : c.textTertiary;

    Widget emblem(String? id) => id != null
        ? TsLeagueIcon(id, size: 20)
        : TsIcon(TsIcons.imageNotSupported, size: 20, color: c.textTertiary);

    Widget teamRow({
      required String letter,
      required String? emblemId,
      required String name,
      required String? score,
    }) {
      return SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(
              width: 12,
              child: Text(
                letter,
                style: TsType.labelXsBold.copyWith(color: c.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: TsSpacing.sm),
            emblem(emblemId),
            const SizedBox(width: TsSpacing.sm),
            Expanded(
              child: Text(
                name,
                style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (score != null)
              SizedBox(
                width: 24,
                child: Text(
                  score,
                  style: TsType.tabular(
                    TsType.bodyMBold.copyWith(color: c.textPrimary),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                timeLabel,
                style: TsType.labelXsMedium.copyWith(color: timeColor),
              ),
            ),
            const SizedBox(width: TsSpacing.sm),
            TsBadge(
              label: resultLabel ?? _defaultResultLabel,
              tone: _resultTone,
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.xs),
        Column(
          children: [
            teamRow(
              letter: 'H',
              emblemId: homeEmblemId,
              name: homeTeam,
              score: homeScore,
            ),
            const SizedBox(height: TsSpacing.xs),
            teamRow(
              letter: 'A',
              emblemId: awayEmblemId,
              name: awayTeam,
              score: awayScore,
            ),
          ],
        ),
      ],
    );
  }
}
