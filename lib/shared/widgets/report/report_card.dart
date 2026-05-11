import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

enum ReportCardSize { large, small }

class ReportCard extends StatelessWidget {
  const ReportCard({
    required this.title,
    required this.date,
    this.thumbnailUrl,
    this.leagueId,
    this.size = ReportCardSize.large,
    this.onTap,
    super.key,
  });

  final String title;
  final String date;
  final String? thumbnailUrl;
  final String? leagueId;
  final ReportCardSize size;
  final VoidCallback? onTap;

  Widget _thumbnailLarge(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: _thumbnailInner(context, semantic, height: 160),
    );
  }

  Widget _thumbnailInner(
    BuildContext context,
    TsSemanticColors semantic, {
    required double height,
  }) {
    final url = thumbnailUrl;
    return ColoredBox(
      color: semantic.surfaceContainer,
      child: url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              placeholder: (context, url) => _placeholderIcon(semantic),
              errorWidget: (context, url, error) => _placeholderIcon(semantic),
            )
          : _placeholderIcon(semantic),
    );
  }

  Widget _placeholderIcon(TsSemanticColors semantic) {
    return Center(
      child: Icon(Icons.image, size: 40, color: semantic.textTertiary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    if (size == ReportCardSize.large) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _thumbnailLarge(context),
              Padding(
                padding: const EdgeInsets.all(TsSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                    ),
                    const SizedBox(height: TsSpacing.sm),
                    Row(
                      children: [
                        if (leagueId != null && leagueId!.isNotEmpty) ...[
                          TsLeagueIcon(leagueId: leagueId!, size: 16),
                          const SizedBox(width: TsSpacing.sm),
                        ],
                        Text(
                          date,
                          style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 200,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: semantic.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: _thumbnailInner(context, semantic, height: 100),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TsSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                    ),
                    const SizedBox(height: TsSpacing.xs),
                    Text(
                      date,
                      style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
