import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Determines the visual layout of [ReportCard].
enum ReportCardSize {
  /// 380 × Hug — horizontal layout with 96×96 thumbnail on the left.
  large,

  /// 160 × Hug — vertical layout with full-width thumbnail on top.
  small,
}

/// A card displaying an analysis report with a thumbnail, title, and
/// description.
///
/// Supports two layouts controlled by [size]:
/// - [ReportCardSize.large]: side-by-side (96×96 thumbnail + date/title/desc).
/// - [ReportCardSize.small]: stacked (full-width×80 thumbnail / title/desc).
///
/// Layout follows Figma node `654:20951`.
///
/// ```dart
/// ReportCard(
///   size: ReportCardSize.large,
///   title: 'Chelsea vs Arsenal Match Report',
///   description: 'A deep-dive into the key moments...',
///   date: '04.13',
///   onTap: () {},
/// )
/// ```
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.size,
    required this.title,
    this.date,
    this.description,
    this.onTap,
  });

  /// Controls the card layout variant.
  final ReportCardSize size;

  /// Report title text.
  final String title;

  /// Date label shown only in the [ReportCardSize.large] variant.
  final String? date;

  /// Optional short description or excerpt.
  final String? description;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  bool get _isLarge => size == ReportCardSize.large;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _isLarge ? 380 : 160,
        padding: const EdgeInsets.all(AppSpacing.xl),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: _isLarge ? _buildLargeLayout() : _buildSmallLayout(),
      ),
    );
  }

  Widget _buildLargeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildThumbnail(width: 96, height: 96, iconSize: 32),
        const SizedBox(width: AppSpacing.xl),
        Expanded(child: _buildLargeTextColumn()),
      ],
    );
  }

  Widget _buildSmallLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(
          width: double.infinity,
          height: 80,
          iconSize: AppSpacing.iconSize,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSmallTextColumn(),
      ],
    );
  }

  Widget _buildThumbnail({
    required double width,
    required double height,
    required double iconSize,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        Icons.article_outlined,
        size: iconSize,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildLargeTextColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (date != null)
          Text(
            date!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        if (date != null) const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            description!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildSmallTextColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            description!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
