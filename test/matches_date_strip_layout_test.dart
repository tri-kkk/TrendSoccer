import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_date_chip.dart';
import 'package:trendsoccer/features_v2/matches/matches_screen.dart';

void main() {
  final chipDates = List.generate(
    8,
    (index) => DateTime(2026, 3, 10).add(Duration(days: index - 3)),
  );

  Widget wrap(double width) {
    return MaterialApp(
      theme: ThemeData(
        extensions: const [TsThemeColors.dark],
      ),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Scaffold(
          body: SizedBox(
            width: width,
            child: MatchesDateStrip(
              chipDates: chipDates,
              selectedDateIndex: 3,
              weekdayLabel: (_) => 'Mon',
              isToday: (date) => date.day == 13,
              onDateSelected: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpStrip(WidgetTester tester, double width) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    await tester.pumpWidget(wrap(width));
    await tester.pumpAndSettle();
  }

  double chipWidth(WidgetTester tester) {
    final boxes = tester
        .renderObjectList<RenderBox>(find.byType(TsDateChip))
        .toList();
    expect(boxes, hasLength(8));
    return boxes.first.size.width;
  }

  bool hasScrollView(WidgetTester tester) {
    return find.byType(SingleChildScrollView).evaluate().isNotEmpty;
  }

  testWidgets('date strip layout at target widths', (tester) async {
    final threshold = MatchesDateStrip.fillThreshold(8);
    expect(threshold, 412);

    final cases = <double>[320, 360, 412, 480];
    for (final width in cases) {
      await pumpStrip(tester, width);
      final scroll = hasScrollView(tester);
      final widthMeasured = chipWidth(tester);
      final expectedFill = width >= threshold;
      expect(scroll, !expectedFill, reason: 'width=$width');
      if (expectedFill) {
        final expected =
            (width - MatchesDateStrip.hPadding * 2 - MatchesDateStrip.gap * 7) /
                8;
        expect(widthMeasured, closeTo(expected, 0.01));
      } else {
        expect(widthMeasured, 44);
      }

      expect(find.text('Mon'), findsNWidgets(8));

      expect(tester.takeException(), isNull);
    }
  });
}
