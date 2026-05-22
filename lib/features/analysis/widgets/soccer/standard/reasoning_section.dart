import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class ReasoningDisplayItem {
  const ReasoningDisplayItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class ReasoningSection extends StatelessWidget {
  const ReasoningSection({required this.items, super.key});

  final List<ReasoningDisplayItem> items;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '분석 근거',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: semantic.interactivePrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Expanded(
                      child: items[i].value.isEmpty
                          ? Text(
                              items[i].label,
                              style: TsType.bodyLRegular.copyWith(
                                color: semantic.textPrimary,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    items[i].label,
                                    style: TsType.bodyLRegular.copyWith(
                                      color: semantic.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: TsSpacing.sm),
                                Text(
                                  items[i].value,
                                  style: TsType.bodyLRegular.copyWith(
                                    color: semantic.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
