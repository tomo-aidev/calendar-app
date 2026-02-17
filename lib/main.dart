import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
// import 'services/ad_service.dart'; // 次フェーズで有効化
import 'services/calendar/lunar_calendar.dart';
import 'services/calendar/solar_term_calculator.dart';
import 'services/daily_message_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.instance.initialize();
  await LunarCalendar.instance.initialize();
  await SolarTermCalculator.instance.initialize();

  await DailyMessageService.instance.initialize();

  await NotificationService.instance.initialize();
  // await AdService.instance.initialize(); // 次フェーズで有効化

  runApp(
    const ProviderScope(
      child: LuckyCalendarApp(),
    ),
  );
}
