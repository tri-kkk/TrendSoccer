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
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleButton(
            label: 'Standard',
            isSelected: isStandardSelected,
            onTap: onStandardTap,
          ),
          const SizedBox(width: 4),
          _ToggleButton(
            label: 'Premium',
            isSelected: !isStandardSelected,
            onTap: onPremiumTap,
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
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
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isSelected ? AppColors.surfaceBase : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
