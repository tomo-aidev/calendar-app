import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'screens/anniversary/anniversary_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/fortune/fortune_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'providers/anniversary_provider.dart';
import 'providers/schedule_provider.dart';

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

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    CalendarScreen(),
    FortuneScreen(),
    AnniversaryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data from Hive on app startup
    Future.microtask(() {
      ref.read(scheduleProvider.notifier).loadSchedules();
      ref.read(anniversaryProvider.notifier).loadAnniversaries();
    });

    // Register notification tap handler
    NotificationService.instance.onNotificationTap = _handleNotificationTap;
    // Consume any pending payload from cold start
    NotificationService.instance.consumePendingPayload();
  }

  @override
  void dispose() {
    NotificationService.instance.onNotificationTap = null;
    super.dispose();
  }

  void _handleNotificationTap(String payload) {
    if (payload == 'daily_message') {
      // Navigate to Fortune screen (tab index 1)
      setState(() => _currentIndex = 1);
    } else if (payload.startsWith('schedule:')) {
      // Navigate to Calendar screen (tab index 0)
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: '今日の運勢',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake_outlined),
            label: '記念日',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
