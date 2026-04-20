import 'package:flutter/material.dart';

import '../../../core/models/soccer_match_report.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../../../shared/widgets/report/report_section_card.dart';
import '../../../shared/widgets/report/single_gauge_bar.dart';

class ThreeMethodSection extends StatelessWidget {
  const ThreeMethodSection({
    super.key,
    required this.methods,
    required this.isBlurred,
    required this.blurText,
  });

  final List<MethodStat> methods;
  final bool isBlurred;
  final String blurText;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: '3-Method Analysis',
      isBlurred: isBlurred,
      blurText: blurText,
      child: Column(
        children: List.generate(methods.length, (i) {
          final m = methods[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < methods.length - 1 ? 8 : 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      m.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(m.homeRatio * 100).round()}%',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleGaugeBar(
                  homeRatio: m.homeRatio,
                  awayRatio: m.awayRatio,
                  height: 8.0,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
