import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';

/// Hive-based local storage service
class StorageService {
  static StorageService? _instance;
  bool _initialized = false;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    // Open boxes
    await Hive.openBox(AppConstants.profileBox);
    await Hive.openBox(AppConstants.schedulesBox);
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox(AppConstants.workEntriesBox);
    _initialized = true;
  }

  // Profile
  Box get profileBox => Hive.box(AppConstants.profileBox);

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await profileBox.putAll(profile);
  }

  Map<String, dynamic> getProfile() {
    final box = profileBox;
    return {
      'name': box.get('name'),
      'gender': box.get('gender'),
      'birthday': box.get('birthday'),
      'bloodType': box.get('bloodType'),
    };
  }

  bool get hasProfile => profileBox.get('birthday') != null;

  // Schedules
  Box get schedulesBox => Hive.box(AppConstants.schedulesBox);

  Future<void> saveSchedule(String id, Map<String, dynamic> data) async {
    await schedulesBox.put(id, data);
  }

  Map<String, dynamic>? getSchedule(String id) {
    final data = schedulesBox.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  List<Map<String, dynamic>> getAllSchedules() {
    return schedulesBox.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  Future<void> deleteSchedule(String id) async {
    await schedulesBox.delete(id);
  }

  // Work Entries
  Box get workEntriesBox => Hive.box(AppConstants.workEntriesBox);

  Future<void> saveWorkEntry(String id, Map<String, dynamic> data) async {
    await workEntriesBox.put(id, data);
  }

  Map<String, dynamic>? getWorkEntry(String id) {
    final data = workEntriesBox.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  List<Map<String, dynamic>> getAllWorkEntries() {
    return workEntriesBox.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  Future<void> deleteWorkEntry(String id) async {
    await workEntriesBox.delete(id);
  }

  // Work Schedule Config History (per-type, stored in settings box as list)
  Future<void> saveWorkScheduleConfigHistory(
      String typeKey, List<Map<String, dynamic>> history) async {
    // Convert each entry to a storable format
    final storableList = history.map((data) {
      final storableData = Map<String, dynamic>.from(data);
      if (storableData['repeatWeekdays'] is List) {
        storableData['repeatWeekdays'] =
            (storableData['repeatWeekdays'] as List).cast<int>();
      }
      return storableData;
    }).toList();
    await settingsBox.put('workConfigHistory_$typeKey', storableList);
  }

  List<Map<String, dynamic>> getWorkScheduleConfigHistory(String typeKey) {
    final data = settingsBox.get('workConfigHistory_$typeKey');
    if (data == null) {
      // Migration: try old single-config format
      final oldData = settingsBox.get('workConfig_$typeKey');
      if (oldData != null) {
        final map = Map<String, dynamic>.from(oldData as Map);
        if (map['repeatWeekdays'] is List) {
          map['repeatWeekdays'] =
              (map['repeatWeekdays'] as List).cast<dynamic>();
        }
        // Set effectiveFrom to epoch if not present (legacy data)
        map['effectiveFrom'] ??= '2000-01-01T00:00:00.000';
        return [map];
      }
      return [];
    }
    return (data as List).map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['repeatWeekdays'] is List) {
        map['repeatWeekdays'] =
            (map['repeatWeekdays'] as List).cast<dynamic>();
      }
      return map;
    }).toList();
  }

  // Excluded Work Dates (schedule-derived entries excluded for specific dates)
  static const _excludedWorkDatesKey = 'excludedWorkDates';

  List<String> getExcludedWorkDates() {
    final data = settingsBox.get(_excludedWorkDatesKey);
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  Future<void> saveExcludedWorkDates(List<String> dates) async {
    await settingsBox.put(_excludedWorkDatesKey, dates);
  }

  // Settings
  Box get settingsBox => Hive.box(AppConstants.settingsBox);

  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
}
