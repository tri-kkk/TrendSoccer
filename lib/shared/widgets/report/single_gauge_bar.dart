import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';

class SingleGaugeBar extends StatelessWidget {
  const SingleGaugeBar({
    super.key,
    required this.homeRatio,
    required this.awayRatio,
    this.height = 8.0,
  });

  final double homeRatio;
  final double awayRatio;
  final double height;

  @override
  Widget build(BuildContext context) {
    final homeFlex = (homeRatio * 100).round().clamp(1, 99);
    final awayFlex = (awayRatio * 100).round().clamp(1, 99);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ColoredBox(
          color: AppColors.passGray500,
          child: Row(
            children: [
              Expanded(
                flex: homeFlex,
                child: Container(color: AppColors.primary500),
              ),
              Expanded(
                flex: awayFlex,
                child: Container(color: AppColors.errorRed500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
