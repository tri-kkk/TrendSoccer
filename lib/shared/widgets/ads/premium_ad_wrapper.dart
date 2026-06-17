import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';

class PremiumAdWrapper extends ConsumerStatefulWidget {
  const PremiumAdWrapper({required this.adUnitId, super.key});

  final String adUnitId;

  @override
  ConsumerState<PremiumAdWrapper> createState() => _PremiumAdWrapperState();
}

class _PremiumAdWrapperState extends ConsumerState<PremiumAdWrapper> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ADMOB] widget mounted: ${widget.adUnitId}');
        _loadAd();
  }

  void _loadAd() {
        _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[ADMOB] loaded: ${widget.adUnitId}');
                    if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[ADMOB] FAILED: code=${error.code}, msg=${error.message}');
                    ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (auth.hasFullAccess) return const SizedBox.shrink();

    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Center(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
