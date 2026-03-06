import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'screens/anniversary/anniversary_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/fortune/fortune_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/work_schedule/work_schedule_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_scheduler.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'providers/anniversary_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/work_entry_provider.dart';

class LuckyCalendarApp extends StatelessWidget {
  const LuckyCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: StorageService.instance.hasProfile
          ? const MainScreen()
          : const ProfileSetupScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  // AdMob関連
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  /// Android includes fortune tab
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  List<Widget> get _screens {
    if (_isAndroid) {
      return const [
        CalendarScreen(), // 0
        WorkScheduleScreen(), // 1
        FortuneScreen(), // 2 (Android only)
        AnniversaryScreen(), // 3
        SettingsScreen(), // 4
      ];
    } else {
      return const [
        CalendarScreen(), // 0
        WorkScheduleScreen(), // 1
        AnniversaryScreen(), // 2
        SettingsScreen(), // 3
      ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: 'カレンダー',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.work_outline),
        label: 'シフト・在宅管理',
      ),
    ];

    if (_isAndroid) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.auto_awesome),
        label: '今日の運勢',
      ));
    }

    items.addAll(const [
      BottomNavigationBarItem(
        icon: Icon(Icons.cake_outlined),
        label: '記念日',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: '設定',
      ),
    ]);

    return items;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAd();
    // Load data from Hive on app startup
    Future.microtask(() async {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(scheduleProvider.notifier).loadSchedules();
      ref.read(anniversaryProvider.notifier).loadAnniversaries();
      ref.read(workEntryProvider.notifier).loadWorkEntries();
      ref.read(workScheduleConfigsProvider.notifier).loadConfigs();
      ref.read(excludedWorkDatesProvider.notifier).load();
      // Schedule notifications after data is loaded
      await NotificationScheduler.instance.rescheduleAllNotifications();
    });

    // Register notification tap handler
    NotificationService.instance.onNotificationTap = _handleNotificationTap;
    // Consume any pending payload from cold start
    NotificationService.instance.consumePendingPayload();
  }

  void _loadBannerAd() {
    if (kIsWeb || !AdService.instance.isSupported) return;
    _bannerAd = AdService.instance.createBannerAd(
      onAdLoaded: (ad) {
        setState(() => _isBannerAdLoaded = true);
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: $error');
        ad.dispose();
        _bannerAd = null;
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.instance.onNotificationTap = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset to today's month when app is resumed
      final now = DateTime.now();
      final todayMonth = DateTime(now.year, now.month, 1);
      ref.read(currentMonthProvider.notifier).state = todayMonth;
      ref.invalidate(monthCalendarProvider(todayMonth));
      // Reschedule notifications (rolling window update)
      NotificationScheduler.instance.rescheduleAllNotifications();
    }
  }

  void _handleNotificationTap(String payload) {
    if (payload.startsWith('schedule:') ||
        payload.startsWith('work_reminder:') ||
        payload.startsWith('lucky_day:')) {
      // Navigate to Calendar screen (tab index 0)
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          // AdMobバナー（フッター）
          if (_isBannerAdLoaded && _bannerAd != null)
            SizedBox(
              width: double.infinity,
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: _navItems,
      ),
    );
  }
}
