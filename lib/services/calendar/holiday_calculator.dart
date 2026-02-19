/// 日本の祝日計算サービス（2020-2099年対応）
class HolidayCalculator {
  HolidayCalculator._();

  /// Returns the holiday name if the date is a national holiday, null otherwise
  static String? getHoliday(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // 1. Check fixed holidays
    final fixed = _getFixedHoliday(month, day, year);
    if (fixed != null) return fixed;

    // 2. Check Happy Monday holidays
    final happyMonday = _getHappyMondayHoliday(year, month, day);
    if (happyMonday != null) return happyMonday;

    // 3. Check equinox holidays
    if (month == 3 && day == _vernalEquinoxDay(year)) return '春分の日';
    if (month == 9 && day == _autumnalEquinoxDay(year)) return '秋分の日';

    // 4. Check 国民の休日 (between two holidays)
    if (_isKokuminNoKyujitsu(date)) return '国民の休日';

    // 5. Check 振替休日 (substitute holiday)
    if (_isSubstituteHoliday(date)) return '振替休日';

    return null;
  }

  /// Fixed-date holidays
  static String? _getFixedHoliday(int month, int day, int year) {
    switch (month) {
      case 1:
        if (day == 1) return '元日';
        break;
      case 2:
        if (day == 11) return '建国記念の日';
        if (day == 23 && year >= 2020) return '天皇誕生日';
        break;
      case 4:
        if (day == 29) return '昭和の日';
        break;
      case 5:
        if (day == 3) return '憲法記念日';
        if (day == 4) return 'みどりの日';
        if (day == 5) return 'こどもの日';
        break;
      case 8:
        if (day == 11) return '山の日';
        break;
      case 11:
        if (day == 3) return '文化の日';
        if (day == 23) return '勤労感謝の日';
        break;
    }
    return null;
  }

  /// Happy Monday holidays (nth Monday of month)
  static String? _getHappyMondayHoliday(int year, int month, int day) {
    // 成人の日: 1月第2月曜日
    if (month == 1) {
      final secondMonday = _nthWeekdayOfMonth(year, 1, DateTime.monday, 2);
      if (day == secondMonday.day) return '成人の日';
    }

    // 海の日: 7月第3月曜日
    if (month == 7) {
      final thirdMonday = _nthWeekdayOfMonth(year, 7, DateTime.monday, 3);
      if (day == thirdMonday.day) return '海の日';
    }

    // 敬老の日: 9月第3月曜日
    if (month == 9) {
      final thirdMonday = _nthWeekdayOfMonth(year, 9, DateTime.monday, 3);
      if (day == thirdMonday.day) return '敬老の日';
    }

    // スポーツの日: 10月第2月曜日
    if (month == 10) {
      final secondMonday = _nthWeekdayOfMonth(year, 10, DateTime.monday, 2);
      if (day == secondMonday.day) return 'スポーツの日';
    }

    return null;
  }

  /// 春分の日 (Vernal Equinox Day) calculation
  /// Valid for 1980-2099
  static int _vernalEquinoxDay(int year) {
    if (year <= 1979) return 21; // fallback
    if (year <= 2099) {
      return (20.8431 + 0.242194 * (year - 1980)).truncate() -
          ((year - 1980) ~/ 4);
    }
    return 21; // fallback
  }

  /// 秋分の日 (Autumnal Equinox Day) calculation
  /// Valid for 1980-2099
  static int _autumnalEquinoxDay(int year) {
    if (year <= 1979) return 23; // fallback
    if (year <= 2099) {
      return (23.2488 + 0.242194 * (year - 1980)).truncate() -
          ((year - 1980) ~/ 4);
    }
    return 23; // fallback
  }

  /// Get the nth occurrence of a specific weekday in a month
  static DateTime _nthWeekdayOfMonth(
      int year, int month, int weekday, int n) {
    var date = DateTime(year, month, 1);
    int count = 0;
    while (count < n) {
      if (date.weekday == weekday) {
        count++;
        if (count == n) return date;
      }
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  /// Check if a date is 国民の休日 (sandwiched between two holidays)
  static bool _isKokuminNoKyujitsu(DateTime date) {
    // 国民の休日: A non-holiday weekday sandwiched between two holidays
    // Most commonly occurs in September between 敬老の日 and 秋分の日
    if (date.weekday == DateTime.sunday) return false;

    final yesterday = date.subtract(const Duration(days: 1));
    final tomorrow = date.add(const Duration(days: 1));

    final yesterdayHoliday = _isNonSubstituteHoliday(yesterday);
    final tomorrowHoliday = _isNonSubstituteHoliday(tomorrow);

    return yesterdayHoliday && tomorrowHoliday;
  }

  /// Check if a date is a holiday (excluding substitute and 国民の休日)
  static bool _isNonSubstituteHoliday(DateTime date) {
    final fixed = _getFixedHoliday(date.month, date.day, date.year);
    if (fixed != null) return true;

    final happyMonday =
        _getHappyMondayHoliday(date.year, date.month, date.day);
    if (happyMonday != null) return true;

    if (date.month == 3 && date.day == _vernalEquinoxDay(date.year)) {
      return true;
    }
    if (date.month == 9 && date.day == _autumnalEquinoxDay(date.year)) {
      return true;
    }

    return false;
  }

  /// Check if a date is a 振替休日 (substitute holiday)
  /// When a holiday falls on Sunday, the next non-holiday Monday is a substitute holiday
  static bool _isSubstituteHoliday(DateTime date) {
    if (date.weekday != DateTime.monday) {
      // For consecutive holidays (like GW), substitute can be later
      // But the standard case is Monday
      // Check multi-day consecutive case
      return _isExtendedSubstituteHoliday(date);
    }

    // Check if yesterday (Sunday) was a holiday
    final yesterday = date.subtract(const Duration(days: 1));
    return _isNonSubstituteHoliday(yesterday) &&
        yesterday.weekday == DateTime.sunday;
  }

  /// Handle extended substitute holidays (e.g., consecutive holidays ending on Sunday)
  static bool _isExtendedSubstituteHoliday(DateTime date) {
    // If this date is already a regular holiday, it's not a substitute
    if (_isNonSubstituteHoliday(date)) return false;

    // Walk backwards to find if there's a Sunday holiday that hasn't been compensated
    var checkDate = date.subtract(const Duration(days: 1));
    while (_isNonSubstituteHoliday(checkDate) ||
        _isKokuminNoKyujitsu(checkDate)) {
      if (checkDate.weekday == DateTime.sunday &&
          _isNonSubstituteHoliday(checkDate)) {
        return true;
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return false;
  }
}
