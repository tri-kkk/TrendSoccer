import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_names.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

export 'fixture_league_names.dart';

/// League logo for Fixture: API URL → local TsAssets icon → text circle.
class FixtureLeagueLogo extends StatelessWidget {
  const FixtureLeagueLogo({
    required this.leagueName,
    required this.leagueCode,
    this.leagueLogoUrl,
    this.size = 20,
    super.key,
  });

  final String leagueName;
  final String leagueCode;
  final String? leagueLogoUrl;
  final double size;

  String get _initials {
    final label = fixtureDisplayLeagueName(leagueName, leagueCode);
    final trimmed = label.trim();
    if (trimmed.isEmpty) return '--';
    if (trimmed.length == 1) return trimmed.toUpperCase();
    return trimmed.substring(0, 2).toUpperCase();
  }

  Widget _textFallback(TsSemanticColors semantic) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: semantic.surfaceContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TsType.labelXsBold.copyWith(
          color: semantic.textTertiary,
          fontSize: size <= 16 ? 8 : 10,
        ),
      ),
    );
  }

  Widget _assetFallback(BuildContext context, TsSemanticColors semantic) {
    final iconId = TsAssets.leagueIconIdFromApiCode(leagueCode);
    if (iconId != null) {
      return TsLeagueIcon(leagueId: iconId, size: size);
    }
    return _textFallback(semantic);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final url = leagueLogoUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _assetFallback(context, semantic),
          ),
        ),
      );
    }

    return _assetFallback(context, semantic);
  }
}
