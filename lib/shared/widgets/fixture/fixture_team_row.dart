import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Single team line: 24×24 emblem, name, optional score (Figma node 755:57533).
class FixtureTeamRow extends StatelessWidget {
  const FixtureTeamRow({
    super.key,
    required this.teamName,
    this.logoUrl,
    this.score,
    required this.isHome,
  });

  final String teamName;
  final String? logoUrl;
  final int? score;
  final bool isHome;

  static const double _emblemSize = 24;
  static const double _emblemRadius = 12;

  @override
  Widget build(BuildContext context) {
    final nameStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textPrimary,
    );
    final scoreStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textPrimary,
    );

    return Semantics(
      label: isHome ? 'Home, $teamName' : 'Away, $teamName',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _emblem(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: nameStyle,
            ),
          ),
          if (score != null) ...[
            const SizedBox(width: AppSpacing.md),
            Text(
              '$score',
              textAlign: TextAlign.end,
              style: scoreStyle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _emblem() {
    final hasUrl = logoUrl != null && logoUrl!.trim().isNotEmpty;
    if (hasUrl) {
      return SizedBox(
        width: _emblemSize,
        height: _emblemSize,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: logoUrl!,
            width: _emblemSize,
            height: _emblemSize,
            fit: BoxFit.cover,
            placeholder: (context, url) => _initialAvatar(),
            errorWidget: (context, url, error) => _initialAvatar(),
          ),
        ),
      );
    }
    return _initialAvatar();
  }

  Widget _initialAvatar() {
    return CircleAvatar(
      radius: _emblemRadius,
      backgroundColor: AppColors.surfaceContainer,
      child: Text(
        _firstInitial(teamName),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  static String _firstInitial(String name) {
    final t = name.trim();
    if (t.isEmpty) {
      return '?';
    }
    return String.fromCharCode(t.runes.first).toUpperCase();
  }
}
