import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/component_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../checkbox/custom_checkbox.dart';
import 'tag_widget.dart';

class TermsRow extends StatelessWidget {
  final String title;
  final bool isRequired;
  final bool isChecked;
  final VoidCallback onChanged;
  final VoidCallback? onViewPressed;

  const TermsRow({
    super.key,
    required this.title,
    required this.isRequired,
    required this.isChecked,
    required this.onChanged,
    this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomCheckbox(
          state: isChecked ? CheckboxState.checked : CheckboxState.unchecked,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(width: 8),
        TagWidget(
          type: isRequired ? TagType.required : TagType.optional,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (onViewPressed != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onViewPressed,
            child: Text(
              'View',
              style: AppTypography.enLabelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
