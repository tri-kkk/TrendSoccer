import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  // Set to false before release
  static const bool _useTestAds = false;

  // Production IDs
  static const String _prodTrendBanner =
      'ca-app-pub-7853814871438044/5988937231';
  static const String _prodAnalysisBanner =
      'ca-app-pub-7853814871438044/9736610556';
  static const String _prodFixtureBanner =
      'ca-app-pub-7853814871438044/9648980645';

  // Google official test banner ID
  static const String _testBanner =
      'ca-app-pub-3940256099942544/6300978111';

  static final Completer<void> _readyCompleter = Completer<void>();

  static bool _initAttempted = false;
  static bool _initSucceeded = false;

  static Future<void> get ready => _readyCompleter.future;

  static bool get initSucceeded => _initSucceeded;

  static String get trendBannerAdUnitId =>
      _useTestAds ? _testBanner : _prodTrendBanner;
  static String get analysisBannerAdUnitId =>
      _useTestAds ? _testBanner : _prodAnalysisBanner;
  static String get fixtureBannerAdUnitId =>
      _useTestAds ? _testBanner : _prodFixtureBanner;

  static Future<void> initialize() async {
    if (_initAttempted) {
      return ready;
    }
    _initAttempted = true;

    try {
      await MobileAds.instance.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('AdmobService.initialize'),
      );
      _initSucceeded = true;
    } on Object {
      _initSucceeded = false;
    } finally {
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }
  }
}
