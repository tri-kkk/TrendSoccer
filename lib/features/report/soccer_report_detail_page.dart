import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/report_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_logo.dart';

class SoccerReportDetailPage extends StatelessWidget {
  const SoccerReportDetailPage({
    required this.reportId,
    super.key,
  });

  final String reportId;

  SoccerReportData? _findReport() {
    for (final r in soccerReportsDummy) {
      if (r.id == reportId) {
        return r;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final report = _findReport();

    if (report == null) {
      return Scaffold(
        backgroundColor: semantic.surfaceBase,
        appBar: const TsAppBar(
          location: TsAppBarLocation.backTitle,
          title: '리포트',
        ),
        body: const TsEmptyState(
          title: '리포트를 찾을 수 없습니다.',
          subtitle: '목록에서 다시 선택해 주세요.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '리포트',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 232,
              width: double.infinity,
              color: semantic.surfaceContainer,
              child: Center(
                child: Icon(Icons.image, size: 48, color: semantic.textTertiary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: semantic.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: semantic.interactivePrimary,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.author,
                              style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'TrendSoccer Editor',
                              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.md),
                  if (report.leagueId.isNotEmpty) ...[
                    TsLeagueLogo(leagueId: report.leagueId, height: 24),
                    const SizedBox(height: TsSpacing.md),
                  ],
                  Text(
                    report.title,
                    style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                  ),
                  Text(
                    report.date,
                    style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  Text(
                    report.content,
                    style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                  ),
                  const SizedBox(height: TsSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
