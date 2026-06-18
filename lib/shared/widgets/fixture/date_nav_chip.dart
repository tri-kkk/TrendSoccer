import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

enum DateNavChipType { today, live, date }

const _dateNavChipHeight = 40.0;

class DateNavChip extends StatelessWidget {
  const DateNavChip({
    required this.type,
    this.isActive = false,
    this.dayLabel,
    this.dateLabel,
    this.onTap,
    this.expandWidth = false,
    super.key,
  });

  final DateNavChipType type;
  final bool isActive;
  final String? dayLabel;
  final String? dateLabel;
  final VoidCallback? onTap;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: switch (type) {
        DateNavChipType.today => _TodayChip(
          semantic: semantic,
          isActive: isActive,
          dayLabel: dayLabel ?? l10n.today,
          dateLabel: dateLabel ?? '',
          expandWidth: expandWidth,
        ),
        DateNavChipType.live => _LiveChip(
          semantic: semantic,
          isActive: isActive,
        ),
        DateNavChipType.date => _DateChip(
          semantic: semantic,
          isActive: isActive,
          dayLabel: dayLabel ?? '',
          dateLabel: dateLabel ?? '',
          expandWidth: expandWidth,
        ),
      },
    );
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip({
    required this.semantic,
    required this.isActive,
    required this.dayLabel,
    required this.dateLabel,
    this.expandWidth = false,
  });

  final TsSemanticColors semantic;
  final bool isActive;
  final String dayLabel;
  final String dateLabel;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    final dayStyle = TsType.labelSRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textTertiary,
    );
    final dateStyle = TsType.bodyLRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textSecondary,
    );

    return SizedBox(
      height: _dateNavChipHeight,
      width: expandWidth ? double.infinity : null,
      child: Container(
        width: expandWidth ? double.infinity : null,
        constraints: expandWidth ? null : const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? semantic.interactivePrimary : semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dayLabel, style: dayStyle),
            const SizedBox(height: TsSpacing.xxs),
            Text(dateLabel, style: dateStyle),
          ],
        ),
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip({
    required this.semantic,
    required this.isActive,
  });

  final TsSemanticColors semantic;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final textStyle = TsType.bodyLRegular.copyWith(
      color: isActive ? semantic.textPrimary : semantic.textTertiary,
    );

    return SizedBox(
      height: _dateNavChipHeight,
      child: Container(
        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? TsColors.systemError500 : semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text('LIVE', style: textStyle),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.semantic,
    required this.isActive,
    required this.dayLabel,
    required this.dateLabel,
    this.expandWidth = false,
  });

  final TsSemanticColors semantic;
  final bool isActive;
  final String dayLabel;
  final String dateLabel;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    final dayStyle = TsType.labelSRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textTertiary,
    );
    final dateStyle = TsType.bodyLRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textSecondary,
    );

    return SizedBox(
      height: _dateNavChipHeight,
      width: expandWidth ? double.infinity : null,
      child: Container(
        width: expandWidth ? double.infinity : null,
        constraints: expandWidth ? null : const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? semantic.interactivePrimary : semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dayLabel, style: dayStyle),
            const SizedBox(height: TsSpacing.xxs),
            Text(dateLabel, style: dateStyle),
          ],
        ),
      ),
    );
  }
}
