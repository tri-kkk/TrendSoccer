import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum ReportTab { standard, premium }

class ReportToggle extends StatelessWidget {
  const ReportToggle({
    required this.selectedTab,
    required this.onChanged,
    super.key,
  });

  final ReportTab selectedTab;
  final ValueChanged<ReportTab> onChanged;

  static String _label(AppLocalizations l10n, ReportTab tab) {
    return switch (tab) {
      ReportTab.standard => l10n.reportTabStandard,
      ReportTab.premium => l10n.reportTabPremium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    Widget segment(ReportTab tab) {
      final selected = selectedTab == tab;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(tab),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? semantic.interactivePrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _label(l10n, tab),
              style: TsType.bodyLBold.copyWith(
                color: selected
                    ? semantic.surfaceBase
                    : semantic.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(TsSpacing.xs),
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            segment(ReportTab.standard),
            const SizedBox(width: TsSpacing.xs),
            segment(ReportTab.premium),
          ],
        ),
      ),
    );
  }
}
