import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_network_image.dart';
import 'package:trendsoccer/design_system/widgets/ts_news_hero_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_news_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_logic.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_provider.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class FeedNewsBody extends ConsumerWidget {
  const FeedNewsBody({
    required this.selectedSport,
    super.key,
  });

  final FeedNewsSportFilter? selectedSport;

  Future<void> _openArticle(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final newsAsync = ref.watch(feedNewsProvider);

    Future<void> onRefresh() async {
      ref.invalidate(feedNewsProvider);
      await ref.read(feedNewsProvider.future);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: newsAsync.when(
        loading: () => _loadingList(),
        error: (_, _) => _centeredEmptyList(
          TsEmptyState(
            type: TsEmptyType.failure,
            title: l10n.newsLoadError,
            description: l10n.errorNetwork,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(feedNewsProvider),
          ),
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return _centeredEmptyList(
              TsEmptyState(
                title: l10n.emptyDataTitle,
                description: l10n.emptyDataSubtitle,
              ),
            );
          }

          final filtered = filterFeedNewsArticles(articles, selectedSport);
          if (filtered.isEmpty) {
            return _centeredEmptyList(
              TsEmptyState(
                title: l10n.emptyDataTitle,
                description: l10n.emptyDataSubtitle,
              ),
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              TsSpacing.lg,
              0,
              TsSpacing.lg,
              TsSpacing.xl,
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
            itemBuilder: (context, index) {
              final article = filtered[index];
              if (index == 0) {
                return GestureDetector(
                  onTap: () => unawaited(_openArticle(article.url)),
                  behavior: HitTestBehavior.opaque,
                  child: TsNewsHeroCard(
                    titleLabel: article.titleLabel,
                    metaLabel:
                        '${article.sourceLabel} · ${article.timeLabel}',
                    imageUrl: article.imageUrl,
                  ),
                );
              }

              return TsNewsRow(
                title: article.titleLabel,
                source: article.sourceLabel,
                timeLabel: article.timeLabel,
                thumbnail: TsNetworkImage(
                  imageUrl: article.imageUrl,
                  aspectRatio: 16 / 9,
                  placeholderIcon: TsIcons.imageNotSupported,
                ),
                onTap: () => unawaited(_openArticle(article.url)),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _loadingList() {
  return ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      TsSpacing.lg,
      0,
      TsSpacing.lg,
      TsSpacing.xl,
    ),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
    itemBuilder: (_, _) => const TsSkeletonBlock(TsSkeletonType.block),
  );
}

Widget _centeredEmptyList(Widget empty) {
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: empty,
          ),
        ),
      ),
    ],
  );
}
