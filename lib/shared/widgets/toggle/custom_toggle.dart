import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/component_tokens.dart';

/// TrendSoccer custom toggle switch component.
///
/// Supports two states:
/// - [ToggleState.off]: Track in secondary color, thumb aligned left
/// - [ToggleState.on]: Track in primary color, thumb aligned right
///
/// ```dart
/// CustomToggle(
///   state: ToggleState.on,
///   onChanged: (newState) => print(newState),
/// )
/// ```
class CustomToggle extends StatelessWidget {
  const CustomToggle({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final ToggleState state;
  final ValueChanged<ToggleState>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isOn = state == ToggleState.on;

    return GestureDetector(
      onTap: () {
        final newState = isOn ? ToggleState.off : ToggleState.on;
        onChanged?.call(newState);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isOn ? AppColors.primary500 : AppColors.textSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
