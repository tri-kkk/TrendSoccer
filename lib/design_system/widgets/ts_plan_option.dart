import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_radio.dart';

class TsPlanOption extends StatelessWidget {
  const TsPlanOption({
    required this.period,
    required this.price,
    this.priceNote,
    this.selected = false,
    this.discountLabel,
    this.onTap,
    super.key,
  });

  final String period;
  final String price;
  final String? priceNote;
  final bool selected;
  final String? discountLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TsSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? c.primaryMuted : c.surfaceRaised,
          borderRadius: TsRadius.md,
          border: Border.all(
            color: selected ? c.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            TsRadio(selected: selected, onTap: onTap),
            const SizedBox(width: TsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period,
                    style: TsType.bodyLBold.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: TsSpacing.xxs),
                  Text.rich(
                    TextSpan(
                      style: TsType.tabular(
                        TsType.h3.copyWith(
                          color: selected ? c.primary : c.textPrimary,
                        ),
                      ),
                      children: [
                        TextSpan(text: price),
                        if (priceNote != null) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: priceNote,
                            style: TsType.tabular(
                              TsType.bodyLRegular.copyWith(
                                color: selected ? c.primary : c.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
            if (discountLabel != null)
              TsBadge(label: discountLabel!, tone: TsBadgeTone.primary),
          ],
        ),
      ),
    );
  }
}
