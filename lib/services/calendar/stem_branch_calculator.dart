/// 干支 (Stem-Branch / Sexagenary Cycle) Calculator
///
/// Calculates the position of any date in the 60-day cycle combining
/// 10 Heavenly Stems (天干) and 12 Earthly Branches (地支).
class StemBranchCalculator {
  StemBranchCalculator._();

  // Reference: 1970-01-01 is 辛巳 (Kanoto-Mi), position 17 in 0-indexed cycle
  static const int _epochOffset = 17;
  static final DateTime _epoch = DateTime(1970, 1, 1);

  // 天干 (Heavenly Stems)
  static const List<String> stems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸',
  ];

  // 地支 (Earthly Branches)
  static const List<String> branches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥',
  ];

  /// Returns the position in the 60-day cycle (0-59)
  static int cyclePosition(DateTime date) {
    final days = DateTime(date.year, date.month, date.day)
        .difference(_epoch)
        .inDays;
    return ((days + _epochOffset) % 60 + 60) % 60; // ensure positive
  }

  /// Returns the Heavenly Stem index (0-9)
  static int stemIndex(DateTime date) {
    return cyclePosition(date) % 10;
  }

  /// Returns the Earthly Branch index (0-11)
  /// 0=子, 1=丑, 2=寅, 3=卯, 4=辰, 5=巳, 6=午, 7=未, 8=申, 9=酉, 10=戌, 11=亥
  static int branchIndex(DateTime date) {
    return cyclePosition(date) % 12;
  }

  /// Returns the Heavenly Stem name
  static String stemName(DateTime date) {
    return stems[stemIndex(date)];
  }

  /// Returns the Earthly Branch name
  static String branchName(DateTime date) {
    return branches[branchIndex(date)];
  }

  /// Returns the full stem-branch name (e.g., "甲子")
  static String fullName(DateTime date) {
    return '${stemName(date)}${branchName(date)}';
  }

  /// Check if the date is a 寅の日 (Tora no hi - Tiger day)
  static bool isToraNoHi(DateTime date) {
    return branchIndex(date) == 2; // 寅 = index 2
  }

  /// Check if the date is a 巳の日 (Mi no hi - Snake day)
  static bool isMiNoHi(DateTime date) {
    return branchIndex(date) == 5; // 巳 = index 5
  }

  /// Check if the date is a 己巳の日 (Tsuchinoto-Mi no hi)
  /// Heavenly Stem 己 (index 5) + Earthly Branch 巳 (index 5)
  /// This is position 5 in the 60-day cycle
  static bool isTsuchinotoMiNoHi(DateTime date) {
    return cyclePosition(date) == 5;
  }
}
