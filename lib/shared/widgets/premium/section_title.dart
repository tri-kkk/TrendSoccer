import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// An expandable section header with a title and a chevron icon.
///
/// ```dart
/// SectionTitle(
///   title: "H2H",
///   isExpanded: isH2HExpanded,
///   onTap: () => setState(() => isH2HExpanded = !isH2HExpanded),
/// )
/// ```
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
