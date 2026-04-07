import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/tokens/color_tokens.dart';
import 'core/theme/tokens/component_tokens.dart';
import 'core/theme/tokens/spacing_tokens.dart';
import 'core/theme/tokens/typography_tokens.dart';
import 'shared/widgets/checkbox/custom_checkbox.dart';
import 'shared/widgets/radio/custom_radio.dart';
import 'shared/widgets/toggle/custom_toggle.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrendSoccerApp(),
    ),
  );
}

class TrendSoccerApp extends StatelessWidget {
  const TrendSoccerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrendSoccer',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: const _ComponentTestScreen(),
    );
  }
}

class _ComponentTestScreen extends StatefulWidget {
  const _ComponentTestScreen();

  @override
  State<_ComponentTestScreen> createState() => _ComponentTestScreenState();
}

class _ComponentTestScreenState extends State<_ComponentTestScreen> {
  // Checkbox states
  CheckboxState _cb1 = CheckboxState.unchecked;
  CheckboxState _cb2 = CheckboxState.checked;
  CheckboxState _cb3 = CheckboxState.partial;

  // Radio state
  int? _selectedOption;

  // Toggle states
  ToggleState _toggle1 = ToggleState.off;
  ToggleState _toggle2 = ToggleState.on;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox Section ──────────────────
            Text(
              'Checkbox Test',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildCheckboxRow('Unchecked', _cb1, (s) {
              setState(() => _cb1 = s);
              debugPrint('Checkbox 1 → $s');
            }),
            const SizedBox(height: AppSpacing.lg),
            _buildCheckboxRow('Checked', _cb2, (s) {
              setState(() => _cb2 = s);
              debugPrint('Checkbox 2 → $s');
            }),
            const SizedBox(height: AppSpacing.lg),
            _buildCheckboxRow('Partial', _cb3, (s) {
              setState(() => _cb3 = s);
              debugPrint('Checkbox 3 → $s');
            }),

            const SizedBox(height: AppSpacing.xxxl),
            const Divider(color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Radio Section ────────────────────
            Text(
              'Radio Button Test',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildRadioRow('Option 1', 0),
            const SizedBox(height: AppSpacing.lg),
            _buildRadioRow('Option 2', 1),
            const SizedBox(height: AppSpacing.lg),
            _buildRadioRow('Option 3', 2),

            const SizedBox(height: AppSpacing.xxxl),
            const Divider(color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Toggle Section ─────────────────────
            Text(
              'Toggle Switch Test',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildToggleRow('Off (default)', _toggle1, (s) {
              setState(() => _toggle1 = s);
              debugPrint('Toggle 1 → $s');
            }),
            const SizedBox(height: AppSpacing.lg),
            _buildToggleRow('On (default)', _toggle2, (s) {
              setState(() => _toggle2 = s);
              debugPrint('Toggle 2 → $s');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(
    String label,
    CheckboxState state,
    ValueChanged<CheckboxState> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCheckbox(state: state, onChanged: onChanged),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String label,
    ToggleState state,
    ValueChanged<ToggleState> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomToggle(state: state, onChanged: onChanged),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioRow(String label, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomRadio(
          state: _selectedOption == index
              ? RadioState.checked
              : RadioState.unchecked,
          onChanged: (_) {
            setState(() => _selectedOption = index);
            debugPrint('Radio ${index + 1} selected');
          },
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
