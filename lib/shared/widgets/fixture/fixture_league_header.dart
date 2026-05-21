import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_logo.dart';

class FixtureLeagueHeader extends StatelessWidget {
  const FixtureLeagueHeader({
    required this.leagueName,
    required this.leagueCode,
    this.leagueLogoUrl,
    super.key,
  });

  final String leagueName;
  final String leagueCode;
  final String? leagueLogoUrl;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final displayName = fixtureDisplayLeagueName(leagueName, leagueCode);

    return Row(
      children: [
        FixtureLeagueLogo(
          leagueName: displayName,
          leagueCode: leagueCode,
          leagueLogoUrl: leagueLogoUrl,
          size: 20,
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: Text(
            displayName,
            style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
