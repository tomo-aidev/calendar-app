import 'dart:convert';
import 'package:flutter/services.dart';

/// Lunar date representation
class LunarDate {
  final int year;
  final int month; // 1-12, negative for leap months (e.g., -4 = leap 4th month)
  final int day; // 1-30

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
  });

  /// The actual month number (ignoring leap)
  int get absoluteMonth => month.abs();

  /// Whether this is a leap month
  bool get isLeapMonth => month < 0;
}

/// Gregorian-to-Lunar date converter using pre-computed lookup table
class LunarCalendar {
  static LunarCalendar? _instance;
  Map<String, LunarDate>? _lookupTable;

  LunarCalendar._();

  static LunarCalendar get instance {
    _instance ??= LunarCalendar._();
    return _instance!;
  }

  /// Initialize by loading the lookup table from bundled JSON asset
  Future<void> initialize() async {
    if (_lookupTable != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/lunar_calendar_2020_2035.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

    _lookupTable = {};
    for (final entry in data.entries) {
      final value = entry.value as Map<String, dynamic>;
      _lookupTable![entry.key] = LunarDate(
        year: value['y'] as int? ?? 0,
        month: value['m'] as int,
        day: value['d'] as int,
      );
    }
  }

  /// Convert a Gregorian date to its Lunar equivalent
  /// Returns null if the date is outside the supported range (2020-2035)
  LunarDate? toLunar(DateTime date) {
    if (_lookupTable == null) {
      throw StateError(
        'LunarCalendar not initialized. Call initialize() first.',
      );
    }

    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _lookupTable![key];
  }

  /// Check if the calendar data has been loaded
  bool get isInitialized => _lookupTable != null;
}
