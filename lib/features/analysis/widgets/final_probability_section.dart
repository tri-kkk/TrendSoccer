import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../../../shared/widgets/report/report_section_card.dart';

class FinalProbabilitySection extends StatelessWidget {
  const FinalProbabilitySection({
    super.key,
    required this.home,
    required this.draw,
    required this.away,
    required this.isBlurred,
    required this.blurText,
  });

  final int home;
  final int draw;
  final int away;
  final bool isBlurred;
  final String blurText;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Final Probability',
      isBlurred: isBlurred,
      blurText: blurText,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 32,
              child: Row(
                children: [
                  Expanded(
                    flex: home,
                    child: Container(
                      color: AppColors.primary500,
                      alignment: Alignment.center,
                      child: Text(
                        '$home%',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: draw,
                    child: Container(
                      color: AppColors.surfaceContainer,
                      alignment: Alignment.center,
                      child: Text(
                        '$draw%',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: away,
                    child: Container(
                      color: AppColors.errorRed500,
                      alignment: Alignment.center,
                      child: Text(
                        '$away%',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Home',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                'Draw',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                'Away',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
