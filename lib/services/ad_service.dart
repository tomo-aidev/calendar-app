// AdMob広告サービス - 次フェーズで有効化
// コメントアウト: google_mobile_ads依存を一時的に無効化

/*
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/constants.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  /// Whether ads are supported on the current platform
  bool get isSupported => !kIsWeb;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Get the banner ad unit ID for the current platform
  String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return AppConstants.adMobBannerIdAndroid;
    if (Platform.isIOS) return AppConstants.adMobBannerIdIos;
    return '';
  }

  /// Create a BannerAd instance
  BannerAd createBannerAd({
    BannerAdSize size = AdSize.banner,
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded ?? (_) {},
        onAdFailedToLoad: onAdFailedToLoad ??
            (ad, error) {
              debugPrint('Ad failed to load: $error');
              ad.dispose();
            },
      ),
    );
  }
}

typedef BannerAdSize = AdSize;
*/
