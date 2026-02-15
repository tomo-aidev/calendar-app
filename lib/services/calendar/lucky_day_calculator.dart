import '../../models/lucky_day.dart';
import 'lunar_calendar.dart';
import 'solar_term_calculator.dart';
import 'stem_branch_calculator.dart';

/// Calculator for all types of lucky/unlucky days (吉日・凶日)
class LuckyDayCalculator {
  final LunarCalendar _lunarCalendar;
  final SolarTermCalculator _solarTermCalculator;

  LuckyDayCalculator({
    LunarCalendar? lunarCalendar,
    SolarTermCalculator? solarTermCalculator,
  })  : _lunarCalendar = lunarCalendar ?? LunarCalendar.instance,
        _solarTermCalculator =
            solarTermCalculator ?? SolarTermCalculator.instance;

  /// Get all lucky day types for a given date
  List<LuckyDayType> calculate(DateTime date) {
    final results = <LuckyDayType>[];

    if (isTenshanichi(date)) results.add(LuckyDayType.tenshanichi);
    if (isIchiryuManbaibi(date)) results.add(LuckyDayType.ichiryuManbaibi);

    // 己巳の日 is a subset of 巳の日, check it first
    if (isTsuchinotoMiNoHi(date)) {
      results.add(LuckyDayType.tsuchinotoMinohi);
    } else if (isMiNoHi(date)) {
      results.add(LuckyDayType.minohi);
    }

    if (isToraNoHi(date)) results.add(LuckyDayType.toranohi);
    if (isFujoujubi(date)) results.add(LuckyDayType.fujoujubi);

    return results;
  }

  /// 天赦日 (Tensha-nichi) - The most auspicious day
  ///
  /// Based on season + specific stem-branch combination:
  /// Spring (立春-立夏前日): 戊寅 days (stem=4 戊, branch=2 寅)
  /// Summer (立夏-立秋前日): 甲午 days (stem=0 甲, branch=6 午)
  /// Autumn (立秋-立冬前日): 戊申 days (stem=4 戊, branch=8 申)
  /// Winter (立冬-立春前日): 甲子 days (stem=0 甲, branch=0 子)
  bool isTenshanichi(DateTime date) {
    final season = _solarTermCalculator.getSeason(date);
    final stem = StemBranchCalculator.stemIndex(date);
    final branch = StemBranchCalculator.branchIndex(date);

    switch (season) {
      case Season.spring:
        return stem == 4 && branch == 2; // 戊寅
      case Season.summer:
        return stem == 0 && branch == 6; // 甲午
      case Season.autumn:
        return stem == 4 && branch == 8; // 戊申
      case Season.winter:
        return stem == 0 && branch == 0; // 甲子
    }
  }

  /// 一粒万倍日 (Ichiryū Manbai-bi)
  ///
  /// Based on sectional month (節月) and the day's earthly branch:
  /// Month 1 (立春-啓蟄): 丑(1), 午(6)
  /// Month 2 (啓蟄-清明): 酉(9), 寅(2)
  /// Month 3 (清明-立夏): 子(0), 卯(3)
  /// Month 4 (立夏-芒種): 卯(3), 辰(4)
  /// Month 5 (芒種-小暑): 巳(5), 午(6)
  /// Month 6 (小暑-立秋): 酉(9), 午(6)
  /// Month 7 (立秋-白露): 子(0), 未(7)
  /// Month 8 (白露-寒露): 卯(3), 申(8)
  /// Month 9 (寒露-立冬): 酉(9), 午(6)
  /// Month 10 (立冬-大雪): 酉(9), 戌(10)
  /// Month 11 (大雪-小寒): 亥(11), 子(0)
  /// Month 12 (小寒-立春): 卯(3), 子(0)
  bool isIchiryuManbaibi(DateTime date) {
    final sectionalMonth = _solarTermCalculator.getSectionalMonth(date);
    final branch = StemBranchCalculator.branchIndex(date);

    final luckyBranches = _ichiryuManbaibiTable[sectionalMonth];
    if (luckyBranches == null) return false;

    return luckyBranches.contains(branch);
  }

  static const Map<int, List<int>> _ichiryuManbaibiTable = {
    1: [1, 6], // 丑, 午
    2: [9, 2], // 酉, 寅
    3: [0, 3], // 子, 卯
    4: [3, 4], // 卯, 辰
    5: [5, 6], // 巳, 午
    6: [9, 6], // 酉, 午
    7: [0, 7], // 子, 未
    8: [3, 8], // 卯, 申
    9: [9, 6], // 酉, 午
    10: [9, 10], // 酉, 戌
    11: [11, 0], // 亥, 子
    12: [3, 0], // 卯, 子
  };

  /// 寅の日 (Tora no hi) - Tiger day, every 12 days
  bool isToraNoHi(DateTime date) {
    return StemBranchCalculator.isToraNoHi(date);
  }

  /// 巳の日 (Mi no hi) - Snake day, every 12 days
  bool isMiNoHi(DateTime date) {
    return StemBranchCalculator.isMiNoHi(date);
  }

  /// 己巳の日 (Tsuchinoto-Mi no hi) - every 60 days
  bool isTsuchinotoMiNoHi(DateTime date) {
    return StemBranchCalculator.isTsuchinotoMiNoHi(date);
  }

  /// 不成就日 (Fujōju-bi) - Days of non-accomplishment
  ///
  /// Based on lunar month, starting from a specific day, repeating every 8 days:
  /// Lunar months 1,7: starting day 3 → 3,11,19,27
  /// Lunar months 2,8: starting day 2 → 2,10,18,26
  /// Lunar months 3,9: starting day 1 → 1,9,17,25
  /// Lunar months 4,10: starting day 4 → 4,12,20,28
  /// Lunar months 5,11: starting day 5 → 5,13,21,29
  /// Lunar months 6,12: starting day 6 → 6,14,22,30
  bool isFujoujubi(DateTime date) {
    final lunar = _lunarCalendar.toLunar(date);
    if (lunar == null) return false;

    final startDay = _fujoujubiStartDay(lunar.absoluteMonth);
    if (startDay == null) return false;

    final diff = lunar.day - startDay;
    return diff >= 0 && diff % 8 == 0;
  }

  int? _fujoujubiStartDay(int lunarMonth) {
    // Normalize month to 1-6 range (months 7-12 repeat the pattern)
    final normalizedMonth = ((lunarMonth - 1) % 6) + 1;
    switch (normalizedMonth) {
      case 1:
        return 3;
      case 2:
        return 2;
      case 3:
        return 1;
      case 4:
        return 4;
      case 5:
        return 5;
      case 6:
        return 6;
      default:
        return null;
    }
  }
}
