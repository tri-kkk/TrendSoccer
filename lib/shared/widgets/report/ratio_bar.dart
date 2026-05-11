import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class RatioSegment {
  const RatioSegment({
    required this.flex,
    required this.color,
    this.label,
    this.bottomLabel,
  });

  final double flex;
  final Color color;
  final String? label;
  final String? bottomLabel;
}

class RatioBar extends StatelessWidget {
  const RatioBar({
    required this.segments,
    this.height = 8,
    this.showLabels = true,
    this.borderRadius = 8,
    super.key,
  });

  final List<RatioSegment> segments;
  final double height;
  final bool showLabels;
  final double borderRadius;

  int _flexValue(double flex) {
    final raw = (flex * 100).round();
    return raw < 1 ? 1 : raw;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Row(
              children: [
                for (final segment in segments)
                  Expanded(
                    flex: _flexValue(segment.flex),
                    child: ColoredBox(
                      color: segment.color,
                      child: segment.label != null
                          ? Center(
                              child: Text(
                                segment.label!,
                                style: TsType.headingH3.copyWith(
                                  color: semantic.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: TsSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < segments.length; i++)
                Expanded(
                  child: Text(
                    segments[i].bottomLabel ?? '',
                    style: TsType.labelSRegular.copyWith(
                      color: semantic.textTertiary,
                    ),
                    textAlign: _textAlignForIndex(i, segments.length),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  TextAlign _textAlignForIndex(int index, int length) {
    if (length <= 1) return TextAlign.center;
    if (index == 0) return TextAlign.start;
    if (index == length - 1) return TextAlign.end;
    return TextAlign.center;
  }
}
