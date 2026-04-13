import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../buttons/primary_button.dart';
import '../league/league_icon.dart';

/// A card prompting the user to analyze a specific match.
///
/// Displays a league header (icon + name + date), home/away team emblems
/// separated by a "VS" divider with match time, and a primary CTA button.
///
/// Layout follows Figma node `651:49908`.
///
/// ```dart
/// AnalysisCard(
///   leagueCode: 'KBO',
///   date: '04.13',
///   homeTeam: 'Home',
///   awayTeam: 'Away',
///   time: '18:30',
///   onAnalyze: () {},
/// )
/// ```
class AnalysisCard extends StatelessWidget {
  const AnalysisCard({
    super.key,
    required this.leagueCode,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.time,
    this.onAnalyze,
  });

  /// League code for the icon lookup (e.g. "EPL", "KBO").
  /// Must match a key in [LeagueIcon]'s asset map.
  final String leagueCode;

  /// Match date string shown in the header (e.g. "04.13").
  final String date;

  /// Home team name.
  final String homeTeam;

  /// Away team name.
  final String awayTeam;

  /// Kick-off / match time shown below VS (e.g. "18:30").
  final String time;

  /// Called when the Analyze button is pressed.
  final VoidCallback? onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(AppSpacing.xl),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildTeams(),
          const SizedBox(height: AppSpacing.xl),
          _buildAnalyzeButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LeagueIcon(league: leagueCode, size: 24),
            const SizedBox(width: 8),
            Text(
              LeagueIcon.getLeagueName(leagueCode),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        Text(
          date,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildTeams() {
    return Row(
      children: [
        Expanded(child: _buildTeamEmblem(homeTeam)),
        const SizedBox(width: AppSpacing.xl),
        _buildVsCenter(),
        const SizedBox(width: AppSpacing.xl),
        Expanded(child: _buildTeamEmblem(awayTeam)),
      ],
    );
  }

  Widget _buildTeamEmblem(String teamName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: AppSpacing.iconSize,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          teamName,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildVsCenter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VS',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          time,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return PrimaryButton(
      label: 'Analyze',
      onPressed: onAnalyze,
    );
  }
}
