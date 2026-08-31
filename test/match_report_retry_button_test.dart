import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';

void main() {
  test('MatchReportRetryButton exposes progress label and disables action', () {
    var pressed = 0;
    final idle = MatchReportRetryButton(
      inProgress: false,
      onPressed: () => pressed++,
    );
    expect(idle.label, 'Retry');
    expect(idle.action, isNotNull);
    idle.action!();
    expect(pressed, 1);

    final busy = MatchReportRetryButton(
      inProgress: true,
      onPressed: () => pressed++,
    );
    expect(busy.label, 'Retrying…');
    expect(busy.action, isNull);
  });
}
