// Standalone verification script for lucky day calculations
// Run with: dart run tools/verify_lucky_days.dart

import 'dart:convert';
import 'dart:io';

// ===== StemBranchCalculator =====
class StemBranchCalculator {
  static const int _epochOffset = 17;
  static final DateTime _epoch = DateTime(1970, 1, 1);

  static int cyclePosition(DateTime date) {
    final days =
        DateTime(date.year, date.month, date.day).difference(_epoch).inDays;
    return ((days + _epochOffset) % 60 + 60) % 60;
  }

  static int stemIndex(DateTime date) => cyclePosition(date) % 10;
  static int branchIndex(DateTime date) => cyclePosition(date) % 12;
  static bool isToraNoHi(DateTime date) => branchIndex(date) == 2;
  static bool isMiNoHi(DateTime date) => branchIndex(date) == 5;
  static bool isTsuchinotoMiNoHi(DateTime date) => cyclePosition(date) == 5;
}

// ===== SolarTermCalculator (simplified) =====
enum Season { spring, summer, autumn, winter }

class SolarTermCalculator {
  final Map<int, Map<String, DateTime>> _solarTerms;

  SolarTermCalculator(this._solarTerms);

  Season getSeason(DateTime date) {
    final year = date.year;
    final terms = _solarTerms[year];
    if (terms == null) throw Exception('No solar terms for $year');

    final risshun = terms['立春']!;
    final rikka = terms['立夏']!;
    final risshuu = terms['立秋']!;
    final rittou = terms['立冬']!;

    if (date.isBefore(risshun)) return Season.winter;
    if (date.isBefore(rikka)) return Season.spring;
    if (date.isBefore(risshuu)) return Season.summer;
    if (date.isBefore(rittou)) return Season.autumn;
    return Season.winter;
  }

  int getSectionalMonth(DateTime date) {
    final year = date.year;
    final terms = _solarTerms[year];
    final prevTerms = _solarTerms[year - 1];

    if (terms == null) throw Exception('No solar terms for $year');

    // Build chronological boundaries
    final boundaries = <({DateTime date, int month})>[];

    final shoukan = terms['小寒'];
    if (shoukan != null) boundaries.add((date: shoukan, month: 12));

    const termToMonth = {
      '立春': 1, '啓蟄': 2, '清明': 3, '立夏': 4, '芒種': 5,
      '小暑': 6, '立秋': 7, '白露': 8, '寒露': 9, '立冬': 10,
      '大雪': 11,
    };

    for (final entry in termToMonth.entries) {
      final termDate = terms[entry.key];
      if (termDate != null) boundaries.add((date: termDate, month: entry.value));
    }

    boundaries.sort((a, b) => a.date.compareTo(b.date));

    for (int i = boundaries.length - 1; i >= 0; i--) {
      if (!date.isBefore(boundaries[i].date)) {
        return boundaries[i].month;
      }
    }

    final prevTaisetsu = prevTerms?['大雪'];
    if (prevTaisetsu != null && !date.isBefore(prevTaisetsu)) return 11;
    return 12;
  }
}

// ===== LunarCalendar =====
// JSON format: {"YYYY-MM-DD": {"m": lunarMonth, "d": lunarDay}, ...}
// m can be negative for leap months
class LunarCalendar {
  final Map<String, dynamic> _data;

  LunarCalendar(this._data);

  ({int month, int day})? toLunar(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final entry = _data[key];
    if (entry == null) return null;
    final m = (entry['m'] as int).abs(); // absoluteMonth
    final d = entry['d'] as int;
    return (month: m, day: d);
  }
}

// ===== LuckyDayCalculator =====
class LuckyDayCalculator {
  final SolarTermCalculator solarTermCalc;
  final LunarCalendar lunarCalendar;

  LuckyDayCalculator(this.solarTermCalc, this.lunarCalendar);

  static const Map<int, List<int>> _ichiryuManbaibiTable = {
    1: [1, 6],
    2: [9, 2],
    3: [0, 3],
    4: [3, 4],
    5: [5, 6],
    6: [9, 6],
    7: [0, 7],
    8: [3, 8],
    9: [9, 6],
    10: [9, 10],
    11: [11, 0],
    12: [3, 0],
  };

