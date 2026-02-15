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

  // Settings
  Box get settingsBox => Hive.box(AppConstants.settingsBox);

  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
}
