import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Left column for fixture rows: time, LIVE, or FT (56px, Figma node 755:57632).
///
/// [status] is typically `scheduled`, `live`, or `finished` (case-insensitive).
/// [time] is required for scheduled (e.g. `14:30` from [DateTime] formatting).
class FixtureStatusWidget extends StatelessWidget {
  const FixtureStatusWidget({
    super.key,
    required this.status,
    this.time,
  });

  final String status;
  final String? time;

  static const double _width = 56;
  static const double _statusDotSize = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Center(child: _body()),
    );
  }

  Widget _body() {
    final normalized = status.toLowerCase();
    final tertiaryMuted =
        AppColors.textTertiary.withValues(alpha: 0.5);
    final baseStyle = AppTypography.labelSmall;

    switch (normalized) {
      case 'live':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _statusDotSize,
              height: _statusDotSize,
              decoration: const BoxDecoration(
                color: AppColors.errorRed500,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'LIVE',
              style: baseStyle.copyWith(color: AppColors.errorRed500),
            ),
          ],
        );
      case 'finished':
        return Text(
          'FT',
          style: baseStyle.copyWith(color: tertiaryMuted),
        );
      case 'scheduled':
      default:
        return Text(
          time ?? '—',
          style: baseStyle.copyWith(color: tertiaryMuted),
        );
    }
  }
}
