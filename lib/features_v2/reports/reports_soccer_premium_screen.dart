import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_shell.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

class ReportsSoccerPremiumScreen extends StatelessWidget {
  const ReportsSoccerPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportsHeaderShell(
        sport: TsSport.soccer,
        segment: ReportsSegment.premium,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
