import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/radio/ts_radio_button.dart';

class AgreeToAllRow extends StatelessWidget {
  const AgreeToAllRow({
    this.isChecked = false,
    this.onChanged,
    super.key,
  });

  final bool isChecked;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg, vertical: TsSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TsRadioButton(selected: isChecked, onChanged: onChanged),
          const SizedBox(width: TsSpacing.md),
          Expanded(
            child: Text(
              l10n.signupAgreeAll,
              style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
