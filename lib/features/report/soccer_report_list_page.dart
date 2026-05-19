import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/report_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';

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
        leading: TsBackButton(onPressed: () => context.pop()),
        title: Text(
          '매치 프리뷰',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
        ),
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
              child: SvgPicture.asset(
                TsAssets.iconBlog,
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  semantic.textTertiary,
                  BlendMode.srcIn,
                ),
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
