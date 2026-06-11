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

class SoccerReportListPage extends ConsumerWidget {
  const SoccerReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final postsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: TsAppBar.preferred(
        context,
        location: TsAppBarLocation.backTitle,
        title: l10n.menuMatchPreview,
        onBack: () => context.pop(),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.reportListLoadError,
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              children: [
                for (var i = 0; i < posts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: semantic.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 128,
                height: 96,
                child: post.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        post.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _thumbnailFallback(semantic),
                      )
                    : _thumbnailFallback(semantic),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.date,
                    style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.description,
                    style: TsType.labelSRegular.copyWith(color: semantic.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailFallback(TsSemanticColors semantic) {
    return ColoredBox(
      color: semantic.surfaceContainer,
      child: Center(
        child: Icon(Icons.image, color: semantic.textTertiary),
      ),
    );
  }
}
