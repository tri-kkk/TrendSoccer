import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';

class MatchHeader extends StatelessWidget {
  const MatchHeader({
    required this.leagueId,
    required this.matchDate,
    required this.homeTeam,
    required this.awayTeam,
    required this.selectedTab,
    required this.onTabChanged,
    this.leagueName,
    this.leagueLogoUrl,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.showTabToggle = true,
    super.key,
  });

  final String leagueId;
  final String? leagueName;
  final String? leagueLogoUrl;
  final String matchDate;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final ReportTab selectedTab;
  final ValueChanged<ReportTab> onTabChanged;
  final bool showTabToggle;

  static const TextStyle _vsTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  static const double _teamLogoSize = 48;

  Widget _teamLogo(BuildContext context, String? url) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    Widget placeholder() {
      return Container(
        width: _teamLogoSize,
        height: _teamLogoSize,
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          shape: BoxShape.circle,
        ),
      );
    }

    if (url == null || url.isEmpty) {
      return placeholder();
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: _teamLogoSize,
        height: _teamLogoSize,
        fit: BoxFit.cover,
        placeholder: (context, _) => placeholder(),
        errorWidget: (context, _, _) => placeholder(),
      ),
    );
  }

  Widget _teamColumn(BuildContext context, String team, String? logoUrl) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final teamNameStyle = TsType.headingH3.copyWith(color: semantic.textPrimary);
    final teamNameBlockHeight =
        (teamNameStyle.fontSize ?? 16) * (teamNameStyle.height ?? 1) * 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _teamLogo(context, logoUrl),
        const SizedBox(height: TsSpacing.sm),
        SizedBox(
          height: teamNameBlockHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              team,
              style: teamNameStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      width: double.infinity,
      color: semantic.surfaceBase,
      padding: const EdgeInsets.symmetric(
        horizontal: TsSpacing.lg,
        vertical: TsSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TsLeagueIcon(
            leagueId: leagueId,
            size: 24,
            logoUrl: leagueLogoUrl,
          ),
          const SizedBox(height: TsSpacing.lg),
          Text(
            matchDate,
            style: TsType.labelSRegular.copyWith(
              color: semantic.textTertiary,
            ),
          ),
          const SizedBox(height: TsSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: _teamColumn(context, homeTeam, homeLogoUrl),
              ),
              const SizedBox(width: TsSpacing.md),
              Text(
                'VS',
                style: _vsTextStyle.copyWith(color: semantic.textTertiary),
              ),
              const SizedBox(width: TsSpacing.md),
              Expanded(
                flex: 3,
                child: _teamColumn(context, awayTeam, awayLogoUrl),
              ),
            ],
          ),
          if (showTabToggle) ...[
            const SizedBox(height: TsSpacing.lg),
            ReportToggle(selectedTab: selectedTab, onChanged: onTabChanged),
          ],
        ],
      ),
    );
  }
}
