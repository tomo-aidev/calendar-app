import 'dart:convert';
import 'package:flutter/services.dart';

/// 二十四節気 (24 Solar Terms) calculator using pre-computed data
class SolarTermCalculator {
  static SolarTermCalculator? _instance;
  Map<int, Map<String, DateTime>>? _solarTerms;

  SolarTermCalculator._();

  static SolarTermCalculator get instance {
    _instance ??= SolarTermCalculator._();
    return _instance!;
  }

  // Solar term names in order
  static const List<String> solarTermNames = [
    '小寒', '大寒', '立春', '雨水', '啓蟄', '春分',
    '清明', '穀雨', '立夏', '小満', '芒種', '夏至',
    '小暑', '大暑', '立秋', '処暑', '白露', '秋分',
    '寒露', '霜降', '立冬', '小雪', '大雪', '冬至',
  ];

  // Season-defining solar terms
  static const String risshun = '立春'; // Start of spring
  static const String rikka = '立夏'; // Start of summer
  static const String risshuu = '立秋'; // Start of autumn
  static const String rittou = '立冬'; // Start of winter

  /// Initialize by loading from bundled JSON asset
  Future<void> initialize() async {
    if (_solarTerms != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/solar_terms_2020_2035.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

    _solarTerms = {};
    for (final yearEntry in data.entries) {
      final year = int.parse(yearEntry.key);
      final terms = yearEntry.value as Map<String, dynamic>;
      _solarTerms![year] = {};
      for (final termEntry in terms.entries) {
        _solarTerms![year]![termEntry.key] =
            DateTime.parse(termEntry.value as String);
      }
    }
  }

  /// Get the date of a specific solar term in a given year
  DateTime? getSolarTermDate(int year, String termName) {
    _ensureInitialized();
    return _solarTerms?[year]?[termName];
  }

  /// Get all solar terms for a given year
  Map<String, DateTime>? getYearSolarTerms(int year) {
    _ensureInitialized();
    return _solarTerms?[year];
  }

  /// Determine the current season based on solar terms
  /// Returns: 'spring', 'summer', 'autumn', 'winter'
  Season getSeason(DateTime date) {
    _ensureInitialized();

    final year = date.year;

    // Get the seasonal boundary dates
    final risshunDate = _solarTerms?[year]?[risshun];
    final rikkaDate = _solarTerms?[year]?[rikka];
    final risshuurDate = _solarTerms?[year]?[risshuu];
    final rittouDate = _solarTerms?[year]?[rittou];
    // prevYear's rittou could be used for winter detection before risshun

    if (risshunDate == null ||
        rikkaDate == null ||
        risshuurDate == null ||
        rittouDate == null) {
      // Fallback: use approximate dates
      return _approximateSeason(date);
    }

    if (date.isBefore(risshunDate)) return Season.winter;
    if (date.isBefore(rikkaDate)) return Season.spring;
    if (date.isBefore(risshuurDate)) return Season.summer;
    if (date.isBefore(rittouDate)) return Season.autumn;
    return Season.winter;
  }

  /// Get the "sectional month" (節月) for calculating 一粒万倍日
  /// Based on the 12 "major" solar terms that start each month
  ///
  /// Sectional months follow this chronological order within a year:
  /// 小寒(12月) → 立春(1月) → 啓蟄(2月) → ... → 大雪(11月)
  /// Note: Month 12 starts at 小寒 (early Jan) and ends before 立春 (early Feb)
  int getSectionalMonth(DateTime date) {
    _ensureInitialized();

    final year = date.year;
    final terms = _solarTerms?[year];
    final prevTerms = _solarTerms?[year - 1];

    if (terms == null) return _approximateSectionalMonth(date);

    // Build chronological list of (term date, month number) for the year
    // Order: 小寒(12) < 立春(1) < 啓蟄(2) < ... < 大雪(11)
    final boundaries = <({DateTime date, int month})>[];

    // 小寒 of current year marks month 12 (in early January)
    final shoukan = terms['小寒'];
    if (shoukan != null) boundaries.add((date: shoukan, month: 12));

    // Months 1-11: 立春 through 大雪
    const termToMonth = {
      '立春': 1, '啓蟄': 2, '清明': 3, '立夏': 4, '芒種': 5,
      '小暑': 6, '立秋': 7, '白露': 8, '寒露': 9, '立冬': 10,
      '大雪': 11,
    };

    for (final entry in termToMonth.entries) {
      final termDate = terms[entry.key];
      if (termDate != null) boundaries.add((date: termDate, month: entry.value));
    }

    // Sort by date ascending
    boundaries.sort((a, b) => a.date.compareTo(b.date));

    // Find which interval the date falls in (reverse search)
    for (int i = boundaries.length - 1; i >= 0; i--) {
      if (!date.isBefore(boundaries[i].date)) {
        return boundaries[i].month;
      }
    }

    // Before 小寒 of current year: check previous year's 大雪 and 小寒
    final prevTaisetsu = prevTerms?['大雪'];
    if (prevTaisetsu != null && !date.isBefore(prevTaisetsu)) {
      return 11;
    }
    // Must be in month 12 of previous year (after prev year's 小寒)
    return 12;
  }

  Season _approximateSeason(DateTime date) {
    final month = date.month;
    final day = date.day;
    if ((month == 2 && day >= 4) || month == 3 || month == 4 || (month == 5 && day < 5)) {
      return Season.spring;
    }
    if ((month == 5 && day >= 5) || month == 6 || month == 7 || (month == 8 && day < 7)) {
      return Season.summer;
    }
    if ((month == 8 && day >= 7) || month == 9 || month == 10 || (month == 11 && day < 7)) {
      return Season.autumn;
    }
    return Season.winter;
  }

  int _approximateSectionalMonth(DateTime date) {
    // Rough mapping based on typical solar term dates
    final month = date.month;
    final day = date.day;
    if (month == 1 && day < 6) return 11;
    if (month == 1) return 12;
    if (month == 2 && day < 4) return 12;
    if (month == 2) return 1;
    if (month == 3 && day < 6) return 1;
    if (month == 3) return 2;
    if (month == 4 && day < 5) return 2;
    if (month == 4) return 3;
    if (month == 5 && day < 6) return 3;
    if (month == 5) return 4;
    if (month == 6 && day < 6) return 4;
    if (month == 6) return 5;
    if (month == 7 && day < 7) return 5;
    if (month == 7) return 6;
    if (month == 8 && day < 8) return 6;
    if (month == 8) return 7;
    if (month == 9 && day < 8) return 7;
    if (month == 9) return 8;
    if (month == 10 && day < 8) return 8;
    if (month == 10) return 9;
    if (month == 11 && day < 7) return 9;
    if (month == 11) return 10;
    if (month == 12 && day < 7) return 10;
    return 11;
  }

  void _ensureInitialized() {
    if (_solarTerms == null) {
      throw StateError(
        'SolarTermCalculator not initialized. Call initialize() first.',
      );
    }
  }

  bool get isInitialized => _solarTerms != null;
}

enum Season { spring, summer, autumn, winter }
