import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

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
  const TsLeagueIcon(
    this.leagueId, {
    this.size = TsIconSize.xs,
    this.logoUrl,
    this.isActive = false,
    this.preferAsset = true,
    super.key,
  });

  final String leagueId;
  final double size;
  final String? logoUrl;
  final bool isActive;
  final bool preferAsset;

  TsThemeColors _colors(BuildContext context) =>
      Theme.of(context).extension<TsThemeColors>()!;

  Brightness _effectiveBrightness(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (!isActive) return brightness;
    return brightness == Brightness.dark ? Brightness.light : Brightness.dark;
  }

  String _assetPath(BuildContext context) =>
      TsAssets.leagueIcon(leagueId, _effectiveBrightness(context));

  Widget _initialsCircle(BuildContext context) {
    final c = _colors(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _leagueInitials(leagueId),
        style: TsType.labelXsBold.copyWith(color: c.textTertiary),
      ),
    );
  }

  Widget _networkLogo(BuildContext context, {required Widget onMissing}) {
    final url = logoUrl;
    if (url == null || url.isEmpty) {
      return onMissing;
    }
    final c = _colors(context);
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c.surfaceRaised,
              shape: BoxShape.circle,
            ),
          ),
          errorWidget: (context, url, error) => _initialsCircle(context),
        ),
      ),
    );
  }

  Widget _bundledSvg(BuildContext context, {required Widget onMissing}) {
    final path = _assetPath(context);
    return FutureBuilder<String?>(
      future: _loadLeagueIconSvg(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(width: size, height: size);
        }
        final svg = snapshot.data;
        if (svg == null || svg.isEmpty) {
          return onMissing;
        }
        return SvgPicture.string(
          svg,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (BuildContext context) => onMissing,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initialsCircle(context);
    if (preferAsset) {
      return _bundledSvg(
        context,
        onMissing: _networkLogo(context, onMissing: initials),
      );
    }
    return _networkLogo(
      context,
      onMissing: _bundledSvg(context, onMissing: initials),
    );
  }
}

class TsLeagueLogo extends StatelessWidget {
  const TsLeagueLogo(this.leagueId, {this.height = 40, super.key});

  final String leagueId;
  final double height;

  @override
  Widget build(BuildContext context) {
    final path =
        TsAssets.leagueLogo(leagueId, Theme.of(context).brightness);
    return SvgPicture.asset(
      path,
      height: height,
      errorBuilder: (_, _, _) => SizedBox(height: height),
    );
  }
}
