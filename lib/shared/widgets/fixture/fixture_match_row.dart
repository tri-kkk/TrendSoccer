import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
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

  @override
  Widget build(BuildContext context) {
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
              ),
              const SizedBox(height: TsSpacing.sm),
              FixtureTeamRow(
                teamName: awayTeam,
                teamLogoUrl: awayLogoUrl,
                score: awayScore,
              ),
            ],
          ),
        ),
        const SizedBox(width: TsSpacing.lg),
        _trailingNotification(),
      ],
    );
  }
}
