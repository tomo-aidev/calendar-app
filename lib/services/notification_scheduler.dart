import 'package:flutter/foundation.dart';
import '../models/notification_day_type.dart';
import '../models/work_entry.dart';
import '../services/calendar/lucky_day_calculator.dart';
import '../services/calendar/rokuyo_calculator.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// Manages scheduling of all periodic notifications (work reminders + lucky day)
/// considering the iOS 64 pending notification limit.
class NotificationScheduler {
  NotificationScheduler._();
  static final NotificationScheduler instance = NotificationScheduler._();

  static const int _maxPendingNotifications = 64;
  static const int _scheduleDays = 30;

  final _rokuyoCalc = RokuyoCalculator();
  final _luckyDayCalc = LuckyDayCalculator();

  /// Reschedule all work reminders and lucky day notifications.
  Future<void> rescheduleAllNotifications() async {
    if (kIsWeb) return;

    final ns = NotificationService.instance;
    final storage = StorageService.instance;

    try {
      // 1. Cancel all existing work/lucky day notifications
      await ns.cancelAllWorkReminders();
      await ns.cancelAllLuckyDayNotifications();

      // 2. Load work schedule config histories
      final configHistories = <WorkEntryType, List<WorkScheduleConfig>>{};
      for (final type in WorkEntryType.values) {
        final key = _typeKey(type);
        final historyData = storage.getWorkScheduleConfigHistory(key);
        if (historyData.isNotEmpty) {
          final list = historyData
              .map((m) => WorkScheduleConfig.fromMap(m))
              .toList()
            ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
          configHistories[type] = list;
        }
      }

      // 3. Get lucky day settings
      final luckyDayEnabled =
          storage.getSetting<bool>('luckyDayNotificationEnabled') ?? false;
      final luckyDayHour =
          storage.getSetting<int>('luckyDayNotificationHour') ?? 8;
      final luckyDayMinute =
          storage.getSetting<int>('luckyDayNotificationMinute') ?? 0;

      // 4. Load work entries and excluded dates
      final workEntries = storage
          .getAllWorkEntries()
          .map((m) => WorkEntry.fromMap(m))
          .toList();
      final excludedDates = storage.getExcludedWorkDates().toSet();

      // 5. Get current pending event notification count estimate
      final pendingCount = await ns.getPendingNotificationCount();
      int availableSlots = _maxPendingNotifications - pendingCount;

      final now = DateTime.now();
      int workScheduled = 0;
      int luckyScheduled = 0;

      // 6. Schedule work reminders (higher priority)
      // Each config has its own reminderMinutes; if > 0, schedule notification
      if (availableSlots > 0) {
        for (int i = 0; i < _scheduleDays && availableSlots > 0; i++) {
          final date = DateTime(now.year, now.month, now.day + i);
          final workType =
              _resolveWorkType(date, workEntries, configHistories, excludedDates);

          if (workType == WorkEntryType.shift ||
              workType == WorkEntryType.workFromHome) {
            final history = configHistories[workType];
            final config =
                history != null ? _findConfigForDate(history, date) : null;
            if (config != null && config.reminderMinutes > 0) {
              final startHour = config.startHour ?? 9;
              final startMinute = config.startMinute ?? 0;

              // Calculate notification time = start time - reminder minutes
              final startTotal = startHour * 60 + startMinute;
              final notifyTotal = startTotal - config.reminderMinutes;
              final notifyHour = (notifyTotal ~/ 60).clamp(0, 23);
              final notifyMinute = (notifyTotal % 60).clamp(0, 59);

              final message = workType == WorkEntryType.shift
                  ? '本日はシフト勤務の日です。準備を始めましょう。'
                  : '本日は在宅ワークの日です。';

              await ns.scheduleWorkReminder(
                date: date,
                message: message,
                hour: notifyHour,
                minute: notifyMinute,
              );
              workScheduled++;
              availableSlots--;
            }
          }
        }
      }

      // 7. Schedule lucky day notifications (remaining slots)
      if (luckyDayEnabled && availableSlots > 0) {
        final enabledTypes = <NotificationDayType>[];
        for (final type in NotificationDayType.values) {
          final enabled =
              storage.getSetting<bool>(type.settingsKey) ?? true;
          if (enabled) {
            enabledTypes.add(type);
          }
        }

        if (enabledTypes.isNotEmpty) {
          for (int i = 0; i < _scheduleDays && availableSlots > 0; i++) {
            final date = DateTime(now.year, now.month, now.day + i);
            final rokuyo = _rokuyoCalc.calculate(date);
            final luckyDays = _luckyDayCalc.calculate(date);

            final matchingTypes =
                NotificationDayTypeExtension.getMatchingTypes(
              rokuyo: rokuyo,
              luckyDays: luckyDays,
            );

            final enabledMatching = matchingTypes
                .where((t) => enabledTypes.contains(t))
                .toList();

            if (enabledMatching.isNotEmpty) {
              final names =
                  enabledMatching.map((t) => t.displayName).join('、');
              final message = '本日は$namesです。';

              await ns.scheduleLuckyDayNotification(
                date: date,
                message: message,
                hour: luckyDayHour,
                minute: luckyDayMinute,
              );
              luckyScheduled++;
              availableSlots--;
            }
          }
        }
      }

      debugPrint(
          'Notifications scheduled: work=$workScheduled, lucky=$luckyScheduled, '
          'remaining slots=$availableSlots');
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  /// Find the applicable config for a given date from history
  WorkScheduleConfig? _findConfigForDate(
      List<WorkScheduleConfig> history, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    WorkScheduleConfig? result;
    for (final config in history) {
      final ef = DateTime(config.effectiveFrom.year,
          config.effectiveFrom.month, config.effectiveFrom.day);
      if (!ef.isAfter(dateOnly)) {
        result = config;
      }
    }
    return result;
  }

  /// Resolve the effective work type for a given date
  /// Priority: 1. Individual WorkEntry, 2. Excluded dates, 3. Config history weekday match
  WorkEntryType? _resolveWorkType(
    DateTime date,
    List<WorkEntry> entries,
    Map<WorkEntryType, List<WorkScheduleConfig>> configHistories,
    Set<String> excludedDates,
  ) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Check individual entry first
    for (final entry in entries) {
      final entryDate =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate == dateOnly) {
        return entry.type;
      }
    }

    // Check if date is excluded
    final dateKey =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
    if (excludedDates.contains(dateKey)) {
      return null;
    }

    // Fall back to config history — find config active at this date
    final weekday = date.weekday;
    for (final entry in configHistories.entries) {
      final config = _findConfigForDate(entry.value, date);
      if (config != null && config.repeatWeekdays.contains(weekday)) {
        return entry.key;
      }
    }

    return null;
  }

  static String _typeKey(WorkEntryType type) {
    switch (type) {
      case WorkEntryType.shift:
        return 'shift';
      case WorkEntryType.workFromHome:
        return 'wfh';
      case WorkEntryType.holiday:
        return 'holiday';
    }
  }
}
