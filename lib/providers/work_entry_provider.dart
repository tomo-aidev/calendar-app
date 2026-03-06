import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/work_entry.dart';
import '../services/notification_scheduler.dart';
import '../services/storage_service.dart';

/// Provider for individual work entries (overrides schedule configs)
final workEntryProvider =
    StateNotifierProvider<WorkEntryNotifier, List<WorkEntry>>((ref) {
  return WorkEntryNotifier();
});

/// Provider for excluded work dates (schedule-derived entries excluded for specific dates)
final excludedWorkDatesProvider =
    StateNotifierProvider<ExcludedWorkDatesNotifier, Set<String>>((ref) {
  return ExcludedWorkDatesNotifier();
});

/// Provider for per-type work schedule config HISTORY
/// State: Map of WorkEntryType to List of WorkScheduleConfig (sorted by effectiveFrom asc)
final workScheduleConfigsProvider = StateNotifierProvider<
    WorkScheduleConfigsNotifier,
    Map<WorkEntryType, List<WorkScheduleConfig>>>((ref) {
  return WorkScheduleConfigsNotifier();
});

/// UI用: 各タイプの「現在の（最新）」設定を返す
final currentWorkScheduleConfigsProvider =
    Provider<Map<WorkEntryType, WorkScheduleConfig>>((ref) {
  final allConfigs = ref.watch(workScheduleConfigsProvider);
  final current = <WorkEntryType, WorkScheduleConfig>{};
  for (final entry in allConfigs.entries) {
    if (entry.value.isNotEmpty) {
      current[entry.key] = entry.value.last; // last = 最新
    }
  }
  return current;
});

/// 指定日付のconfigを履歴から探すヘルパー
WorkScheduleConfig? _findConfigForDate(
    List<WorkScheduleConfig> history, DateTime date) {
  final dateOnly = DateTime(date.year, date.month, date.day);
  WorkScheduleConfig? result;
  for (final config in history) {
    final ef = DateTime(
        config.effectiveFrom.year, config.effectiveFrom.month, config.effectiveFrom.day);
    if (!ef.isAfter(dateOnly)) {
      result = config; // effectiveFrom <= date → 候補（最後に見つかったものが最新）
    }
  }
  return result;
}

/// Resolves the effective work type for a given date
/// Priority: 1. Individual WorkEntry, 2. Excluded dates check, 3. Config history weekday match
final resolvedWorkTypeProvider =
    Provider.family<WorkEntryType?, DateTime>((ref, date) {
  final entries = ref.watch(workEntryProvider);
  final allConfigs = ref.watch(workScheduleConfigsProvider);
  final excludedDates = ref.watch(excludedWorkDatesProvider);

  // 1. Check individual entry first (highest priority)
  final dateOnly = DateTime(date.year, date.month, date.day);
  for (final entry in entries) {
    final entryDate =
        DateTime(entry.date.year, entry.date.month, entry.date.day);
    if (entryDate == dateOnly) {
      return entry.type;
    }
  }

  // 2. Check if this date is excluded
  final dateKey =
      '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
  if (excludedDates.contains(dateKey)) {
    return null;
  }

  // 3. Fall back to config history — find config active at this date
  final weekday = date.weekday; // 1=Mon, 7=Sun
  for (final typeEntry in allConfigs.entries) {
    final config = _findConfigForDate(typeEntry.value, date);
    if (config != null && config.repeatWeekdays.contains(weekday)) {
      return typeEntry.key;
    }
  }

  return null;
});

/// Resolves the start time for a given date based on work type
final resolvedWorkStartTimeProvider =
    Provider.family<({int hour, int minute})?, DateTime>((ref, date) {
  final type = ref.watch(resolvedWorkTypeProvider(date));
  if (type == null || type == WorkEntryType.holiday) return null;

  final allConfigs = ref.watch(workScheduleConfigsProvider);
  final history = allConfigs[type];
  if (history == null || history.isEmpty) return null;

  final config = _findConfigForDate(history, date);
  if (config == null) return null;

  final h = config.startHour;
  final m = config.startMinute;
  if (h == null || m == null) return null;

  return (hour: h, minute: m);
});

class WorkEntryNotifier extends StateNotifier<List<WorkEntry>> {
  static const _uuid = Uuid();

  WorkEntryNotifier() : super([]);

