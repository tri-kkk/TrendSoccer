import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/features_v2/matches/match_report_screen.dart';

void main() {
  Future<EdgeInsets> scrollPadding(
    WidgetTester tester, {
    required double bottomInset,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(extensions: const [TsThemeColors.dark]),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              viewPadding: EdgeInsets.only(bottom: bottomInset),
              padding: EdgeInsets.only(bottom: bottomInset),
            ),
            child: const MatchReportScreen(
              sport: 'soccer',
              matchId: '1',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    return scrollView.padding as EdgeInsets;
  }

  testWidgets('adds viewPadding.bottom on top of the 24px design padding', (
    tester,
  ) async {
    final noInset = await scrollPadding(tester, bottomInset: 0);
    expect(noInset.bottom, TsSpacing.xl);

    final gestureInset = await scrollPadding(tester, bottomInset: 34);
    expect(gestureInset.bottom, TsSpacing.xl + 34);

    final threeButtonInset = await scrollPadding(tester, bottomInset: 48);
    expect(threeButtonInset.bottom, TsSpacing.xl + 48);
  });
}
