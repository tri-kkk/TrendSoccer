import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../../../shared/widgets/report/report_section_card.dart';
import '../../../shared/widgets/report/single_gauge_bar.dart';

class PowerIndexSection extends StatelessWidget {
  const PowerIndexSection({
    super.key,
    required this.homePower,
    required this.awayPower,
    required this.isBlurred,
    required this.blurText,
  });

  final double homePower;
  final double awayPower;
  final bool isBlurred;
  final String blurText;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Power Index',
      isBlurred: isBlurred,
      blurText: blurText,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'H Pow.',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleGaugeBar(
              homeRatio: homePower,
              awayRatio: awayPower,
              height: 16.0,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'A Pow.',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
