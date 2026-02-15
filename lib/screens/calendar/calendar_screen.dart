// import 'package:flutter/foundation.dart'; // 次フェーズで有効化（AdMob用）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // 次フェーズで有効化
import '../../config/colors.dart';
import '../../providers/calendar_provider.dart';
// import '../../services/ad_service.dart'; // 次フェーズで有効化
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_list.dart';
import 'widgets/month_navigation.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // 次フェーズで有効化: AdMob関連
  // BannerAd? _bannerAd;
  // bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // _loadBannerAd(); // 次フェーズで有効化
  }

  // 次フェーズで有効化: AdMobバナー読み込み
  // void _loadBannerAd() {
  //   if (kIsWeb || !AdService.instance.isSupported) return;
  //   _bannerAd = AdService.instance.createBannerAd(
  //     onAdLoaded: (ad) {
  //       setState(() => _isBannerAdLoaded = true);
  //     },
  //     onAdFailedToLoad: (ad, error) {
  //       debugPrint('Banner ad failed to load: $error');
  //       ad.dispose();
  //       _bannerAd = null;
  //     },
  //   )..load();
  // }

  @override
  void dispose() {
    // _bannerAd?.dispose(); // 次フェーズで有効化
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGridView = ref.watch(isGridViewProvider);

    return SafeArea(
      child: Column(
        children: [
          // 次フェーズで有効化: AdMobバナー
          // if (_isBannerAdLoaded && _bannerAd != null)
          //   SizedBox(
          //     width: double.infinity,
          //     height: _bannerAd!.size.height.toDouble(),
          //     child: AdWidget(ad: _bannerAd!),
          //   )
          // else
          //   Container(
          //     width: double.infinity,
          //     height: 50,
          //     color: Colors.grey[200],
          //     child: const Center(
          //       child: Text(
          //         'AdMob Banner',
          //         style: TextStyle(color: Colors.grey),
          //       ),
          //     ),
          //   ),
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              border: Border(
                bottom: BorderSide(color: AppColors.red, width: 2),
              ),
            ),
            child: const Center(
              child: Text(
                '\u2728 \u5e78\u904b\u30ab\u30ec\u30f3\u30c0\u30fc \u2728',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Month navigation + view toggle
          const MonthNavigation(),
          // Calendar body
          Expanded(
            child: isGridView
                ? const CalendarGrid()
                : const CalendarList(),
          ),
        ],
      ),
    );
  }
}
