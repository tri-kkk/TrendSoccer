import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// LIVE rail chip vs calendar day chip (fixture date strip).
enum DateNavChipType { live, day }

/// One item in the horizontal date rail. Use [type] = [DateNavChipType.live]
/// for the all-live filter chip, or [DateNavChipType.day] for a calendar day.
class DateNavChip extends StatelessWidget {
  const DateNavChip({
    super.key,
    this.type = DateNavChipType.day,
    this.date,
    this.isToday = false,
    required this.isSelected,
    this.onTap,
  });

  final DateNavChipType type;
  final DateTime? date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (type == DateNavChipType.live) {
      return _liveBody();
    }
    return _dayBody();
  }

  Widget _liveBody() {
    final bg = isSelected
        ? AppColors.errorRed500
        : AppColors.surfaceContainer;
    final fg = isSelected ? AppColors.surfaceBase : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'LIVE',
            textAlign: TextAlign.center,
            style: AppTypography.labelLarge.copyWith(color: fg, height: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _dayBody() {
    final d = date;
    if (d == null) {
      return const SizedBox.shrink();
    }
    final bg = isSelected ? AppColors.primary500 : AppColors.surfaceContainer;
    final fg = isSelected ? AppColors.surfaceBase : AppColors.textSecondary;
    final lineStyle = AppTypography.labelSmall.copyWith(
      color: fg,
      height: 1.2,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isToday
            ? _todayBody(d, lineStyle, fg)
            : _standardBody(d, lineStyle),
      ),
    );
  }

  Widget _todayBody(DateTime d, TextStyle lineStyle, Color fg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('Today', style: lineStyle.copyWith(color: fg)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('M.d', 'en_US').format(d),
          style: lineStyle,
        ),
      ],
    );
  }

  Widget _standardBody(DateTime d, TextStyle lineStyle) {
    return Text(
      '${DateFormat('EEE', 'en_US').format(d)}\n${DateFormat('M.d', 'en_US').format(d)}',
      textAlign: TextAlign.center,
      style: lineStyle,
    );
  }
}
