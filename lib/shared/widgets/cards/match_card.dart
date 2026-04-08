import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Current state of a match.
enum MatchStatus { scheduled, live, finished }

/// A card displaying a single match with league, teams, score and status.
///
/// The visual layout adapts based on [status]:
/// - **scheduled** — shows a dash between team names.
/// - **live / finished** — shows the numeric score between teams.
/// - **live** — renders [statusText] in red to draw attention.
///
/// ```dart
/// MatchCard(
///   league: 'Premier League',
///   homeTeam: 'Chelsea',
///   awayTeam: 'Arsenal',
///   status: MatchStatus.live,
///   statusText: "Live 82'",
///   homeScore: 2,
///   awayScore: 1,
/// )
/// ```
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    required this.statusText,
    this.homeScore,
    this.awayScore,
  });

  /// Name of the league or competition (e.g. "Premier League").
  final String league;

  /// Home team name.
  final String homeTeam;

  /// Away team name.
  final String awayTeam;

  /// Determines how score and status are rendered.
  final MatchStatus status;

  /// Textual representation shown below the score row.
  /// Examples: "16:00", "Live 82'", "FT".
  final String statusText;

  /// Home team score. Displayed only when [status] is [MatchStatus.live]
  /// or [MatchStatus.finished]. Shows "–" when null.
  final int? homeScore;

  /// Away team score. Displayed only when [status] is [MatchStatus.live]
  /// or [MatchStatus.finished]. Shows "–" when null.
  final int? awayScore;

  bool get _hasScore => status != MatchStatus.scheduled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLeague(),
          const SizedBox(height: 12),
          _buildTeamsRow(),
          const SizedBox(height: 12),
          _buildStatus(),
        ],
      ),
    );
  }

  Widget _buildLeague() {
    return Text(
      league,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTeamsRow() {
    return Row(
      children: [
        Expanded(child: _buildTeam(homeTeam, Alignment.centerLeft)),
        _buildCenter(),
        Expanded(child: _buildTeam(awayTeam, Alignment.centerRight)),
      ],
    );
  }

  Widget _buildTeam(String name, Alignment alignment) {
    final isLeft = alignment == Alignment.centerLeft;
    final children = [
      const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFE5E7EB),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          name,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: isLeft ? children : children.reversed.toList(),
    );
  }

  Widget _buildCenter() {
    if (!_hasScore) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          '-',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    final home = homeScore?.toString() ?? '–';
    final away = awayScore?.toString() ?? '–';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '$home : $away',
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final isLive = status == MatchStatus.live;

    return Text(
      statusText,
      style: AppTypography.labelMedium.copyWith(
        color: isLive ? const Color(0xFFEF4444) : AppColors.textSecondary,
      ),
    );
  }
}
