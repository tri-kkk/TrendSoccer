import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/tokens/color_tokens.dart';

/// Maps a league code to its corresponding SVG asset path and renders it.
///
/// Supports 15 leagues across two sports:
/// - **Soccer** (11): EPL, Laliga, Bundesliga, SerieA, Ligue 1, UCL, UEL,
///   Eredivisie, KLeague, J1League, MLS
/// - **Baseball** (4): KBO, MLB, NPB, CPBL
///
/// Falls back to a generic [Icons.sports] placeholder when the league code
/// is not recognised.
///
/// ```dart
/// LeagueIcon(league: 'EPL')
/// LeagueIcon(league: 'KBO', size: 24, color: AppColors.textPrimary)
/// ```
class LeagueIcon extends StatelessWidget {
  const LeagueIcon({
    super.key,
    required this.league,
    this.size = 16,
    this.color,
  });

  /// League code used to resolve the SVG asset (e.g. `'EPL'`, `'KBO'`).
  final String league;

  /// Width and height of the icon. Defaults to 16.
  final double size;

  /// Optional colour applied via [ColorFilter]. When `null` the SVG's
  /// original colours are preserved.
  final Color? color;

  static String _normalizeCode(String code) => code.trim().toUpperCase();

  static const String _kIconDark = 'assets/images/leagues/icon/dark/';

  static const Map<String, String> _assetMap = {
    // Soccer
    'EPL': '${_kIconDark}premier_league.svg',
    'LALIGA': '${_kIconDark}laliga.svg',
    'BUNDESLIGA': '${_kIconDark}bundesliga.svg',
    'SERIEA': '${_kIconDark}serie_a.svg',
    'LIGUE1': '${_kIconDark}ligue_1.svg',
    'UCL': '${_kIconDark}champions_league.svg',
    'UEL': '${_kIconDark}europa_league.svg',
    'EREDIVISIE': '${_kIconDark}eredivisie.svg',
    'KLEAGUE': '${_kIconDark}k_league.svg',
    'J1LEAGUE': '${_kIconDark}j1_league.svg',
    'MLS': '${_kIconDark}mls.svg',
    // Baseball
    'KBO': '${_kIconDark}kbo.svg',
    'MLB': '${_kIconDark}mlb.svg',
    'NPB': '${_kIconDark}npb.svg',
    'CPBL': '${_kIconDark}cpbl.svg',
  };

  /// Converts a league code to its display name.
  static String getLeagueName(String code) {
    final key = _normalizeCode(code);
    const Map<String, String> names = {
      'EPL': 'Premier League',
      'LALIGA': 'La Liga',
      'BUNDESLIGA': 'Bundesliga',
      'SERIEA': 'Serie A',
      'LIGUE1': 'Ligue 1',
      'UCL': 'Champions League',
      'UEL': 'Europa League',
      'EREDIVISIE': 'Eredivisie',
      'KLEAGUE': 'K League 1',
      'J1LEAGUE': 'J1 League',
      'MLS': 'MLS',
      'KBO': 'KBO',
      'MLB': 'MLB',
      'NPB': 'NPB',
      'CPBL': 'CPBL',
    };
    return names[key] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetMap[_normalizeCode(league)];

    if (path == null) {
      return Icon(
        Icons.sports,
        size: size,
        color: color ?? AppColors.textTertiary,
      );
    }

    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      placeholderBuilder: (_) => SizedBox.square(dimension: size),
    );
  }
}
