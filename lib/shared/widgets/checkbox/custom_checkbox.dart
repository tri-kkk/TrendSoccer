import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/component_tokens.dart';

/// TrendSoccer custom checkbox component.
///
/// Supports three states:
/// - [CheckboxState.unchecked]: Empty checkbox
/// - [CheckboxState.checked]: Checked with icon
/// - [CheckboxState.partial]: Indeterminate state with minus icon
class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final CheckboxState state;
  final ValueChanged<CheckboxState>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isActive = state != CheckboxState.unchecked;

    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          final newState = state == CheckboxState.checked
              ? CheckboxState.unchecked
              : CheckboxState.checked;
          onChanged!(newState);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary500 : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.primary500 : AppColors.textSecondary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isActive
            ? Icon(
                state == CheckboxState.checked ? Icons.check : Icons.remove,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
