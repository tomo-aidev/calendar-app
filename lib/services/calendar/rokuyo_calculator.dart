import '../../models/rokuyo.dart';
import 'lunar_calendar.dart';

/// 六曜 (Rokuyō) calculator
///
/// Formula: (lunar_month + lunar_day) % 6
/// 0=大安, 1=赤口, 2=先勝, 3=友引, 4=先負, 5=仏滅
class RokuyoCalculator {
  final LunarCalendar _lunarCalendar;

  RokuyoCalculator({LunarCalendar? lunarCalendar})
      : _lunarCalendar = lunarCalendar ?? LunarCalendar.instance;

  /// Calculate the Rokuyō for a given Gregorian date
  Rokuyo calculate(DateTime date) {
    final lunar = _lunarCalendar.toLunar(date);
    if (lunar == null) return Rokuyo.unknown;

    final remainder = (lunar.absoluteMonth + lunar.day) % 6;
    switch (remainder) {
      case 0:
        return Rokuyo.taian;
      case 1:
        return Rokuyo.shakku;
      case 2:
        return Rokuyo.senshou;
      case 3:
        return Rokuyo.tomobiki;
      case 4:
        return Rokuyo.senbu;
      case 5:
        return Rokuyo.butsumetsu;
      default:
        return Rokuyo.unknown;
    }
  }
}
