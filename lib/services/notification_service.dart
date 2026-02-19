import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/schedule_event.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const int _dailyMessageNotificationId = 99999;
  static const String _channelIdSchedule = 'schedule_notifications';
  static const String _channelNameSchedule = '予定通知';
  static const String _channelIdDaily = 'daily_message';
  static const String _channelNameDaily = '日替わりメッセージ';

  /// Callback to handle notification tap navigation
  void Function(String payload)? onNotificationTap;

  /// Stores payload when notification is tapped before callback is registered (cold start)
  String? _pendingPayload;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelIdSchedule,
            _channelNameSchedule,
            description: '予定のリマインダー通知',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelIdDaily,
            _channelNameDaily,
            description: '毎日の吉日メッセージ通知',
            importance: Importance.defaultImportance,
          ),
        );
      }
    }

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    final payload = response.payload;
    if (payload != null) {
      if (onNotificationTap != null) {
        onNotificationTap!(payload);
      } else {
        // Store for later consumption (cold start case)
        _pendingPayload = payload;
      }
    }
  }

  /// Consume any pending payload from a cold-start notification tap
  void consumePendingPayload() {
    if (_pendingPayload != null && onNotificationTap != null) {
      onNotificationTap!(_pendingPayload!);
      _pendingPayload = null;
    }
  }

  /// Schedule a notification for a schedule event
  Future<void> scheduleEventNotification(ScheduleEvent event) async {
    if (kIsWeb || event.notifyBefore == Duration.zero) return;

    final eventDateTime = event.isAllDay
        ? DateTime(event.date.year, event.date.month, event.date.day, 9, 0)
        : event.startTime ?? event.date;

    final notifyAt = eventDateTime.subtract(event.notifyBefore);

    // Don't schedule if in the past
    if (notifyAt.isBefore(DateTime.now())) return;

    final tzNotifyAt = tz.TZDateTime.from(notifyAt, tz.local);

    await _plugin.zonedSchedule(
      event.id.hashCode,
      '📅 ${event.title}',
      _notifyBeforeText(event.notifyBefore),
      tzNotifyAt,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelIdSchedule,
          _channelNameSchedule,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'schedule:${event.id}',
    );
  }

  /// Cancel notification for a specific event
  Future<void> cancelEventNotification(String eventId) async {
    if (kIsWeb) return;
    await _plugin.cancel(eventId.hashCode);
  }

  /// Schedule daily morning message notification
  Future<void> scheduleDailyMessage({
    int hour = 7,
    int minute = 0,
  }) async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyMessageNotificationId,
      '✨ 今日の吉日メッセージ',
      '今日の運勢をチェックしましょう！',
      scheduledDate,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelIdDaily,
          _channelNameDaily,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_message',
    );
  }

  /// Cancel daily message notification
  Future<void> cancelDailyMessage() async {
    if (kIsWeb) return;
    await _plugin.cancel(_dailyMessageNotificationId);
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    if (!kIsWeb && Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  String _notifyBeforeText(Duration duration) {
    if (duration.inDays >= 1) return '明日の予定です';
    if (duration.inHours >= 1) return '${duration.inHours}時間後に予定があります';
    return '${duration.inMinutes}分後に予定があります';
  }
}
