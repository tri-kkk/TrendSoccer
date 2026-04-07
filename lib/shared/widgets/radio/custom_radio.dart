import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/component_tokens.dart';

/// TrendSoccer custom radio button component.
///
/// Supports two states:
/// - [RadioState.unchecked]: Empty circle outline
/// - [RadioState.checked]: Circle outline with filled inner dot
///
/// ```dart
/// CustomRadio(
///   state: RadioState.checked,
///   onChanged: (newState) => print(newState),
/// )
/// ```
class CustomRadio extends StatelessWidget {
  const CustomRadio({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final RadioState state;
  final ValueChanged<RadioState>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isChecked = state == RadioState.checked;

    return GestureDetector(
      onTap: () => onChanged?.call(RadioState.checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked ? AppColors.primary500 : AppColors.textSecondary,
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isChecked ? 12 : 0,
            height: isChecked ? 12 : 0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary500,
            ),
          ),
        ),
      ),
    );
  }
}
