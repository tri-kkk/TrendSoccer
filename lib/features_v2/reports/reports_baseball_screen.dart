import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_shell.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

class ReportsBaseballScreen extends StatelessWidget {
  const ReportsBaseballScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportsHeaderShell(
        sport: TsSport.baseball,
        segment: ReportsSegment.analysis,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
