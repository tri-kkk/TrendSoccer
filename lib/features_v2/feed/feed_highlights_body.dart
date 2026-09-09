import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_highlight_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlight.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlights_provider.dart';
import 'package:trendsoccer/features_v2/feed/highlight_player_sheet.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class FeedHighlightsBody extends ConsumerWidget {
  const FeedHighlightsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final highlightsAsync = ref.watch(feedHighlightsProvider);

    Future<void> onRefresh() async {
      ref.invalidate(feedHighlightsProvider);
      await ref.read(feedHighlightsProvider.future);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: highlightsAsync.when(
        loading: () => _loadingList(),
        error: (_, _) => _centeredEmptyList(
          TsEmptyState(
            type: TsEmptyType.failure,
            title: l10n.highlightsLoadError,
            description: l10n.errorNetwork,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(feedHighlightsProvider),
          ),
        ),
        data: (highlights) {
          if (highlights.isEmpty) {
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
            itemCount: highlights.length,
            separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
            itemBuilder: (context, index) {
              return _HighlightListCard(highlight: highlights[index]);
            },
          );
        },
      ),
    );
  }
}

class _HighlightListCard extends StatelessWidget {
  const _HighlightListCard({required this.highlight});

  final FeedHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final leagueLogoUrl = highlight.leagueLogoUrl;

    return TsHighlightCard(
      leagueIcon: leagueLogoUrl == null || leagueLogoUrl.isEmpty
          ? TsIcon(
              TsIcons.imageNotSupported,
              size: TsIconSize.xs,
              color: c.textTertiary,
            )
          : TsLeagueIcon(
              highlight.leagueCode,
              size: TsIconSize.xs,
              logoUrl: leagueLogoUrl,
              preferAsset: false,
            ),
      metaLabel: highlight.metaLabel,
      titleLabel: highlight.titleLabel,
      imageUrl: highlight.imageUrl,
      onTap: () => showHighlightPlayerSheet(context, highlight),
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
