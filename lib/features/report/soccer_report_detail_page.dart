import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/blog_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/blog_parser.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';

class SoccerReportDetailPage extends ConsumerWidget {
  const SoccerReportDetailPage({
    required this.slug,
    super.key,
  });

  final String slug;

  static String extractMatchupTitle(String content, String titleKrFallback) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('# ')) {
        final h1Text = trimmed.substring(2).trim();
        if (h1Text.contains(':')) {
          return h1Text.split(':').first.trim();
        }
        return h1Text;
      }
    }
    if (titleKrFallback.contains('|')) {
      return titleKrFallback.split('|').first.trim();
    }
    return titleKrFallback;
  }

  static String removeFirstH1(String content) {
    final lines = content.split('\n');
    if (lines.isNotEmpty && lines.first.trimLeft().startsWith('# ')) {
      var startIndex = 1;
      while (startIndex < lines.length && lines[startIndex].trim().isEmpty) {
        startIndex++;
      }
      return lines.sublist(startIndex).join('\n');
    }
    return content;
  }

  static String cleanMarkdownContent(String content) {
    content = removeFirstH1(content);
    content = content.replaceAll(RegExp(r'[█░]+\s*'), '');
    return content;
  }

  static (String body, String? analysis) splitAnalysisSection(String cleanContent) {
    const analysisSplit = '## TrendSoccer 분석';
    final splitIndex = cleanContent.indexOf(analysisSplit);
    if (splitIndex >= 0) {
      return (
        cleanContent.substring(0, splitIndex).trim(),
        cleanContent.substring(splitIndex).trim(),
      );
    }
    return (cleanContent, null);
  }

  Widget _markdownBody(String data, TsSemanticColors semantic) {
    return SizedBox(
      width: double.infinity,
      child: MarkdownBody(
        data: data,
        styleSheet: _markdownStyle(semantic),
        selectable: true,
        shrinkWrap: true,
        fitContent: false,
      ),
    );
  }

  Widget _buildBlurredAnalysis(
    BuildContext context,
    WidgetRef ref,
    String analysisContent,
    TsSemanticColors colors,
  ) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: IgnorePointer(
              child: MarkdownBody(
                data: analysisContent,
                styleSheet: _markdownStyle(colors),
                shrinkWrap: true,
                fitContent: false,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.surfaceBase.withValues(alpha: 0.3),
                  colors.surfaceBase.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: colors.textTertiary,
                    size: 32,
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  Text(
                    context.l10n.reportPremiumOnlyTitle,
                    style: TsType.bodyLBold.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TsSpacing.xs),
                  Text(
                    context.l10n.reportPremiumOnlyMessage,
                    style: TsType.bodyMRegular.copyWith(color: colors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => navigateToSubscribe(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.interactivePrimary,
                        foregroundColor: colors.interactiveOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: TsSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TsSpacing.sm),
                        ),
                      ),
                      child: Text(
                        context.l10n.premiumSubscribeNow,
                        style: TsType.bodyLBold.copyWith(
                          color: colors.interactiveOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  MarkdownStyleSheet _markdownStyle(TsSemanticColors semantic) {
    return MarkdownStyleSheet(
      h1: TsType.headingH1.copyWith(color: semantic.textPrimary),
      h1Padding: const EdgeInsets.only(
        top: TsSpacing.xl,
        bottom: TsSpacing.sm,
      ),
      h2: TsType.headingH2.copyWith(color: semantic.textPrimary),
      h2Padding: const EdgeInsets.only(
        top: TsSpacing.xl,
        bottom: TsSpacing.sm,
      ),
      h3: TsType.headingH3.copyWith(color: semantic.textPrimary),
      h3Padding: const EdgeInsets.only(
        top: TsSpacing.lg,
        bottom: TsSpacing.sm,
      ),
      p: TsType.bodyLRegular.copyWith(
        color: semantic.textSecondary,
        height: 21 / 14,
      ),
      pPadding: const EdgeInsets.only(bottom: TsSpacing.sm),
      strong: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
      listBullet: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
      a: TsType.bodyLRegular.copyWith(
        color: semantic.interactivePrimary,
        decoration: TextDecoration.underline,
      ),
      tableHead: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
      tableBody: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
      tableBorder: TableBorder.all(color: semantic.borderSubtle, width: 1),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: TsSpacing.sm,
        vertical: TsSpacing.xs,
      ),
      tableCellsDecoration: BoxDecoration(color: semantic.surfaceContainer),
      tableColumnWidth: const FlexColumnWidth(),
      tableHeadAlign: TextAlign.left,
      blockquote: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: semantic.interactivePrimary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(
        left: TsSpacing.md,
        top: TsSpacing.xs,
        bottom: TsSpacing.xs,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: semantic.borderSubtle, width: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final brightness = Theme.of(context).brightness;
    final auth = ref.watch(authProvider);
    final hasFullAccess = auth.hasFullAccess;
    final postAsync = ref.watch(blogPostDetailProvider(slug));
    final locale = getApiLanguage(ref.read(sharedPreferencesProvider));
    final bottomPadding = TsSpacing.lg + MediaQuery.paddingOf(context).bottom;
    final appBarTitle = postAsync.when(
      data: (response) {
        final post = BlogParser.parsePostDetail(response, locale: locale);
        if (post != null) {
          return extractMatchupTitle(post.content, post.title);
        }
        return l10n.menuMatchPreview;
      },
      loading: () => l10n.menuMatchPreview,
      error: (error, stackTrace) => l10n.menuMatchPreview,
    );

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: TsAppBar.preferred(
        context,
        location: TsAppBarLocation.backTitle,
        title: appBarTitle,
        onBack: () => context.pop(),
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.reportDetailLoadError,
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: l10n.retry,
                variant: TsButtonVariant.primary,
                size: TsButtonSize.small,
                onPressed: () => ref.invalidate(blogPostDetailProvider(slug)),
              ),
            ],
          ),
        ),
        data: (response) {
          final post = BlogParser.parsePostDetail(response, locale: locale);
          if (post == null) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: TsEmptyState(
                title: l10n.reportNotFoundTitle,
                subtitle: l10n.reportNotFoundSubtitle,
              ),
            );
          }

          final leagueLogoId = TsAssets.leagueLogoIdFromBlogTags(post.tags);
          final cleanContent = cleanMarkdownContent(post.content);
          final (bodyContent, analysisContent) = splitAnalysisSection(cleanContent);

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: TsSpacing.lg,
              right: TsSpacing.lg,
              top: TsSpacing.lg,
              bottom: bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(TsSpacing.sm),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 232),
                    child: SizedBox(
                      width: double.infinity,
                      height: 232,
                      child: post.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              post.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _bannerFallback(semantic),
                            )
                          : _bannerFallback(semantic),
                    ),
                  ),
                ),
                const SizedBox(height: TsSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      TsAssets.logoEditor(brightness),
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appName,
                            style: TsType.bodyLRegular.copyWith(
                              color: semantic.textPrimary,
                            ),
                          ),
                          const SizedBox(height: TsSpacing.xs),
                          Text(
                            l10n.reportAuthorRole,
                            style: TsType.labelSRegular.copyWith(
                              color: semantic.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TsSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (leagueLogoId != null)
                      SvgPicture.asset(
                        TsAssets.leagueLogo(leagueLogoId, brightness),
                        height: 24,
                        fit: BoxFit.contain,
                      )
                    else
                      const SizedBox.shrink(),
                    Text(
                      post.date,
                      style: TsType.labelSRegular.copyWith(
                        color: semantic.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TsSpacing.lg),
                Text(
                  post.title,
                  style: TsType.headingH1.copyWith(color: semantic.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: TsSpacing.lg),
                if (bodyContent.isNotEmpty) _markdownBody(bodyContent, semantic),
                if (analysisContent != null) ...[
                  const SizedBox(height: TsSpacing.lg),
                  if (hasFullAccess)
                    _markdownBody(analysisContent, semantic)
                  else
                    _buildBlurredAnalysis(
                      context,
                      ref,
                      analysisContent,
                      semantic,
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bannerFallback(TsSemanticColors semantic) {
    return ColoredBox(
      color: semantic.surfaceContainer,
      child: Center(
        child: Icon(Icons.image_outlined, size: 40, color: semantic.textTertiary),
      ),
    );
  }
}
