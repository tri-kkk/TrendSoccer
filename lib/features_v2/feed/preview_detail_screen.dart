import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/blog_provider.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_locked_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_post_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_detail_logic.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_logic.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class PreviewDetailScreen extends ConsumerWidget {
  const PreviewDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = Theme.of(context).extension<TsThemeColors>()!;
    ref.watch(languageProvider);
    final locale = getApiLanguage(ref.read(sharedPreferencesProvider));
    final auth = ref.watch(authProvider);
    final postAsync = ref.watch(blogPostDetailProvider(slug));
    final bottomPadding = TsSpacing.xl + MediaQuery.paddingOf(context).bottom;

    Future<void> onRefresh() async {
      ref.invalidate(blogPostDetailProvider(slug));
      await ref.read(blogPostDetailProvider(slug).future);
    }

    final appBarTitle = postAsync.when(
      data: (response) {
        final post = parseFeedPreviewDetail(response, locale: locale);
        if (post != null) {
          return extractFeedPreviewMatchupTitle(post.content, post.title);
        }
        return l10n.menuMatchPreview;
      },
      loading: () => l10n.menuMatchPreview,
      error: (_, _) => l10n.menuMatchPreview,
    );

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: appBarTitle,
        onBack: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: postAsync.when(
          loading: () => _loadingBody(),
          error: (_, _) => _centeredState(
            TsEmptyState(
              type: TsEmptyType.failure,
              title: l10n.reportDetailLoadError,
              description: l10n.errorNetwork,
              actionLabel: l10n.retry,
              onAction: () => ref.invalidate(blogPostDetailProvider(slug)),
            ),
          ),
          data: (response) {
            final post = parseFeedPreviewDetail(response, locale: locale);
            if (post == null) {
              return _centeredState(
                TsEmptyState(
                  title: l10n.reportNotFoundTitle,
                  description: l10n.reportNotFoundSubtitle,
                ),
              );
            }

            final emblemId = leagueEmblemIdFromTags(post.tags);
            final cleanContent = cleanFeedPreviewMarkdownContent(post.content);
            final (bodyContent, predictionHeading, predictionBody) =
                splitFeedPreviewAnalysisSection(cleanContent);
            final lockLabel = _previewLockLabel(l10n, auth.planType);
            final lockOnTap = _previewLockOnTap(context, auth.planType);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                TsSpacing.lg,
                TsSpacing.lg,
                TsSpacing.lg,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TsPostHeader(
                    authorLabel: l10n.appName,
                    roleLabel: l10n.reportAuthorRole,
                    leagueLogo: emblemId == null
                        ? const SizedBox.shrink()
                        : TsLeagueLogo(emblemId, height: 20),
                    dateLabel: post.dateLabel,
                    titleLabel: post.title,
                    imageUrl: post.imageUrl,
                  ),
                  if (bodyContent.isNotEmpty) ...[
                    const SizedBox(height: TsSpacing.lg),
                    _previewMarkdownBody(bodyContent, c),
                  ],
                  if (predictionHeading != null) ...[
                    const SizedBox(height: TsSpacing.lg),
                    if (auth.hasFullAccess)
                      _previewMarkdownBody(
                        predictionBody != null && predictionBody.isNotEmpty
                            ? '$predictionHeading\n\n$predictionBody'
                            : predictionHeading,
                        c,
                      )
                    else ...[
                      Text(
                        feedPreviewPredictionHeadingDisplayText(predictionHeading),
                        style: TsType.h2.copyWith(color: c.textPrimary),
                      ),
                      if (predictionBody != null && predictionBody.isNotEmpty) ...[
                        const SizedBox(height: TsSpacing.lg),
                        TsLockedBlock(
                          label: lockLabel,
                          onTap: lockOnTap,
                          child: _previewMarkdownBody(predictionBody, c),
                        ),
                      ],
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String _previewLockLabel(AppLocalizations l10n, PlanType planType) {
  if (planType == PlanType.none) {
    return l10n.loginAppBarTitle;
  }
  return l10n.reportPremiumOnlyTitle;
}

VoidCallback? _previewLockOnTap(BuildContext context, PlanType planType) {
  if (planType == PlanType.none) {
    return () => context.push('/login');
  }
  return () => context.push('/menu/subscribe');
}

Widget _previewMarkdownBody(String data, TsThemeColors c) {
  return MarkdownBody(
    data: data,
    styleSheet: _previewMarkdownStyle(c),
    selectable: true,
    shrinkWrap: true,
    fitContent: false,
  );
}

MarkdownStyleSheet _previewMarkdownStyle(TsThemeColors c) {
  return MarkdownStyleSheet(
    h2: TsType.h2.copyWith(color: c.textPrimary),
    h2Padding: const EdgeInsets.only(
      top: TsSpacing.xl,
      bottom: TsSpacing.sm,
    ),
    h3: TsType.h3.copyWith(color: c.textPrimary),
    h3Padding: const EdgeInsets.only(
      top: TsSpacing.lg,
      bottom: TsSpacing.sm,
    ),
    p: TsType.bodyLRegular.copyWith(color: c.textSecondary),
    pPadding: const EdgeInsets.only(bottom: TsSpacing.sm),
    strong: TsType.bodyLBold.copyWith(color: c.textPrimary),
    listBullet: TsType.bodyLRegular.copyWith(color: c.textSecondary),
    a: TsType.bodyLRegular.copyWith(
      color: c.primary,
      decoration: TextDecoration.underline,
      decorationColor: c.primary,
    ),
    tableHead: TsType.bodyMBold.copyWith(color: c.textPrimary),
    tableBody: TsType.bodyMRegular.copyWith(color: c.textSecondary),
    tableBorder: TableBorder.all(color: c.borderSubtle, width: 1),
    tableCellsPadding: const EdgeInsets.symmetric(
      horizontal: TsSpacing.sm,
      vertical: TsSpacing.xs,
    ),
    tableCellsDecoration: BoxDecoration(color: c.surfaceRaised),
    tableColumnWidth: const FlexColumnWidth(),
    tableHeadAlign: TextAlign.left,
    blockquote: TsType.bodyMRegular.copyWith(color: c.textTertiary),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(color: c.primary, width: 3),
      ),
    ),
    blockquotePadding: const EdgeInsets.only(
      left: TsSpacing.md,
      top: TsSpacing.xs,
      bottom: TsSpacing.xs,
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: c.borderSubtle, width: 1)),
    ),
  );
}

Widget _loadingBody() {
  return SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      TsSpacing.lg,
      TsSpacing.lg,
      TsSpacing.lg,
      TsSpacing.xl,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        TsSkeletonBlock(TsSkeletonType.block),
        SizedBox(height: TsSpacing.lg),
        TsSkeletonBlock(TsSkeletonType.title, width: 200),
        SizedBox(height: TsSpacing.sm),
        TsSkeletonBlock(TsSkeletonType.line),
        SizedBox(height: TsSpacing.sm),
        TsSkeletonBlock(TsSkeletonType.line, width: 280),
        SizedBox(height: TsSpacing.lg),
        TsSkeletonBlock(TsSkeletonType.line),
        SizedBox(height: TsSpacing.sm),
        TsSkeletonBlock(TsSkeletonType.line),
      ],
    ),
  );
}

Widget _centeredState(Widget child) {
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: child,
          ),
        ),
      ),
    ],
  );
}
