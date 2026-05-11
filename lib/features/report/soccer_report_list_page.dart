import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/report_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/report/report_card.dart';

class SoccerReportListPage extends StatelessWidget {
  const SoccerReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: 'Soccer Reports',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(TsSpacing.lg),
        itemCount: soccerReportsDummy.length,
        separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
        itemBuilder: (context, index) {
          final report = soccerReportsDummy[index];
          return ReportCard(
            title: report.title,
            thumbnailUrl: null,
            leagueId: report.leagueId,
            date: report.date,
            size: ReportCardSize.large,
            onTap: () => context.push('/menu/reports/soccer/${report.id}'),
          );
        },
      ),
    );
  }
}
