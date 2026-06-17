import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static const String trendBannerAdUnitId =
      'ca-app-pub-7853814871438044/5988937231';
  static const String analysisBannerAdUnitId =
      'ca-app-pub-7853814871438044/9736610556';
  static const String fixtureBannerAdUnitId =
      'ca-app-pub-7853814871438044/9648980645';

  // For testing, use test ad unit IDs:
  // static const String testBannerAdUnitId =
  //     'ca-app-pub-3940256099942544/6300978111';

  static Future<void> initialize() async {
        await MobileAds.instance.initialize();
    debugPrint('[ADMOB] init complete');
      }
}
