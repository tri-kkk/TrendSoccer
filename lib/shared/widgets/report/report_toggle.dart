import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

class ReportToggle extends StatelessWidget {
  const ReportToggle({
    super.key,
    required this.isStandardSelected,
    required this.onStandardTap,
    required this.onPremiumTap,
  });

  final bool isStandardSelected;
  final VoidCallback onStandardTap;
  final VoidCallback onPremiumTap;

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to compute pill position from actual rendered width.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Container has 4px padding on each side → inner area width.
        final innerWidth = constraints.maxWidth - 8;
        // Two equal buttons separated by a 4px gap.
        final pillWidth = (innerWidth - 4) / 2;
        final pillLeft = isStandardSelected ? 0.0 : pillWidth + 4;

        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              // Sliding pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: pillLeft,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Labels — rendered above the pill
              Row(
                children: [
                  _TabLabel(
                    label: 'Standard',
                    isSelected: isStandardSelected,
                    onTap: onStandardTap,
                  ),
                  const SizedBox(width: 4),
                  _TabLabel(
                    label: 'Premium',
                    isSelected: !isStandardSelected,
                    onTap: onPremiumTap,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 40,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.surfaceBase
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
