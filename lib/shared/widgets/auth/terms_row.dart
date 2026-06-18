import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/checkbox/ts_checkbox.dart';

class TermsRow extends StatelessWidget {
  const TermsRow({
    required this.title,
    this.isRequired = true,
    this.isChecked = false,
    this.onChanged,
    this.onViewTap,
    super.key,
  });

  final String title;
  final bool isRequired;
  final bool isChecked;
  final VoidCallback? onChanged;
  final VoidCallback? onViewTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TsCheckBox(
          state: isChecked ? TsCheckBoxState.checked : TsCheckBoxState.unchecked,
          onChanged: onChanged,
        ),
        const SizedBox(width: TsSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: TsSpacing.xxs),
          decoration: BoxDecoration(
            color: isRequired ? semantic.interactivePrimary : semantic.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isRequired ? l10n.signupRequiredBadge : l10n.signupOptionalBadge,
            style: TsType.labelSBold.copyWith(
              color: isRequired ? semantic.surfaceBase : semantic.textTertiary,
            ),
          ),
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
        if (onViewTap != null)
          GestureDetector(
            onTap: onViewTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              l10n.signupView,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ),
      ],
    );
  }
}
