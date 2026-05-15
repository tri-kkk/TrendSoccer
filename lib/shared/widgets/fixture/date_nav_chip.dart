import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum DateNavChipType { today, live, date }

class DateNavChip extends StatelessWidget {
  const DateNavChip({
    required this.type,
    this.isActive = false,
    this.dayLabel,
    this.dateLabel,
    this.onTap,
    super.key,
  });

  final DateNavChipType type;
  final bool isActive;
  final String? dayLabel;
  final String? dateLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: switch (type) {
        DateNavChipType.today => _TodayChip(
          semantic: semantic,
          isActive: isActive,
          dayLabel: dayLabel ?? 'Today',
          dateLabel: dateLabel ?? '',
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
  });

  final TsSemanticColors semantic;
  final bool isActive;
  final String dayLabel;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final dayStyle = TsType.labelSRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textTertiary,
    );
    final dateStyle = TsType.bodyLRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textSecondary,
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? semantic.interactivePrimary : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayLabel, style: dayStyle),
          const SizedBox(height: 2),
          Text(dateLabel, style: dateStyle),
        ],
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? TsColors.systemError500 : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
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
  });

  final TsSemanticColors semantic;
  final bool isActive;
  final String dayLabel;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final dayStyle = TsType.labelSRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textTertiary,
    );
    final dateStyle = TsType.bodyLRegular.copyWith(
      color: isActive ? semantic.surfaceBase : semantic.textSecondary,
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? semantic.interactivePrimary : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayLabel, style: dayStyle),
          const SizedBox(height: 2),
          Text(dateLabel, style: dateStyle),
        ],
      ),
    );
  }
}
