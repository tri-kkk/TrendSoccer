import 'package:flutter/material.dart';

import '../../../core/models/soccer_match_report.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../../../shared/widgets/report/report_section_card.dart';

class ReasoningSection extends StatelessWidget {
  const ReasoningSection({
    super.key,
    required this.items,
    required this.isBlurred,
    required this.blurText,
  });

  final List<ReasoningItem> items;
  final bool isBlurred;
  final String blurText;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Reasoning',
      isBlurred: isBlurred,
      blurText: blurText,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 8 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    item.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.value,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
