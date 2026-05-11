import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TsSectionHeader extends StatelessWidget {
  const TsSectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final titleStyle = TsType.headingH3.copyWith(color: semantic.textPrimary);
    final actionStyle =
        TsType.bodyLRegular.copyWith(color: semantic.textSecondary);

    return Row(
      children: [
        if (actionText != null)
          Expanded(
            child: Text(
              title,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(title, style: titleStyle),
        if (actionText != null) ...[
          const SizedBox(width: TsSpacing.lg),
          GestureDetector(
            onTap: onAction,
            child: Text(actionText!, style: actionStyle),
          ),
        ],
      ],
    );
  }
}
