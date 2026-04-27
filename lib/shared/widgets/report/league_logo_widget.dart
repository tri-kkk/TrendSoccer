import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Maps [leagueId] keys to bundled report league logo filenames (light/dark).
const Map<String, (String light, String dark)> _kLeagueLogoFiles = {
  'ucl': (
    'League Logo_Report_Light_Champions League.svg',
    'League Logo_Report_Dark_Champions League.svg',
  ),
  'epl': (
    'League Logo_Report_Light_Premier League.svg',
    'League Logo_Report_Dark_Premier League.svg',
  ),
  'laliga': (
    'League Logo_Report_Light_LaLiga.svg',
    'League Logo_Report_Dark_LaLiga.svg',
  ),
  'kleague': (
    'League Logo_Report_Light_K League.svg',
    'League Logo_Report_Dark_K League.svg',
  ),
};

/// League mark for report headers — height 24, width from SVG aspect ratio.
class LeagueLogoWidget extends StatelessWidget {
  const LeagueLogoWidget({
    super.key,
    required this.leagueId,
  });

  final String leagueId;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final key = leagueId.toLowerCase().trim();
    final files = _kLeagueLogoFiles[key];
    if (files == null) {
      return _FallbackLabel(leagueId: leagueId);
    }
    final fileName = isDark ? files.$2 : files.$1;
    final path =
        'assets/images/leagues/logo/${isDark ? 'dark' : 'light'}/$fileName';

    return SizedBox(
      height: 24,
      child: SvgPicture.asset(
        path,
        height: 24,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(height: 24, width: 32),
        // If asset is missing, framework reports in debug; keep [leagueId] map accurate.
      ),
    );
  }
}

class _FallbackLabel extends StatelessWidget {
  const _FallbackLabel({required this.leagueId});

  final String leagueId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        leagueId.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
