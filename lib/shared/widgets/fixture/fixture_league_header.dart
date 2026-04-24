import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// League title row: optional 24×24 logo + name.
class FixtureLeagueHeader extends StatelessWidget {
  const FixtureLeagueHeader({
    super.key,
    required this.leagueName,
    this.logoUrl,
  });

  final String leagueName;
  final String? logoUrl;

  static const double _logo = 24;
  static const double _r = 12;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _logoOrInitial(),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            leagueName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _logoOrInitial() {
    final has = logoUrl != null && logoUrl!.trim().isNotEmpty;
    if (has) {
      return SizedBox(
        width: _logo,
        height: _logo,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: logoUrl!,
            width: _logo,
            height: _logo,
            fit: BoxFit.cover,
            placeholder: (context, url) => _initial(),
            errorWidget: (context, url, error) => _initial(),
          ),
        ),
      );
    }
    return _initial();
  }

  Widget _initial() {
    return CircleAvatar(
      radius: _r,
      backgroundColor: AppColors.surfaceContainer,
      child: Text(
        leagueName.isNotEmpty
            ? String.fromCharCode(leagueName.runes.first).toUpperCase()
            : '?',
        style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
