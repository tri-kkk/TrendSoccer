import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Visual variant for [SectionHeader].
enum SectionHeaderType {
  /// Title text only.
  defaultType,

  /// Title text with a "See All →" action link on the right.
  withAction,
}

/// A section heading row used to label content groups on a page.
///
/// Two variants controlled by [type]:
/// - [SectionHeaderType.defaultType]: renders only the title.
/// - [SectionHeaderType.withAction]: renders the title and a tappable
///   "See All →" link in a `spaceBetween` row.
///
/// Layout follows Figma node `618:30250`.
///
/// ```dart
/// SectionHeader(title: 'Today's Matches')
///
/// SectionHeader(
///   title: 'Reports',
///   type: SectionHeaderType.withAction,
///   onSeeAllTap: () {},
/// )
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.type = SectionHeaderType.defaultType,
    this.onSeeAllTap,
  });

  /// Section title text.
  final String title;

  /// Controls whether the "See All →" action link is shown.
  final SectionHeaderType type;

  /// Called when the "See All →" link is tapped.
  /// Only relevant when [type] is [SectionHeaderType.withAction].
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (type == SectionHeaderType.withAction)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                'See All →',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
