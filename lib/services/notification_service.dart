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

  // Channel IDs
  static const String _channelIdSchedule = 'schedule_notifications';
  static const String _channelNameSchedule = '予定通知';
  static const String _channelIdWorkReminder = 'work_reminder';
  static const String _channelNameWorkReminder = '勤務リマインダー';
  static const String _channelIdLuckyDay = 'lucky_day';
  static const String _channelNameLuckyDay = '吉日通知';

  // Notification ID ranges
  static const int _workReminderBaseId = 80000;
  static const int _luckyDayBaseId = 81000;

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
            _channelIdWorkReminder,
            _channelNameWorkReminder,
            description: '勤務スケジュールの通知',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelIdLuckyDay,
            _channelNameLuckyDay,
            description: '吉日の通知',
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

  // --- Work Reminder Notifications ---

  /// Get notification ID for a work reminder on a given date
  int _workReminderId(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return _workReminderBaseId + (dayOfYear % 366);
  }

  /// Schedule a work reminder notification for a specific date
  Future<void> scheduleWorkReminder({
    required DateTime date,
    required String message,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;

    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Don't schedule if in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _workReminderId(date),
      '⏰ 勤務リマインダー',
      message,
      scheduledDate,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelIdWorkReminder,
          _channelNameWorkReminder,
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
      payload: 'work_reminder:${date.toIso8601String()}',
    );
  }

  /// Cancel all work reminder notifications
  Future<void> cancelAllWorkReminders() async {
    if (kIsWeb) return;
    final now = DateTime.now();
    for (int i = 0; i < 31; i++) {
      final date = now.add(Duration(days: i));
      await _plugin.cancel(_workReminderId(date));
    }
  }

  // --- Lucky Day Notifications ---

  /// Get notification ID for a lucky day notification on a given date
  int _luckyDayId(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return _luckyDayBaseId + (dayOfYear % 366);
  }

  /// Schedule a lucky day notification for a specific date
  Future<void> scheduleLuckyDayNotification({
    required DateTime date,
    required String message,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;

    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Don't schedule if in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _luckyDayId(date),
      '🌟 吉日のお知らせ',
      message,
      scheduledDate,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelIdLuckyDay,
          _channelNameLuckyDay,
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
      payload: 'lucky_day:${date.toIso8601String()}',
    );
  }

  /// Cancel all lucky day notifications
  Future<void> cancelAllLuckyDayNotifications() async {
    if (kIsWeb) return;
    final now = DateTime.now();
    for (int i = 0; i < 31; i++) {
      final date = now.add(Duration(days: i));
      await _plugin.cancel(_luckyDayId(date));
    }
  }

  /// Get count of currently pending notifications
  Future<int> getPendingNotificationCount() async {
    if (kIsWeb) return 0;
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
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