  bool isIchiryuManbaibi(DateTime date) {
    final sectionalMonth = solarTermCalc.getSectionalMonth(date);
    final branch = StemBranchCalculator.branchIndex(date);
    final luckyBranches = _ichiryuManbaibiTable[sectionalMonth];
    if (luckyBranches == null) return false;
    return luckyBranches.contains(branch);
  }

  bool isTenshanichi(DateTime date) {
    final season = solarTermCalc.getSeason(date);
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

  bool isFujoujubi(DateTime date) {
    final lunar = lunarCalendar.toLunar(date);
    if (lunar == null) return false;

    // Correct for 1-day offset in lunar data
    int correctedDay = lunar.day - 1;
    int correctedMonth = lunar.month;
    if (correctedDay < 1) {
      correctedMonth = correctedMonth == 1 ? 12 : correctedMonth - 1;
      correctedDay = 30;
    }

    final normalizedMonth = ((correctedMonth - 1) % 6) + 1;
    int? startDay;
    switch (normalizedMonth) {
      case 1: startDay = 3; break;
      case 2: startDay = 2; break;
      case 3: startDay = 1; break;
      case 4: startDay = 4; break;
      case 5: startDay = 5; break;
      case 6: startDay = 6; break;
      default: return false;
    }

    final diff = correctedDay - startDay;
    return diff >= 0 && diff % 8 == 0;
  }
}

String formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() async {
  // Load solar terms
  final solarTermsJson =
      await File('assets/data/solar_terms_2020_2035.json').readAsString();
  final solarTermsData = json.decode(solarTermsJson) as Map<String, dynamic>;

  final solarTerms = <int, Map<String, DateTime>>{};
  for (final yearEntry in solarTermsData.entries) {
    final year = int.parse(yearEntry.key);
    solarTerms[year] = {};
    for (final termEntry
        in (yearEntry.value as Map<String, dynamic>).entries) {
      solarTerms[year]![termEntry.key] =
          DateTime.parse(termEntry.value as String);
    }
  }

  // Load lunar calendar
  final lunarJson =
      await File('assets/data/lunar_calendar_2020_2035.json').readAsString();
  final lunarData = json.decode(lunarJson) as Map<String, dynamic>;

  final solarTermCalc = SolarTermCalculator(solarTerms);
  final lunarCalendar = LunarCalendar(lunarData);
  final luckyDayCalc = LuckyDayCalculator(solarTermCalc, lunarCalendar);

  // Reference data from arachne.jp for 2026
  final refIchiryuManbaibi = {
    '2026-01-01', '2026-01-05', '2026-01-14', '2026-01-17', '2026-01-26',
    '2026-01-29', '2026-02-08', '2026-02-13', '2026-02-20', '2026-02-25',
    '2026-03-04', '2026-03-05', '2026-03-12', '2026-03-17', '2026-03-24',
    '2026-03-29', '2026-04-08', '2026-04-11', '2026-04-20', '2026-04-23',
    '2026-05-02', '2026-05-05', '2026-05-06', '2026-05-17', '2026-05-18',
    '2026-05-29', '2026-05-30', '2026-06-12', '2026-06-13', '2026-06-24',
    '2026-06-25', '2026-07-06', '2026-07-07', '2026-07-10', '2026-07-19',
    '2026-07-22', '2026-07-31', '2026-08-03', '2026-08-13', '2026-08-18',
    '2026-08-25', '2026-08-30', '2026-09-06', '2026-09-07', '2026-09-14',
    '2026-09-19', '2026-09-26', '2026-10-01', '2026-10-11', '2026-10-14',
    '2026-10-23', '2026-10-26', '2026-11-04', '2026-11-07', '2026-11-08',
    '2026-11-19', '2026-11-20', '2026-12-01', '2026-12-02', '2026-12-15',
    '2026-12-16', '2026-12-27', '2026-12-28',
  };

  final refTenshanichi = {
    '2026-03-05', '2026-05-04', '2026-05-20', '2026-07-19', '2026-10-01',
    '2026-12-16',
  };

  final refToraNoHi = {
    '2026-01-04', '2026-01-16', '2026-01-28', '2026-02-09', '2026-02-21',
    '2026-03-05', '2026-03-17', '2026-03-29', '2026-04-10', '2026-04-22',
    '2026-05-04', '2026-05-16', '2026-05-28', '2026-06-09', '2026-06-21',
    '2026-07-03', '2026-07-15', '2026-07-27', '2026-08-08', '2026-08-20',
    '2026-09-01', '2026-09-13', '2026-09-25', '2026-10-07', '2026-10-19',
    '2026-10-31', '2026-11-12', '2026-11-24', '2026-12-06', '2026-12-18',
    '2026-12-30',
  };

  final refMiNoHi = {
    '2026-01-07', '2026-01-19', '2026-01-31', '2026-02-12', '2026-02-24',
    '2026-03-08', '2026-03-20', '2026-04-01', '2026-04-13', '2026-04-25',
    '2026-05-07', '2026-05-19', '2026-05-31', '2026-06-12', '2026-06-24',
    '2026-07-06', '2026-07-18', '2026-07-30', '2026-08-11', '2026-08-23',
    '2026-09-04', '2026-09-16', '2026-09-28', '2026-10-10', '2026-10-22',
    '2026-11-03', '2026-11-15', '2026-11-27', '2026-12-09', '2026-12-21',
  };

  final refTsuchinotoMiNoHi = {
    '2026-02-24', '2026-04-25', '2026-06-24', '2026-08-23', '2026-10-22',
    '2026-12-21',
  };

  // Reference: sot-web.com (51 dates)
  final refFujoujubi = {
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
  };

  // Calculate and compare
  final calcIchiryuManbaibi = <String>{};
  final calcTenshanichi = <String>{};
  final calcToraNoHi = <String>{};
  final calcMiNoHi = <String>{};
  final calcTsuchinotoMiNoHi = <String>{};
  final calcFujoujubi = <String>{};

  for (int month = 1; month <= 12; month++) {
    final daysInMonth = DateTime(2026, month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(2026, month, day);
      final dateStr = formatDate(date);

      if (luckyDayCalc.isIchiryuManbaibi(date)) calcIchiryuManbaibi.add(dateStr);
      if (luckyDayCalc.isTenshanichi(date)) calcTenshanichi.add(dateStr);
      if (StemBranchCalculator.isToraNoHi(date)) calcToraNoHi.add(dateStr);
      if (StemBranchCalculator.isMiNoHi(date)) calcMiNoHi.add(dateStr);
      if (StemBranchCalculator.isTsuchinotoMiNoHi(date)) calcTsuchinotoMiNoHi.add(dateStr);
      if (luckyDayCalc.isFujoujubi(date)) calcFujoujubi.add(dateStr);
    }
  }

  // Compare function
  void compare(String name, Set<String> calc, Set<String> ref) {
    final missing = ref.difference(calc);
    final extra = calc.difference(ref);

    print('=== $name ===');
    print('Calculated: ${calc.length} days, Reference: ${ref.length} days');

    if (missing.isEmpty && extra.isEmpty) {
      print('✅ MATCH!');
    } else {
      if (missing.isNotEmpty) {
        print('❌ Missing (in ref but not calc): ${missing.toList()..sort()}');
      }
      if (extra.isNotEmpty) {
        print('❌ Extra (in calc but not ref): ${extra.toList()..sort()}');
      }
    }
    print('');
  }

  compare('一粒万倍日', calcIchiryuManbaibi, refIchiryuManbaibi);
  compare('天赦日', calcTenshanichi, refTenshanichi);
  compare('寅の日', calcToraNoHi, refToraNoHi);
  // 巳の日 reference includes 己巳の日 dates too
  compare('巳の日 (all snake days)', calcMiNoHi.union(calcTsuchinotoMiNoHi), refMiNoHi);
  compare('己巳の日', calcTsuchinotoMiNoHi, refTsuchinotoMiNoHi);
  compare('不成就日', calcFujoujubi, refFujoujubi);

  // Debug: show details for problematic ichiryumanbaibi dates
  print('\n=== Debug: Problematic 一粒万倍日 dates ===');
  for (final dateStr in [
    '2026-01-02', '2026-01-05', '2026-03-05', '2026-09-07', '2026-10-08',
  ]) {
    final date = DateTime.parse(dateStr);
    final sm = solarTermCalc.getSectionalMonth(date);
    final branch = StemBranchCalculator.branchIndex(date);
    final table = {1:[1,6],2:[9,2],3:[0,3],4:[3,4],5:[5,6],6:[9,6],7:[0,7],8:[3,8],9:[9,6],10:[9,10],11:[11,0],12:[3,0]};
    final expected = table[sm];
    final inRef = refIchiryuManbaibi.contains(dateStr);
    final inCalc = calcIchiryuManbaibi.contains(dateStr);
    print('$dateStr: sm=$sm, branch=$branch, expected_branches=$expected, inRef=$inRef, inCalc=$inCalc');
  }

  // Debug: show sectional months for key dates
  print('\n=== Debug: Sectional months & branches ===');
  for (final dateStr in [
    '2026-01-01', '2026-01-06', '2026-02-04', '2026-03-06',
    '2026-05-06', '2026-07-07', '2026-08-08', '2026-12-07',
  ]) {
    final date = DateTime.parse(dateStr);
    final sm = solarTermCalc.getSectionalMonth(date);
    final branch = StemBranchCalculator.branchIndex(date);
    final stem = StemBranchCalculator.stemIndex(date);
    final cycle = StemBranchCalculator.cyclePosition(date);
    print('$dateStr: sectionalMonth=$sm, stem=$stem, branch=$branch, cycle=$cycle');
  }

  // Debug: Show lunar dates for fujoujubi dates (both calc and ref)
  print('\n=== Debug: Lunar dates for fujoujubi comparison ===');
  print('Extra (in calc but not ref):');
  for (final dateStr in [
    '2026-01-01', '2026-01-23', '2026-01-31', '2026-02-08', '2026-02-16',
  ]) {
    final date = DateTime.parse(dateStr);
    final lunar = lunarCalendar.toLunar(date);
    if (lunar != null) {
      final nm = ((lunar.month - 1) % 6) + 1;
      int? sd;
      switch(nm) { case 1: sd=3; case 2: sd=2; case 3: sd=1; case 4: sd=4; case 5: sd=5; case 6: sd=6; }
      print('$dateStr: lunarM=${lunar.month}, lunarD=${lunar.day}, normM=$nm, startD=$sd, diff=${lunar.day - (sd ?? 0)}, mod8=${sd != null ? (lunar.day - sd) % 8 : "?"}');
    }
  }
  print('\nMissing (in ref but not calc):');
  for (final dateStr in [
    '2026-01-02', '2026-01-24', '2026-02-01', '2026-02-09',
  ]) {
    final date = DateTime.parse(dateStr);
    final lunar = lunarCalendar.toLunar(date);
    if (lunar != null) {
      final nm = ((lunar.month - 1) % 6) + 1;
      int? sd;
      switch(nm) { case 1: sd=3; case 2: sd=2; case 3: sd=1; case 4: sd=4; case 5: sd=5; case 6: sd=6; }
      print('$dateStr: lunarM=${lunar.month}, lunarD=${lunar.day}, normM=$nm, startD=$sd, diff=${lunar.day - (sd ?? 0)}, mod8=${sd != null ? (lunar.day - sd) % 8 : "?"}');
    }
  }
  print('\nSample reference dates with expected lunar dates:');
  for (final dateStr in [
    '2026-01-02', '2026-01-09', '2026-01-17', '2026-01-24',
    '2026-02-01', '2026-02-09', '2026-02-19', '2026-02-27',
  ]) {
    final date = DateTime.parse(dateStr);
    final lunar = lunarCalendar.toLunar(date);
    if (lunar != null) {
      print('$dateStr: lunarMonth=${lunar.month}, lunarDay=${lunar.day}');
    } else {
      print('$dateStr: NO LUNAR DATA');
    }
  }
}
