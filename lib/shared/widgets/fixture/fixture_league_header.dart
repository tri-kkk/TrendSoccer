import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

class FixtureLeagueHeader extends StatelessWidget {
  const FixtureLeagueHeader({
    required this.leagueId,
    required this.leagueName,
    this.leagueLogoUrl,
    super.key,
  });

  final String leagueId;
  final String leagueName;
  final String? leagueLogoUrl;

  Widget _logo(TsSemanticColors semantic) {
    final url = leagueLogoUrl;
    if (url == null || url.isEmpty) {
      return TsLeagueIcon(leagueId: leagueId, size: 32);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 32,
        height: 32,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => Container(
            width: 32,
            height: 32,
            color: semantic.surfaceContainer,
          ),
          errorWidget: (context, url, error) => TsLeagueIcon(leagueId: leagueId, size: 32),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      children: [
        _logo(semantic),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: Text(
            leagueName,
            style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
