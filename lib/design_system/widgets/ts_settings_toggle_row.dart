import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_toggle.dart';

class TsSettingsToggleRow extends StatelessWidget {
  const TsSettingsToggleRow({
    required this.label,
    required this.value,
    this.description,
    this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final String? description;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final enabled = onChanged != null;
    final labelColor = enabled ? c.textPrimary : c.textDisabled;
    final descriptionColor = enabled ? c.textTertiary : c.textDisabled;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: TsSpacing.md,
        horizontal: TsSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TsType.bodyLMedium.copyWith(color: labelColor),
                ),
                if (description != null) ...[
                  const SizedBox(height: TsSpacing.xxs),
                  Text(
                    description!,
                    style: TsType.labelSRegular.copyWith(
                      color: descriptionColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: TsSpacing.md),
          TsToggle(
            value: enabled ? value : false,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
