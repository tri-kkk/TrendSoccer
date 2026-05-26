import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum ScoreBoxResult { win, draw, lose }

class ScoreBox extends StatelessWidget {
  const ScoreBox({
    required this.score,
    required this.result,
    this.homeTeamLogo,
    this.awayTeamLogo,
    super.key,
  });

  final String score;
  final ScoreBoxResult result;
  final String? homeTeamLogo;
  final String? awayTeamLogo;

  Color _scoreBackground(TsSemanticColors semantic) {
    switch (result) {
      case ScoreBoxResult.win:
        return semantic.interactivePrimary;
      case ScoreBoxResult.draw:
        return semantic.surfaceContainer;
      case ScoreBoxResult.lose:
        return TsColors.systemError500;
    }
  }

  Widget _logoPlaceholder(TsSemanticColors semantic) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: semantic.surfaceContainer,
        border: Border.all(color: semantic.borderSubtle, width: 1),
      ),
    );
  }

  Widget _networkLogo(String? url, TsSemanticColors semantic) {
    if (url == null || url.isEmpty) {
      return _logoPlaceholder(semantic);
    }
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => _logoPlaceholder(semantic),
          errorWidget: (context, url, error) => _logoPlaceholder(semantic),
        ),
      ),
    );
  }

  Widget _buildEmblem(TsSemanticColors semantic, Brightness brightness) {
    switch (result) {
      case ScoreBoxResult.draw:
        return SvgPicture.asset(
          TsAssets.logoEditor(brightness),
          width: 32,
          height: 32,
        );
      case ScoreBoxResult.win:
        return _networkLogo(homeTeamLogo, semantic);
      case ScoreBoxResult.lose:
        return _networkLogo(awayTeamLogo, semantic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final brightness = Theme.of(context).brightness;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEmblem(semantic, brightness),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _scoreBackground(semantic),
          ),
          alignment: Alignment.center,
          child: Text(
            score,
            style: TsType.labelSRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }
}
