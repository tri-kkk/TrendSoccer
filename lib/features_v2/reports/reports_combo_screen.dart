import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_date_strip.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_shell.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

class ReportsComboScreen extends StatelessWidget {
  const ReportsComboScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportsHeaderShell(
        sport: TsSport.baseball,
        segment: ReportsSegment.multiMatch,
        dateStripDates: reportsHistoryDateStripDates(),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
