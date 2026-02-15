import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_event.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<ScheduleEvent>>((ref) {
  return ScheduleNotifier();
});

class ScheduleNotifier extends StateNotifier<List<ScheduleEvent>> {
  static const _uuid = Uuid();

  ScheduleNotifier() : super([]);

  void loadSchedules() {
    try {
      final storage = StorageService.instance;
      final data = storage.getAllSchedules();
      state = data.map((d) => _fromMap(d)).toList();
    } catch (e) {
      debugPrint('Failed to load schedules: $e');
      state = [];
    }
  }

  Future<void> addSchedule({
    required String title,
    required DateTime date,
    String? location,
    bool isAllDay = true,
    DateTime? startTime,
    DateTime? endTime,
    Duration travelTime = Duration.zero,
    RepeatType repeat = RepeatType.none,
    Duration notifyBefore = Duration.zero,
  }) async {
    final now = DateTime.now();
    final event = ScheduleEvent(
      id: _uuid.v4(),
      title: title,
      location: location,
      date: date,
      isAllDay: isAllDay,
      startTime: startTime,
      endTime: endTime,
      travelTime: travelTime,
      repeat: repeat,
      notifyBefore: notifyBefore,
      createdAt: now,
      updatedAt: now,
    );

    await _saveToStorage(event);
    try {
      await NotificationService.instance.scheduleEventNotification(event);
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }

    // Save title to history
    _addToHistory('titleHistory', title);
    if (location != null && location.isNotEmpty) {
      _addToHistory('locationHistory', location);
    }

    state = [...state, event];
  }

  Future<void> updateSchedule(ScheduleEvent event) async {
    final updated = event.copyWith(updatedAt: DateTime.now());
    await _saveToStorage(updated);
    try {
      await NotificationService.instance.cancelEventNotification(event.id);
      await NotificationService.instance.scheduleEventNotification(updated);
    } catch (e) {
      debugPrint('Failed to update notification: $e');
    }

    // Save title/location to history
    _addToHistory('titleHistory', updated.title);
    if (updated.location != null && updated.location!.isNotEmpty) {
      _addToHistory('locationHistory', updated.location!);
    }

    state = [
      for (final e in state)
        if (e.id == event.id) updated else e,
    ];
  }

  Future<void> deleteSchedule(String id) async {
    await StorageService.instance.deleteSchedule(id);
    try {
      await NotificationService.instance.cancelEventNotification(id);
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
    state = state.where((e) => e.id != id).toList();
  }

  List<ScheduleEvent> getEventsForDate(DateTime date) {
    return state.where((e) {
      if (e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day) {
        return true;
      }
      // Handle repeating events
      if (e.repeat != RepeatType.none) {
        return _matchesRepeat(e, date);
      }
      return false;
    }).toList();
  }

  bool _matchesRepeat(ScheduleEvent event, DateTime date) {
    if (date.isBefore(event.date)) return false;

    switch (event.repeat) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return date.weekday == event.date.weekday;
      case RepeatType.monthly:
        return date.day == event.date.day;
      case RepeatType.yearly:
        return date.month == event.date.month && date.day == event.date.day;
      case RepeatType.none:
        return false;
    }
  }

  void _addToHistory(String key, String value) {
    final storage = StorageService.instance;
    final history =
        (storage.getSetting<List>(key) ?? []).cast<String>().toList();
    history.remove(value);
    history.insert(0, value);
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    storage.saveSetting(key, history);
  }

  List<String> getTitleHistory() {
    return (StorageService.instance.getSetting<List>('titleHistory') ?? [])
        .cast<String>()
        .toList();
  }

  List<String> getLocationHistory() {
    return (StorageService.instance.getSetting<List>('locationHistory') ?? [])
        .cast<String>()
        .toList();
  }

  Future<void> _saveToStorage(ScheduleEvent event) async {
    await StorageService.instance.saveSchedule(event.id, _toMap(event));
  }

  Map<String, dynamic> _toMap(ScheduleEvent event) {
    return {
      'id': event.id,
      'title': event.title,
      'location': event.location,
      'date': event.date.toIso8601String(),
      'isAllDay': event.isAllDay,
      'startTime': event.startTime?.toIso8601String(),
      'endTime': event.endTime?.toIso8601String(),
      'travelTime': event.travelTime.inMinutes,
      'repeat': event.repeat.index,
      'notifyBefore': event.notifyBefore.inMinutes,
      'nativeCalendarId': event.nativeCalendarId,
      'createdAt': event.createdAt.toIso8601String(),
      'updatedAt': event.updatedAt.toIso8601String(),
    };
  }

  ScheduleEvent _fromMap(Map<String, dynamic> data) {
    return ScheduleEvent(
      id: data['id'] as String,
      title: data['title'] as String,
      location: data['location'] as String?,
      date: DateTime.parse(data['date'] as String),
      isAllDay: data['isAllDay'] as bool? ?? true,
      startTime: data['startTime'] != null
          ? DateTime.parse(data['startTime'] as String)
          : null,
      endTime: data['endTime'] != null
          ? DateTime.parse(data['endTime'] as String)
          : null,
      travelTime: Duration(minutes: data['travelTime'] as int? ?? 0),
      repeat: RepeatType.values[data['repeat'] as int? ?? 0],
      notifyBefore: Duration(minutes: data['notifyBefore'] as int? ?? 0),
      nativeCalendarId: data['nativeCalendarId'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
