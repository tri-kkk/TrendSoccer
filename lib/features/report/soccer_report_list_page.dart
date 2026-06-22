import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/blog_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/blog_parser.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/loading/report_list_skeleton.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class SoccerReportListPage extends ConsumerWidget {
  const SoccerReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final postsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      appBar: TsAppBar.preferred(
        context,
        location: TsAppBarLocation.backTitle,
        title: l10n.menuMatchPreview,
        onBack: () => context.pop(),
      ),
      body: postsAsync.when(
        loading: () => const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: TsSpacing.lg),
            child: ReportListSkeleton(),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.reportListLoadError,
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: l10n.retry,
                variant: TsButtonVariant.primary,
                size: TsButtonSize.small,
                onPressed: () => ref.invalidate(blogPostsProvider),
              ),
            ],
          ),
        ),
        data: (response) {
          final locale = getApiLanguage(ref.read(sharedPreferencesProvider));
          final posts = BlogParser.parsePostsList(response, locale: locale);
          if (posts.isEmpty) {
            return TsEmptyState(
              title: l10n.reportEmptyTitle,
              subtitle: l10n.reportEmptySubtitle,
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: TsSpacing.lg,
              right: TsSpacing.lg,
              top: TsSpacing.lg,
              bottom: TsSpacing.lg + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              children: [
                for (var i = 0; i < posts.length; i++) ...[
                  if (i > 0) const SizedBox(height: TsSpacing.lg),
                  _ReportCard(
                    post: posts[i],
                    onTap: () => context.push('/menu/reports/soccer/${posts[i].slug}'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.post,
    required this.onTap,
  });

  final BlogPostListItem post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TsSpacing.md),
        decoration: BoxDecoration(
          color: semantic.surfaceBase,
          borderRadius: BorderRadius.circular(TsSpacing.lg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TsSpacing.sm),
              child: post.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: post.thumbnailUrl,
                      width: 160,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _thumbnailPlaceholder(semantic),
                      errorWidget: (context, url, error) =>
                          _thumbnailError(semantic),
                    )
                  : _thumbnailError(semantic),
            ),
            const SizedBox(width: TsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: TsSpacing.xs),
                  Text(
                    post.description,
                    style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: TsSpacing.xs),
                  Text(
                    post.date,
                    style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder(TsSemanticColors semantic) {
    return Container(
      width: 160,
      height: 90,
      color: semantic.surfaceContainer,
    );
  }

  Widget _thumbnailError(TsSemanticColors semantic) {
    return Container(
      width: 160,
      height: 90,
      color: semantic.surfaceContainer,
      child: Icon(Icons.image_not_supported, color: semantic.textTertiary),
    );
  }
}
