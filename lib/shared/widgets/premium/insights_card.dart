import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({required this.comments, super.key});

  final List<String> comments;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < comments.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i < comments.length - 1 ? TsSpacing.sm : 0,
              ),
              child: Text(
                comments[i],
                style: TsType.bodyMRegular.copyWith(
                  color: semantic.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
