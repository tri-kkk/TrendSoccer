import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

class SplitGaugeBar extends StatelessWidget {
  const SplitGaugeBar({
    super.key,
    required this.homeValue,
    required this.awayValue,
    required this.homeLabel,
    required this.awayLabel,
    required this.centerLabel,
  });

  final double homeValue;
  final double awayValue;
  final String homeLabel;
  final String awayLabel;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              homeLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              centerLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              awayLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = (constraints.maxWidth - 8) / 2;

            return Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                  child: SizedBox(
                    width: barWidth,
                    height: 8,
                    child: Stack(
                      children: [
                        Container(
                          width: barWidth,
                          height: 8,
                          color: AppColors.surfaceContainer,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: barWidth * homeValue,
                            height: 8,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  child: SizedBox(
                    width: barWidth,
                    height: 8,
                    child: Stack(
                      children: [
                        Container(
                          width: barWidth,
                          height: 8,
                          color: AppColors.surfaceContainer,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: barWidth * awayValue,
                            height: 8,
                            color: AppColors.errorRed500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
