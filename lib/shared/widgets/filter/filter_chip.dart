import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide FilterChip;

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../league/league_icon.dart';

/// Visual style for [FilterChip]: label only, asset [LeagueIcon], or [logoUrl] image.
enum FilterChipType { textOnly, withIcon, withAPI }

/// A pill-shaped chip for filtering content by league or category (Figma `624:21568`).
///
/// - **WithAPI**: 16×16 [CachedNetworkImage] + label; [logoUrl] null/empty uses `?` fallback.
/// - **WithIcon** [LeagueIcon] (asset) at 16px + label, same padding/colors as WithAPI.
/// - **TextOnly**: label only.
///
/// [iconPath] is the league key passed to [LeagueIcon] (e.g. `'EPL'`, `'KBO'`).
///
/// ```dart
/// FilterChip(
///   text: 'All',
///   isSelected: true,
///   onTap: () {},
///   type: FilterChipType.textOnly,
/// )
///
/// FilterChip(
///   text: 'Europa League',
///   isSelected: false,
///   onTap: () {},
///   type: FilterChipType.withIcon,
///   iconPath: 'UEL',
/// )
/// ```
class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.type = FilterChipType.textOnly,
    this.iconPath,
    this.logoUrl,
  });

  static const double _leadingGap = 6;
  static const double _apiLogoSize = 16;
  static const double _apiLogoRadius = 8;

  /// Display text inside the chip.
  final String text;

  /// Whether this chip is currently active.
  final bool isSelected;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  final FilterChipType type;

  /// For [FilterChipType.withIcon]: key for [LeagueIcon] (e.g. `'EPL'`).
  final String? iconPath;

  /// For [FilterChipType.withAPI]: network URL for the 16×16 logo.
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isSelected ? AppColors.primary500 : AppColors.surfaceContainer;
    final textColor =
        isSelected ? AppColors.surfaceBase : AppColors.textSecondary;
    final textStyle = AppTypography.labelMedium.copyWith(color: textColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == FilterChipType.withIcon && iconPath != null) ...[
              LeagueIcon(league: iconPath!, size: 16),
              const SizedBox(width: _leadingGap),
            ],
            if (type == FilterChipType.withAPI) ...[
              _buildApiLogo(),
              const SizedBox(width: _leadingGap),
            ],
            Text(
              text,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiLogo() {
    final hasUrl = logoUrl != null && logoUrl!.trim().isNotEmpty;
    if (hasUrl) {
      return SizedBox(
        width: _apiLogoSize,
        height: _apiLogoSize,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: logoUrl!,
            width: _apiLogoSize,
            height: _apiLogoSize,
            fit: BoxFit.cover,
            placeholder: (context, url) => _apiLogoFallback(),
            errorWidget: (context, url, error) => _apiLogoFallback(),
          ),
        ),
      );
    }
    return _apiLogoFallback();
  }

  Widget _apiLogoFallback() {
    final markColor = isSelected ? AppColors.surfaceBase : AppColors.textSecondary;
    return CircleAvatar(
      radius: _apiLogoRadius,
      backgroundColor: AppColors.surfaceContainer,
      child: Text(
        '?',
        style: AppTypography.labelSmall.copyWith(
          color: markColor,
          fontSize: 10,
        ),
      ),
    );
  }
}
