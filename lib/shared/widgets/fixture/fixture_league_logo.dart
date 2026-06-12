import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
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

  String get _codeLabel {
    final code = leagueCode.trim().toUpperCase();
    if (code.isEmpty) return '--';
    if (code.length <= 4) return code;
    return code.substring(0, 3);
  }

  double get _codeFontSize {
    final length = _codeLabel.length;
    if (length <= 2) return 11;
    return 9;
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
        _codeLabel,
        style: TsType.labelXsBold.copyWith(
          color: semantic.textTertiary,
          fontSize: _codeFontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _worldCupIcon(BuildContext context) {
    return SvgPicture.asset(
      TsAssets.leagueIcon26fwc(Theme.of(context).brightness),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  Widget _assetFallback(BuildContext context, TsSemanticColors semantic) {
    if (leagueCode.trim().toUpperCase() == 'WC') {
      return _worldCupIcon(context);
    }
    final iconId = TsAssets.leagueIconIdFromApiCode(leagueCode);
    if (iconId != null) {
      return TsLeagueIcon(leagueId: iconId, size: size);
    }
    return _textFallback(semantic);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    if (leagueCode.trim().toUpperCase() == 'WC') {
      return _worldCupIcon(context);
    }

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
