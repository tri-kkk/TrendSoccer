import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/widgets/ts_team_emblem.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsMatchRowStatus { scheduled, live, finished }

class TsMatchRow extends StatelessWidget {
  const TsMatchRow({
    required this.homeTeam,
    required this.awayTeam,
    required this.timeLabel,
    this.status = TsMatchRowStatus.scheduled,
    this.homeScore,
    this.awayScore,
    this.homeEmblemUrl,
    this.awayEmblemUrl,
    this.alarmOn,
    this.onAlarmTap,
    this.onTap,
    super.key,
  });

  final String homeTeam;
  final String awayTeam;
  final String timeLabel;
  final TsMatchRowStatus status;
  final String? homeScore;
  final String? awayScore;
  final String? homeEmblemUrl;
  final String? awayEmblemUrl;
  final bool? alarmOn;
  final VoidCallback? onAlarmTap;
  final VoidCallback? onTap;

  static const _rowMinHeight = 56.0;
  static const _statusColumnWidth = 56.0;
  static const _liveDotSize = 8.0;
  static const _statusColumnGap = 6.0;
  static const _scoreColumnWidth = 24.0;
  static const _alarmVisualSize = 20.0;
  static const _alarmTapTarget = 48.0;

  int? _parseScore(String? score) {
    if (score == null || score.isEmpty) return null;
    return int.tryParse(score);
  }

  TextStyle _scoreTextStyle(TsThemeColors c, {required bool isHome}) {
    final emphasized = TsType.tabular(
      TsType.bodyMBold.copyWith(color: c.textPrimary),
    );

    if (status != TsMatchRowStatus.finished) {
      return emphasized;
    }

    final home = _parseScore(homeScore);
    final away = _parseScore(awayScore);
    if (home == null || away == null || home == away) {
      return emphasized;
    }

    final isWinner = isHome ? home > away : away > home;
    if (isWinner) {
      return emphasized;
    }
    return TsType.tabular(
      TsType.bodyMMedium.copyWith(color: c.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final showScores =
        status == TsMatchRowStatus.live || status == TsMatchRowStatus.finished;
    final isLive = status == TsMatchRowStatus.live;

    Widget teamRow({
      required String? emblemUrl,
      required String name,
      required String? score,
      required bool isHome,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TsTeamEmblem(emblemUrl, size: TsIconSize.sm),
          const SizedBox(width: TsSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showScores)
            SizedBox(
              width: _scoreColumnWidth,
              child: Text(
                score ?? '',
                style: _scoreTextStyle(c, isHome: isHome),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      );
    }

    Widget statusColumn() {
      final timeStyle = TsType.labelSRegular.copyWith(
        color: isLive ? c.error : c.textTertiary,
      );

      return SizedBox(
        width: _statusColumnWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLive) ...[
              Container(
                width: _liveDotSize,
                height: _liveDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.error,
                ),
              ),
              const SizedBox(width: _statusColumnGap),
            ],
            Flexible(
              child: Text(
                timeLabel,
                style: timeStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget alarmSlot() {
      if (status == TsMatchRowStatus.finished || alarmOn == null) {
        return const SizedBox(
          width: _alarmVisualSize,
          height: _alarmVisualSize,
        );
      }

      return SizedBox(
        width: _alarmTapTarget,
        height: _alarmTapTarget,
        child: Center(
          child: GestureDetector(
            onTap: onAlarmTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: _alarmTapTarget,
              height: _alarmTapTarget,
              child: Center(
                child: TsIcon(
                  alarmOn! ? TsIcons.notifications : TsIcons.notificationsNone,
                  size: TsIconSize.sm,
                  color: alarmOn! ? c.primary : c.textTertiary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowMinHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            statusColumn(),
            const SizedBox(width: TsSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  teamRow(
                    emblemUrl: homeEmblemUrl,
                    name: homeTeam,
                    score: homeScore,
                    isHome: true,
                  ),
                  const SizedBox(height: TsSpacing.xs),
                  teamRow(
                    emblemUrl: awayEmblemUrl,
                    name: awayTeam,
                    score: awayScore,
                    isHome: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: TsSpacing.sm),
            alarmSlot(),
          ],
        ),
      ),
    );
  }
}