  void loadWorkEntries() {
    try {
      final storage = StorageService.instance;
      final data = storage.getAllWorkEntries();
      state = data.map((d) => WorkEntry.fromMap(d)).toList();
    } catch (e) {
      debugPrint('Failed to load work entries: $e');
      state = [];
    }
  }

  Future<void> addWorkEntry({
    required DateTime date,
    required WorkEntryType type,
  }) async {
    final entry = WorkEntry(
      id: _uuid.v4(),
      date: DateTime(date.year, date.month, date.day),
      type: type,
      createdAt: DateTime.now(),
    );

    // Remove existing entry for the same date
    await _removeEntryForDate(date);

    await StorageService.instance.saveWorkEntry(entry.id, entry.toMap());
    state = [...state, entry];
    NotificationScheduler.instance.rescheduleAllNotifications();
  }

  Future<void> deleteWorkEntry(String id) async {
    await StorageService.instance.deleteWorkEntry(id);
    state = state.where((e) => e.id != id).toList();
    NotificationScheduler.instance.rescheduleAllNotifications();
  }

  Future<void> deleteWorkEntryForDate(DateTime date) async {
    await _removeEntryForDate(date);
    state = state.where((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return entryDate != targetDate;
    }).toList();
    NotificationScheduler.instance.rescheduleAllNotifications();
  }

  WorkEntry? getEntryForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    for (final entry in state) {
      final entryDate =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate == dateOnly) {
        return entry;
      }
    }
    return null;
  }

  Future<void> _removeEntryForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    for (final entry in state) {
      final entryDate =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate == dateOnly) {
        await StorageService.instance.deleteWorkEntry(entry.id);
      }
    }
  }
}

class WorkScheduleConfigsNotifier
    extends StateNotifier<Map<WorkEntryType, List<WorkScheduleConfig>>> {
  WorkScheduleConfigsNotifier() : super({});

  static const _typeKeys = {
    WorkEntryType.shift: 'shift',
    WorkEntryType.workFromHome: 'wfh',
    WorkEntryType.holiday: 'holiday',
  };

  void loadConfigs() {
    final storage = StorageService.instance;
    final configs = <WorkEntryType, List<WorkScheduleConfig>>{};

    for (final entry in _typeKeys.entries) {
      final historyData = storage.getWorkScheduleConfigHistory(entry.value);
      if (historyData.isNotEmpty) {
        final list = historyData
            .map((m) => WorkScheduleConfig.fromMap(m))
            .toList()
          ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
        configs[entry.key] = list;
      }
    }
    state = configs;
  }

  /// Save a new config — appends to history with effectiveFrom = today
  Future<void> saveConfig(
      WorkEntryType type, WorkScheduleConfig config) async {
    final key = _typeKeys[type]!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Set effectiveFrom to today
    final newConfig = config.copyWith(effectiveFrom: today);

    // Get existing history
    final history = List<WorkScheduleConfig>.from(state[type] ?? []);

    // If there's already an entry for today, replace it
    final todayIndex = history.indexWhere((c) {
      final ef = DateTime(
          c.effectiveFrom.year, c.effectiveFrom.month, c.effectiveFrom.day);
      return ef == today;
    });

    if (todayIndex >= 0) {
      history[todayIndex] = newConfig;
    } else {
      history.add(newConfig);
    }

    // Sort by effectiveFrom
    history.sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));

    // Save to storage
    await StorageService.instance.saveWorkScheduleConfigHistory(
      key,
      history.map((c) => c.toMap()).toList(),
    );

    // Update state
    state = {...state, type: history};
    NotificationScheduler.instance.rescheduleAllNotifications();
  }
}

class ExcludedWorkDatesNotifier extends StateNotifier<Set<String>> {
  ExcludedWorkDatesNotifier() : super({});

  void load() {
    final dates = StorageService.instance.getExcludedWorkDates();
    state = dates.toSet();
  }

  Future<void> excludeDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final key =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
    final newState = {...state, key};
    await StorageService.instance.saveExcludedWorkDates(newState.toList());
    state = newState;
    NotificationScheduler.instance.rescheduleAllNotifications();
  }

  Future<void> removeExclusion(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final key =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
    final newState = {...state}..remove(key);
    await StorageService.instance.saveExcludedWorkDates(newState.toList());
    state = newState;
  }
}
