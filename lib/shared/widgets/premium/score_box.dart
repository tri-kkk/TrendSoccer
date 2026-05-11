import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/premium/circle_badge.dart';

class ScoreBox extends StatelessWidget {
  const ScoreBox({
    required this.result,
    required this.score,
    this.teamLogoUrl,
    super.key,
  });

  final MatchResult result;
  final String score;
  final String? teamLogoUrl;

  Color _scoreBoxBackground(TsSemanticColors semantic) {
    switch (result) {
      case MatchResult.win:
        return semantic.interactivePrimary;
      case MatchResult.draw:
        return semantic.surfaceContainer;
      case MatchResult.lose:
        return TsColors.systemError500;
    }
  }

  Widget _logo(BuildContext context, TsSemanticColors semantic) {
    if (result == MatchResult.draw) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.sports_soccer,
          size: 16,
          color: semantic.textTertiary,
        ),
      );
    }

    final url = teamLogoUrl;
    if (url == null || url.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          shape: BoxShape.circle,
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              shape: BoxShape.circle,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _logo(context, semantic),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _scoreBoxBackground(semantic),
            borderRadius: BorderRadius.circular(8),
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
