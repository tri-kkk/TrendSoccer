import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/admob_service.dart';

class PremiumAdWrapper extends ConsumerStatefulWidget {
  const PremiumAdWrapper({required this.adUnitId, super.key});

  final String adUnitId;

  @override
  ConsumerState<PremiumAdWrapper> createState() => _PremiumAdWrapperState();
}

class _PremiumAdWrapperState extends ConsumerState<PremiumAdWrapper> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleAdLoad();
  }

  void _scheduleAdLoad() {
    if (_loadScheduled) return;
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadAdWhenReady());
    });
  }

  Future<void> _loadAdWhenReady() async {
    await AdmobService.ready;
    if (!mounted || !AdmobService.initSucceeded) return;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
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
