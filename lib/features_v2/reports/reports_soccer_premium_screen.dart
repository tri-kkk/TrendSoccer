import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_shell.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';
import 'package:trendsoccer/features_v2/reports/reports_soccer_premium_body.dart';

class ReportsSoccerPremiumScreen extends ConsumerWidget {
  const ReportsSoccerPremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReportsHeaderShell(
      sport: TsSport.soccer,
      segment: ReportsSegment.premium,
      child: const ReportsSoccerPremiumBody(),
    );
  }
}
