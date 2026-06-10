import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class FixtureTeamRow extends StatelessWidget {
  const FixtureTeamRow({
    required this.teamName,
    this.teamLogoUrl,
    this.score,
    super.key,
  });

  final String teamName;
  final String? teamLogoUrl;
  final String? score;

  Widget _logo(TsSemanticColors semantic) {
    Widget ph() {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: semantic.surfaceOverlay,
          border: Border.all(
            color: semantic.borderSubtle,
            width: 1,
          ),
        ),
      );
    }

    final url = teamLogoUrl;
    debugPrint(
      '[LOGO] Rendering: team=$teamName, url=$url, isNull=${url == null}',
    );
    if (url == null || url.isEmpty) {
      return ph();
    }
    return ClipOval(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => ph(),
          errorWidget: (context, url, error) => ph(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final primaryStyle = TsType.labelSRegular.copyWith(color: semantic.textPrimary);

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _logo(semantic),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Text(
                  teamName,
                  style: primaryStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (score != null) Text(score!, style: primaryStyle),
      ],
    );
  }
}
