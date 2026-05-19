import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/report_dummy_data.dart';

class SoccerReportListPage extends StatelessWidget {
  const SoccerReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '리포트',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < soccerReportsDummy.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _ReportCard(
                report: soccerReportsDummy[i],
                onTap: () => context.push('/menu/reports/soccer/${soccerReportsDummy[i].id}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  final SoccerReportData report;
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
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: semantic.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.article_outlined,
                size: 32,
                color: semantic.textTertiary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.date,
                    style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.title,
                    style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
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
}
