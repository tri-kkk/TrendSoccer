import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

final Map<String, Future<String?>> _leagueIconSvgFutures = {};

Future<String?> _loadLeagueIconSvg(String path) =>
    _leagueIconSvgFutures.putIfAbsent(path, () async {
      try {
        return await rootBundle.loadString(path);
      } catch (_) {
        return null;
      }
    });

String _leagueInitials(String leagueId) {
  final t = leagueId.trim();
  if (t.isEmpty) {
    return '--';
  }
  if (t.length == 1) {
    return t.toUpperCase();
  }
  return t.substring(0, 2).toUpperCase();
}

class TsLeagueIcon extends StatelessWidget {
  const TsLeagueIcon({
    required this.leagueId,
    this.size = 16,
    super.key,
  });

  final String leagueId;
  final double size;

  Widget _fallback(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final radius = size / 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        _leagueInitials(leagueId),
        style: TsType.labelXsBold.copyWith(color: semantic.textTertiary),
      ),
    );
  }

  String _assetPath(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final folder = brightness == Brightness.dark ? 'dark' : 'light';
    return 'assets/images/leagues/icon/$folder/$leagueId.svg';
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetPath(context);

    return FutureBuilder<String?>(
      future: _loadLeagueIconSvg(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(width: size, height: size);
        }
        final svg = snapshot.data;
        if (svg == null || svg.isEmpty) {
          return _fallback(context);
        }
        return SvgPicture.string(
          svg,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (BuildContext context) => _fallback(context),
        );
      },
    );
  }
}
