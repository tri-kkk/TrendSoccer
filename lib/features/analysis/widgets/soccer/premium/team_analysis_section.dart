import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/premium/card_section_title.dart';

class TeamAnalysisSection extends StatefulWidget {
  const TeamAnalysisSection({
    required this.teamName,
    required this.overallForm,
    required this.homeAwayForm,
    required this.goalStats,
    required this.recentResults,
    required this.strengthText,
    required this.weaknessText,
    super.key,
  });

  final String teamName;
  final String overallForm;
  final String homeAwayForm;
  final String goalStats;
  final String recentResults;
  final String strengthText;
  final String weaknessText;

  @override
  State<TeamAnalysisSection> createState() => _TeamAnalysisSectionState();
}

class _TeamAnalysisSectionState extends State<TeamAnalysisSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardSectionTitle(
          title: widget.teamName,
          isExpanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) ...[
          const SizedBox(height: TsSpacing.lg),
          Container(
            padding: const EdgeInsets.all(TsSpacing.lg),
            decoration: BoxDecoration(
              color: semantic.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SubSection(label: '전체 폼', value: widget.overallForm),
                const SizedBox(height: TsSpacing.md),
                _SubSection(label: '홈/원정 폼', value: widget.homeAwayForm),
                const SizedBox(height: TsSpacing.md),
                _SubSection(label: '득실 통계', value: widget.goalStats),
                const SizedBox(height: TsSpacing.md),
                _SubSection(label: '최근 5경기', value: widget.recentResults),
                const SizedBox(height: TsSpacing.md),
                _SubSection(label: '강점', value: widget.strengthText),
                const SizedBox(height: TsSpacing.md),
                _SubSection(label: '약점', value: widget.weaknessText),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SubSection extends StatelessWidget {
  const _SubSection({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TsType.bodyMBold.copyWith(color: semantic.textTertiary),
        ),
        const SizedBox(height: TsSpacing.xs),
        Text(
          value,
          style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
        ),
      ],
    );
  }
}
