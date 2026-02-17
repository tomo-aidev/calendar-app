import '../../models/lucky_day.dart';
import 'solar_term_calculator.dart';
import 'stem_branch_calculator.dart';

/// Calculator for all types of lucky/unlucky days (吉日・凶日)
class LuckyDayCalculator {
  final SolarTermCalculator _solarTermCalculator;

  LuckyDayCalculator({
    SolarTermCalculator? solarTermCalculator,
  })  : _solarTermCalculator =
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
  /// Uses pre-computed lookup table for accuracy.
  /// Data verified against multiple Japanese calendar reference sites
  /// (sot-web.com, hotdoglab.jp, arachne.jp).
  bool isFujoujubi(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _fujoujubiDates.contains(key);
  }

  // Pre-computed 不成就日 dates (2025-2028)
  // Source: cross-referenced from sot-web.com, hotdoglab.jp
  static final Set<String> _fujoujubiDates = {
    // 2025
    '2025-01-02', '2025-01-10', '2025-01-18', '2025-01-26',
    '2025-02-02', '2025-02-10', '2025-02-12', '2025-02-20',
    '2025-02-28', '2025-03-08', '2025-03-11', '2025-03-19',
    '2025-03-27', '2025-04-04', '2025-04-09', '2025-04-17',
    '2025-04-25', '2025-05-03', '2025-05-11', '2025-05-19',
    '2025-05-27', '2025-06-04', '2025-06-15', '2025-06-23',
    '2025-07-01', '2025-07-09', '2025-07-13', '2025-07-21',
    '2025-07-29', '2025-08-06', '2025-08-14', '2025-08-22',
    '2025-08-26', '2025-09-03', '2025-09-11', '2025-09-19',
    '2025-09-24', '2025-10-02', '2025-10-10', '2025-10-18',
    '2025-10-21', '2025-10-29', '2025-11-06', '2025-11-14',
    '2025-11-22', '2025-11-30', '2025-12-08', '2025-12-16',
    '2025-12-20', '2025-12-28',
    // 2026
    '2026-01-01', '2026-01-09', '2026-01-17', '2026-01-24',
    '2026-02-01', '2026-02-09', '2026-02-19', '2026-02-27',
    '2026-03-07', '2026-03-15', '2026-03-20', '2026-03-28',
    '2026-04-05', '2026-04-13', '2026-04-17', '2026-04-25',
    '2026-05-03', '2026-05-11', '2026-05-20', '2026-05-28',
    '2026-06-05', '2026-06-13', '2026-06-19', '2026-06-27',
    '2026-07-05', '2026-07-13', '2026-07-19', '2026-07-27',
    '2026-08-04', '2026-08-12', '2026-08-15', '2026-08-23', '2026-08-31',
    '2026-09-08', '2026-09-12', '2026-09-20', '2026-09-28',
    '2026-10-06', '2026-10-11', '2026-10-19', '2026-10-27',
    '2026-11-04', '2026-11-12', '2026-11-20', '2026-11-28',
    '2026-12-06', '2026-12-13', '2026-12-21', '2026-12-29',
    // 2027
    '2027-01-06', '2027-01-13', '2027-01-21', '2027-01-29',
    '2027-02-06', '2027-02-09', '2027-02-17', '2027-02-25',
    '2027-03-05', '2027-03-09', '2027-03-17', '2027-03-25',
    '2027-04-02', '2027-04-07', '2027-04-15', '2027-04-23',
    '2027-05-01', '2027-05-09', '2027-05-17', '2027-05-25',
    '2027-06-02', '2027-06-09', '2027-06-17', '2027-06-25',
    '2027-07-03', '2027-07-09', '2027-07-17', '2027-07-25',
    '2027-08-04', '2027-08-12', '2027-08-20', '2027-08-28',
    '2027-09-02', '2027-09-10', '2027-09-18', '2027-09-26', '2027-09-30',
    '2027-10-08', '2027-10-16', '2027-10-24',
    '2027-11-01', '2027-11-09', '2027-11-17', '2027-11-25',
    '2027-12-02', '2027-12-10', '2027-12-18', '2027-12-26',
    // 2028
    '2028-01-02', '2028-01-10', '2028-01-18', '2028-01-26', '2028-01-29',
    '2028-02-06', '2028-02-14', '2028-02-22', '2028-02-26',
    '2028-03-05', '2028-03-13', '2028-03-21', '2028-03-26',
    '2028-04-03', '2028-04-11', '2028-04-19', '2028-04-28',
    '2028-05-06', '2028-05-14', '2028-05-22', '2028-05-28',
    '2028-06-05', '2028-06-13', '2028-06-21', '2028-06-27',
    '2028-07-05', '2028-07-13', '2028-07-21', '2028-07-27',
    '2028-08-04', '2028-08-12', '2028-08-22', '2028-08-30',
    '2028-09-07', '2028-09-15', '2028-09-20', '2028-09-28',
    '2028-10-06', '2028-10-14', '2028-10-18', '2028-10-26',
    '2028-11-03', '2028-11-11', '2028-11-19', '2028-11-27',
    '2028-12-05', '2028-12-13', '2028-12-20', '2028-12-28',
  };
}
