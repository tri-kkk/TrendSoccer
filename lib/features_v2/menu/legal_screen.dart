import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({
    required this.title,
    required this.provider,
    super.key,
  });

  final String title;
  final FutureProvider<String> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final contentAsync = ref.watch(provider);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: title,
        onBack: () => context.go('/menu'),
      ),
      body: contentAsync.when(
        skipLoadingOnRefresh: false,
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            TsSpacing.lg,
            TsSpacing.lg,
            TsSpacing.lg,
            TsSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              TsSkeletonBlock(TsSkeletonType.title, width: 200),
              SizedBox(height: TsSpacing.lg),
              TsSkeletonBlock(TsSkeletonType.line),
              SizedBox(height: TsSpacing.sm),
              TsSkeletonBlock(TsSkeletonType.line),
              SizedBox(height: TsSpacing.sm),
              TsSkeletonBlock(TsSkeletonType.line, width: 280),
              SizedBox(height: TsSpacing.lg),
              TsSkeletonBlock(TsSkeletonType.block),
              SizedBox(height: TsSpacing.lg),
              TsSkeletonBlock(TsSkeletonType.line),
              SizedBox(height: TsSpacing.sm),
              TsSkeletonBlock(TsSkeletonType.line),
              SizedBox(height: TsSpacing.sm),
              TsSkeletonBlock(TsSkeletonType.line, width: 240),
            ],
          ),
        ),
        error: (_, _) => Center(
          child: TsEmptyState(
            type: TsEmptyType.failure,
            title: 'Unable to load',
            description: 'Check your connection and try again.',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(provider),
          ),
        ),
        data: (content) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            TsSpacing.lg,
            TsSpacing.lg,
            TsSpacing.lg,
            TsSpacing.xl,
          ),
          child: MarkdownBody(
            data: content,
            styleSheet: _legalMarkdownStyle(c),
            selectable: true,
            shrinkWrap: true,
            fitContent: false,
            onTapLink: (text, href, title) {
              if (href == null) return;
              if (href.startsWith('mailto:')) {
                context.go('/menu/help');
              } else if (href.startsWith('http')) {
                launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _legalMarkdownStyle(TsThemeColors c) {
    return MarkdownStyleSheet(
      h2: TsType.h2.copyWith(color: c.textPrimary),
      h2Padding: const EdgeInsets.only(bottom: TsSpacing.lg),
      p: TsType.bodyLMedium.copyWith(color: c.textSecondary),
      pPadding: const EdgeInsets.only(bottom: TsSpacing.lg),
      blockSpacing: TsSpacing.lg,
      a: TsType.bodyLMedium.copyWith(
        color: c.primary,
        decoration: TextDecoration.underline,
        decorationColor: c.primary,
      ),
    );
  }
}
