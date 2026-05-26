import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

String formatPitcherAnalysisParagraphs(String text) {
  if (text.isEmpty) return text;

  text = text.replaceAll(r'\n', '\n');

  if (text.contains('\n') &&
      text.split('\n').where((segment) => segment.trim().isNotEmpty).length >
          1) {
    return text.trim();
  }

  final formatted = text.replaceAllMapped(
    RegExp(r'(다\.\s)(?=\S)'),
    (match) => '다.\n\n',
  );

  return formatted.trim();
}

List<String> _splitAnalysisParagraphs(String text) {
  return formatPitcherAnalysisParagraphs(text)
      .split('\n')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

class PitcherAnalysisSection extends StatelessWidget {
  const PitcherAnalysisSection({
    this.analysisText,
    this.isLoading = false,
    super.key,
  });

  final String? analysisText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final bodyStyle = TsType.bodyMRegular.copyWith(color: semantic.textSecondary);
    final paragraphs = analysisText == null
        ? const <String>[]
        : _splitAnalysisParagraphs(analysisText!);
    final hasContent = paragraphs.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '투수 분석',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? _LoadingPlaceholder(semantic: semantic)
              : hasContent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < paragraphs.length; i++) ...[
                          if (i > 0) const SizedBox(height: TsSpacing.md),
                          Text(
                            paragraphs[i],
                            style: bodyStyle,
                          ),
                        ],
                      ],
                    )
                  : Text(
                      '투수 분석 데이터를 불러올 수 없습니다.',
                      style: bodyStyle,
                    ),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.semantic});

  final TsSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final widthFactor in [1.0, 0.92, 0.78]) ...[
          Container(
            height: 12,
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * widthFactor,
            ),
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
        ],
      ],
    );
  }
}
