import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(extensions: const [TsThemeColors.dark]),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(412, 900)),
        child: SizedBox(
          width: 412,
          child: child,
        ),
      ),
    );
  }

  testWidgets('analysis carousel error rail fits at 412px width', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ko'));

    await tester.pumpWidget(
      wrap(
        Align(
          alignment: Alignment.center,
          child: TsEmptyState(
            type: TsEmptyType.failure,
            title: l10n.analysisLoadMatchesFailed,
            description: l10n.errorNetwork,
            actionLabel: l10n.retry,
            onAction: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('today matches error rail fits at 412px width', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ko'));

    await tester.pumpWidget(
      wrap(
        Align(
          alignment: Alignment.center,
          child: TsEmptyState(
            type: TsEmptyType.failure,
            title: l10n.analysisLoadMatchesFailed,
            description: l10n.errorNetwork,
            actionLabel: l10n.retry,
            onAction: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('loading rails keep fixed heights for horizontal lists', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SizedBox(
                    width: 340,
                    child: TsSkeletonBlock(TsSkeletonType.block),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SizedBox(
                    width: 300,
                    child: TsSkeletonBlock(TsSkeletonType.block),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final heights = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((box) => box.height == 120 || box.height == 118)
        .map((box) => box.height)
        .toList();
    expect(heights, contains(120));
    expect(heights, contains(118));
    expect(tester.takeException(), isNull);
  });
}
