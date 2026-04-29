import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/component_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../radio/custom_radio.dart';

class AgreeToAllRow extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onChanged;

  const AgreeToAllRow({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            IgnorePointer(
              child: CustomRadio(
                state:
                    isChecked ? RadioState.checked : RadioState.unchecked,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Agree to All',
              style: AppTypography.enLabelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
