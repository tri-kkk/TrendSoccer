import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';

void main() {
  test('MatchReportRetryButton disables action while retry is in progress', () {
    var pressed = 0;
    final idle = MatchReportRetryButton(
      inProgress: false,
      onPressed: () => pressed++,
    );
    expect(idle.action, isNotNull);
    idle.action!();
    expect(pressed, 1);

    final busy = MatchReportRetryButton(
      inProgress: true,
      onPressed: () => pressed++,
    );
    expect(busy.action, isNull);
  });
}
