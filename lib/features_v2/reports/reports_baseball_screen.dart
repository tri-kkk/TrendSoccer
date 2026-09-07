import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_analysis_body.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_shell.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

class ReportsBaseballScreen extends ConsumerWidget {
  const ReportsBaseballScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReportsHeaderShell(
      sport: TsSport.baseball,
      segment: ReportsSegment.analysis,
      child: const ReportsBaseballAnalysisBody(),
    );
  }
}
