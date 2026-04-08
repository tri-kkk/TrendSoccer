import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/badge/custom_badge.dart';
import '../../shared/widgets/cards/match_card.dart';

class TrendPage extends StatelessWidget {
  const TrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadgeSection(),
              const SizedBox(height: 32),
              _buildMatchCardSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CustomBadge(type: BadgeType.pick, label: 'PICK'),
            CustomBadge(type: BadgeType.good, label: 'GOOD'),
            CustomBadge(type: BadgeType.pass, label: 'PASS'),
            CustomBadge(type: BadgeType.premium, label: 'Premium'),
            CustomBadge(type: BadgeType.trial, label: 'Trial'),
            CustomBadge(type: BadgeType.free, label: 'Free'),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Cards',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const MatchCard(
          league: 'Premier League',
          homeTeam: 'Chelsea',
          awayTeam: 'Arsenal',
          status: MatchStatus.scheduled,
          statusText: '16:00',
        ),
        const SizedBox(height: 16),
        const MatchCard(
          league: 'Premier League',
          homeTeam: 'Chelsea',
          awayTeam: 'Arsenal',
          status: MatchStatus.live,
          statusText: "Live 82'",
          homeScore: 2,
          awayScore: 1,
        ),
        const SizedBox(height: 16),
        const MatchCard(
          league: 'Premier League',
          homeTeam: 'Chelsea',
          awayTeam: 'Arsenal',
          status: MatchStatus.finished,
          statusText: 'FT',
          homeScore: 2,
          awayScore: 1,
        ),
      ],
    );
  }
}
