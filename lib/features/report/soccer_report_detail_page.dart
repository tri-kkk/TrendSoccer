import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/report/report_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';

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

  PreferredSizeWidget _appBar(BuildContext context, String title) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return AppBar(
      backgroundColor: semantic.surfaceBase,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: TsType.headingH3.copyWith(color: semantic.textPrimary),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(height: 2, color: semantic.textDisabled),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final brightness = Theme.of(context).brightness;
    final report = _findReport();

    if (report == null) {
      return Scaffold(
        backgroundColor: semantic.surfaceBase,
        appBar: _appBar(context, '매치 리포트'),
        body: const TsEmptyState(
          title: '리포트를 찾을 수 없습니다.',
          subtitle: '목록에서 다시 선택해 주세요.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: _appBar(context, '매치 리포트'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 232),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: semantic.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, size: 40, color: semantic.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    'Report Banner',
                    style: TsType.bodyMBold.copyWith(color: semantic.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  TsAssets.logoEditor(brightness),
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.author,
                        style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '축구 데이터 분석가',
                        style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  TsAssets.leagueLogo(report.leagueId, brightness),
                  height: 24,
                ),
                Text(
                  report.date,
                  style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              report.title,
              style: TsType.headingH1.copyWith(color: semantic.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              report.content,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
