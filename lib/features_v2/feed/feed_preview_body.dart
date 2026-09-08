import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_preview_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_logic.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_post.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_provider.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class FeedPreviewBody extends ConsumerWidget {
  const FeedPreviewBody({
    required this.selectedLeagueId,
    required this.onClearLeagueSelection,
    super.key,
  });

  final String? selectedLeagueId;
  final VoidCallback onClearLeagueSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final postsAsync = ref.watch(feedPreviewPostsProvider);

    Future<void> onRefresh() async {
      ref.invalidate(feedPreviewPostsProvider);
      await ref.read(feedPreviewPostsProvider.future);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: postsAsync.when(
        loading: () => _loadingList(),
        error: (_, _) => _centeredEmptyList(
          TsEmptyState(
            type: TsEmptyType.failure,
            title: l10n.reportListLoadError,
            description: l10n.errorNetwork,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(feedPreviewPostsProvider),
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return _centeredEmptyList(
              TsEmptyState(
                title: l10n.feedPreviewEmptyTitle,
                description: l10n.feedPreviewEmptyBody,
              ),
            );
          }

          final filtered = filterFeedPreviewPosts(posts, selectedLeagueId);
          if (filtered.isEmpty) {
            return _centeredEmptyList(
              TsEmptyState(
                type: TsEmptyType.withAction,
                title: l10n.feedPreviewNoLeagueTitle,
                description: l10n.feedPreviewNoLeagueBody,
                actionLabel: l10n.feedPreviewViewAll,
                onAction: onClearLeagueSelection,
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
              final post = filtered[index];
              return _PreviewListCard(
                post: post,
                languageCode: languageCode,
                onTap: () => context.push('/feed/preview/${post.slug}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _PreviewListCard extends StatelessWidget {
  const _PreviewListCard({
    required this.post,
    required this.languageCode,
    required this.onTap,
  });

  final FeedPreviewPost post;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final emblemId = leagueEmblemIdFromTags(post.tags);
    final leagueLabel = leagueLabelForEmblemId(emblemId, languageCode);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TsPreviewCard(
        leagueIcon: emblemId == null
            ? TsIcon(
                TsIcons.imageNotSupported,
                size: TsIconSize.xs,
                color: c.textTertiary,
              )
            : TsLeagueIcon(emblemId, size: TsIconSize.xs),
        leagueLabel: leagueLabel,
        dateLabel: post.dateLabel,
        titleLabel: post.title,
        excerptLabel: post.excerpt,
        imageUrl: post.imageUrl,
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
