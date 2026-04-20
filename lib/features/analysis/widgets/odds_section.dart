import 'package:flutter/material.dart';

import '../../../shared/widgets/report/info_cell.dart';
import '../../../shared/widgets/report/report_section_card.dart';

class OddsSection extends StatelessWidget {
  const OddsSection({
    super.key,
    required this.home,
    required this.draw,
    required this.away,
  });

  final double home;
  final double draw;
  final double away;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Odds',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InfoCell(
                label: 'Home',
                value: home.toStringAsFixed(2),
                valueFontSize: 24,
                valueFontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoCell(
                label: 'Draw',
                value: draw.toStringAsFixed(2),
                valueFontSize: 24,
                valueFontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoCell(
                label: 'Away',
                value: away.toStringAsFixed(2),
                valueFontSize: 24,
                valueFontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
