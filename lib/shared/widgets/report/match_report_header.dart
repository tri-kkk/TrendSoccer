import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../league/league_icon.dart';
import 'report_toggle.dart';

class MatchReportHeader extends StatelessWidget {
  const MatchReportHeader({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.leagueId,
    required this.matchDateTime,
    required this.isStandardSelected,
    required this.onStandardTap,
    required this.onPremiumTap,
  });

  final String homeTeam;
  final String awayTeam;
  final String leagueId;
  final DateTime matchDateTime;
  final bool isStandardSelected;
  final VoidCallback onStandardTap;
  final VoidCallback onPremiumTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceBase,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LeagueIcon(league: leagueId, size: 24),
          const SizedBox(height: 16),
          Text(
            DateFormat('EEE, MMM d HH:mm').format(matchDateTime),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TeamColumn(teamName: homeTeam),
              const SizedBox(width: 40),
              Text(
                'VS',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 40),
              _TeamColumn(teamName: awayTeam),
            ],
          ),
          const SizedBox(height: 16),
          ReportToggle(
            isStandardSelected: isStandardSelected,
            onStandardTap: onStandardTap,
            onPremiumTap: onPremiumTap,
          ),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.teamName});

  final String teamName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFE5E7EB),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            teamName,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
