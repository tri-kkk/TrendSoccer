import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/providers/blog_provider.dart';
import 'package:trendsoccer/features/menu/help_center_page.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class TermsOfServicePage extends ConsumerWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final contentAsync = ref.watch(termsContentProvider);

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        title: Text(
          l10n.menuTermsOfService,
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: contentAsync.when(
        skipLoadingOnRefresh: false,
        loading: () => Center(
          child: CircularProgressIndicator(color: semantic.interactivePrimary),
        ),
        error: (_, _) => _LegalErrorState(
          semantic: semantic,
          onRetry: () => ref.invalidate(termsContentProvider),
        ),
        data: (content) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
          ),
          child: MarkdownBody(
            data: content,
            styleSheet: _legalMarkdownStyle(semantic),
            selectable: true,
            shrinkWrap: true,
            fitContent: false,
            onTapLink: (text, href, title) {
              if (href == null) return;
              if (href.startsWith('mailto:')) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HelpCenterPage(),
                  ),
                );
              } else if (href.startsWith('http')) {
                launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _legalMarkdownStyle(TsSemanticColors semantic) {
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
      h4: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
      h4Padding: const EdgeInsets.only(
        top: TsSpacing.md,
        bottom: TsSpacing.sm,
      ),
      p: TsType.bodyMRegular.copyWith(
        color: semantic.textSecondary,
        height: 21 / 14,
      ),
      pPadding: const EdgeInsets.only(bottom: TsSpacing.sm),
      strong: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
      listBullet: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
      a: TsType.bodyLRegular.copyWith(
        color: semantic.interactivePrimary,
        decoration: TextDecoration.underline,
        decorationColor: semantic.interactivePrimary,
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
}

class _LegalErrorState extends StatelessWidget {
  const _LegalErrorState({
    required this.semantic,
    required this.onRetry,
  });

  final TsSemanticColors semantic;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.legalLoadError,
              style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TsButton(
              label: l10n.retry,
              variant: TsButtonVariant.secondary,
              size: TsButtonSize.small,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
