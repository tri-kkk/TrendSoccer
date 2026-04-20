import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

class InfoCell extends StatelessWidget {
  const InfoCell({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.valueFontSize = 16,
    this.valueFontWeight = FontWeight.w600,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final double valueFontSize;
  final FontWeight valueFontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (valueWidget != null)
            valueWidget!
          else
            Text(
              value ?? '',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: valueFontSize,
                fontWeight: valueFontWeight,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
