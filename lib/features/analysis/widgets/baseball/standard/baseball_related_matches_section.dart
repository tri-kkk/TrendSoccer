import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';

class BaseballRelatedMatchesSection extends StatelessWidget {
  const BaseballRelatedMatchesSection({
    required this.matches,
    super.key,
  });

  final List<BaseballRelatedMatch> matches;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballRelatedMatches,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var i = 0; i < matches.length; i++) ...[
                _RelatedMatchRow(match: matches[i]),
                if (i < matches.length - 1) ...[
                  const SizedBox(height: TsSpacing.md),
                  Container(height: 1, color: semantic.borderSubtle),
                  const SizedBox(height: TsSpacing.md),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RelatedMatchRow extends StatelessWidget {
  const _RelatedMatchRow({required this.match});

  final BaseballRelatedMatch match;

  Widget _teamLogo(String? url, TsSemanticColors semantic) {
    Widget placeholder() {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: semantic.surfaceContainer,
        ),
      );
    }

    if (url == null || url.isEmpty) return placeholder();
    return ClipOval(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => placeholder(),
          errorWidget: (context, url, error) => placeholder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final labelStyle = TsType.labelSRegular.copyWith(color: semantic.textPrimary);

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            match.dateDisplay,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
          ),
        ),
        _teamLogo(match.awayLogoUrl, semantic),
        const SizedBox(width: TsSpacing.xs),
        Expanded(
          child: Text(
            match.awayTeam,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm),
          child: Text(
            match.scoreDisplay,
            style: labelStyle,
          ),
        ),
        Expanded(
          child: Text(
            match.homeTeam,
            style: labelStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: TsSpacing.xs),
        _teamLogo(match.homeLogoUrl, semantic),
      ],
    );
  }
}
