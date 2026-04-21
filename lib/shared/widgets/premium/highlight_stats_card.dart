import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A highlighted stats tile with an accent border, used for key metrics.
///
/// ```dart
/// HighlightStatsCard(value: "60%", label: "O 2.5")
/// HighlightStatsCard(value: "80%", label: "BTTS")
/// ```
class HighlightStatsCard extends StatelessWidget {
  const HighlightStatsCard({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x3300DF81),
        border: Border.all(color: AppColors.accent, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
