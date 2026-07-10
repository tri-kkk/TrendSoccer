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

  static const _predictionSectionMarkers = [
    '## TrendSoccer Prediction',
    '## TrendSoccer Analysis',
    '## TrendSoccer 분석',
    '## 트렌드사커 예측',
    '## 트렌드사커 분석',
    '## Prediction',
    '## Analysis',
    '## 예측',
    '## 분석',
  ];

  static (String body, String? heading, String? predictionBody)
      splitAnalysisSection(String cleanContent) {
    int? splitIndex;
    String? matchedMarker;
    for (final marker in _predictionSectionMarkers) {
      final index = cleanContent.indexOf(marker);
      if (index >= 0 && (splitIndex == null || index < splitIndex)) {
        splitIndex = index;
        matchedMarker = marker;
      }
    }
    if (splitIndex == null || matchedMarker == null) {
      return (cleanContent, null, null);
    }

    final headingStart = splitIndex;
    final afterMarker = splitIndex + matchedMarker.length;
    final newlineIndex = cleanContent.indexOf('\n', afterMarker);
    final headingEnd = newlineIndex >= 0 ? newlineIndex : cleanContent.length;
    final headingLine = cleanContent.substring(headingStart, headingEnd).trim();
    final bodyAfterHeading = newlineIndex >= 0
        ? cleanContent.substring(newlineIndex + 1).trim()
        : '';

    return (
      cleanContent.substring(0, headingStart).trim(),
      headingLine,
      bodyAfterHeading.isEmpty ? null : bodyAfterHeading,
    );
  }

  static String _predictionHeadingDisplayText(String headingLine) {
    final trimmed = headingLine.trimLeft();
    if (trimmed.startsWith('## ')) {
      return trimmed.substring(3).trim();
    }
    return headingLine;
  }

  Widget _predictionHeading(String headingLine, TsSemanticColors semantic) {
    return Text(
      _predictionHeadingDisplayText(headingLine),
      style: TsType.headingH2.copyWith(color: semantic.textPrimary),
    );
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
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
            color: colors.surfaceBase.withValues(alpha: 0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: TsSpacing.md),
                Text(
                  context.l10n.premiumExclusiveContent,
                  style: TsType.headingH3.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.sm),
                Text(
                  context.l10n.subscribeToUnlock,
                  style: TsType.labelSRegular.copyWith(color: colors.textTertiary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.lg),
                TsButton(
                  label: context.l10n.subscribeNow,
                  variant: TsButtonVariant.primary,
                  size: TsButtonSize.small,
                  onPressed: () => navigateToSubscribe(context, ref),
                ),
              ],
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
      backgroundColor: semantic.surfaceRaised,
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
          final (bodyContent, predictionHeading, predictionBody) =
              splitAnalysisSection(cleanContent);

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
                if (predictionHeading != null) ...[
                  const SizedBox(height: TsSpacing.lg),
                  if (hasFullAccess)
                    _markdownBody(
                      predictionBody != null && predictionBody.isNotEmpty
                          ? '$predictionHeading\n\n$predictionBody'
                          : predictionHeading,
                      semantic,
                    )
                  else ...[
                    _predictionHeading(predictionHeading, semantic),
                    if (predictionBody != null && predictionBody.isNotEmpty) ...[
                      const SizedBox(height: TsSpacing.lg),
                      _buildBlurredAnalysis(
                        context,
                        ref,
                        predictionBody,
                        semantic,
                      ),
                    ],
                  ],
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
