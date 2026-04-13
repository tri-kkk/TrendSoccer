import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A card for displaying a single news article.
///
/// Renders a text area (source + date meta row, title) on the left and an
/// 80×80 thumbnail on the right, vertically centered.
///
/// Layout follows Figma node `654:20971`.
///
/// ```dart
/// NewsCard(
///   source: 'ESPN',
///   date: '04.13',
///   title: 'Premier League: Weekend Preview',
///   onTap: () {},
/// )
/// ```
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.source,
    required this.date,
    required this.title,
    this.onTap,
  });

  /// News outlet or author name (e.g. "ESPN").
  final String source;

  /// Publication date string (e.g. "04.13").
  final String date;

  /// Headline / title of the article.
  final String title;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(AppSpacing.xl),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildTextArea()),
            const SizedBox(width: AppSpacing.xl),
            _buildThumbnail(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              source,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              date,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Icon(
        Icons.newspaper_outlined,
        size: AppSpacing.iconSize,
        color: AppColors.textTertiary,
      ),
    );
  }
}
