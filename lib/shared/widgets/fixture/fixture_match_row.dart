import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_team_row.dart';
import 'package:trendsoccer/shared/widgets/fixture/notification_icon.dart';

class FixtureMatchRow extends StatelessWidget {
  const FixtureMatchRow({
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    this.timeText,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.homeScore,
    this.awayScore,
    this.showNotification = true,
    this.isNotificationOn = false,
    this.onNotificationTap,
    this.scoreChangeAt,
    super.key,
  });

  final FixtureMatchStatus status;
  final String? timeText;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String? homeScore;
  final String? awayScore;
  final bool showNotification;
  final bool isNotificationOn;
  final VoidCallback? onNotificationTap;
  final DateTime? scoreChangeAt;

  Widget _trailingNotification() {
    final icon = NotificationIcon(
      isOn: isNotificationOn,
      onTap: onNotificationTap,
    );
    if (onNotificationTap == null) {
      return Opacity(opacity: 0, child: icon);
    }
    if (!showNotification) {
      return const SizedBox(width: 24, height: 24);
    }
    return icon;
  }

  int? _parseScore(String? score) => int.tryParse(score ?? '');

  TextStyle _scoreTextStyle({
    required BuildContext context,
    required bool isHome,
  }) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final defaultStyle =
        TsType.labelSRegular.copyWith(color: semantic.textPrimary);

    if (status != FixtureMatchStatus.finished) {
      return defaultStyle;
    }

    final home = _parseScore(homeScore);
    final away = _parseScore(awayScore);
    if (home == null || away == null) {
      return defaultStyle;
    }

    if (home == away) {
      return TsType.bodyLBold.copyWith(color: semantic.textPrimary);
    }

    final isWinner = isHome ? home > away : away > home;
    if (isWinner) {
      return TsType.bodyLBold.copyWith(color: semantic.textPrimary);
    }
    return TsType.bodyLRegular.copyWith(color: semantic.textTertiary);
  }

  Widget _buildRowContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FixtureStatus(status: status, timeText: timeText),
        const SizedBox(width: TsSpacing.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FixtureTeamRow(
                teamName: homeTeam,
                teamLogoUrl: homeLogoUrl,
                score: homeScore,
                scoreStyle: _scoreTextStyle(context: context, isHome: true),
              ),
              const SizedBox(height: TsSpacing.sm),
              FixtureTeamRow(
                teamName: awayTeam,
                teamLogoUrl: awayLogoUrl,
                score: awayScore,
                scoreStyle: _scoreTextStyle(context: context, isHome: false),
              ),
            ],
          ),
        ),
        const SizedBox(width: TsSpacing.lg),
        _trailingNotification(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = _buildRowContent(context);
    final changeAt = scoreChangeAt;
    if (changeAt == null) return row;

    return TweenAnimationBuilder<double>(
      key: ValueKey(changeAt),
      tween: Tween<double>(begin: 1, end: 0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: TsColors.brandPrimary500.withValues(alpha: value * 0.15),
            borderRadius: BorderRadius.circular(TsSpacing.sm),
          ),
          child: child,
        );
      },
      child: row,
    );
  }
}
