import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_analysis_body.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_shell.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

class ReportsSoccerScreen extends ConsumerWidget {
  const ReportsSoccerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ReportsHeaderShell(
        sport: TsSport.soccer,
        segment: ReportsSegment.analysis,
        child: const ReportsSoccerAnalysisBody(),
      ),
    );
  }
}
