import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/fixture_models.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import 'fixture_status_widget.dart';
import 'fixture_team_row.dart';

/// One fixture: status column (56px) + home/away [FixtureTeamRow]s, 8px between rows.
class FixtureMatchRow extends StatelessWidget {
  const FixtureMatchRow({
    super.key,
    required this.match,
    this.onTap,
  });

  final FixtureMatch match;
  final VoidCallback? onTap;

  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final status = match.status.toLowerCase();
    final timeText = _timeFormat.format(match.matchDateTime);
    final showScores = status == 'live' || status == 'finished';

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FixtureStatusWidget(
          status: match.status,
          time: timeText,
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FixtureTeamRow(
                teamName: match.homeTeam.name,
                logoUrl: match.homeTeam.logoUrl,
                score: showScores ? match.homeScore : null,
                isHome: true,
              ),
              const SizedBox(height: AppSpacing.md),
              FixtureTeamRow(
                teamName: match.awayTeam.name,
                logoUrl: match.awayTeam.logoUrl,
                score: showScores ? match.awayScore : null,
                isHome: false,
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
