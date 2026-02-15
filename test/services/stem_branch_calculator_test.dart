import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_calendar/services/calendar/stem_branch_calculator.dart';

void main() {
  group('StemBranchCalculator', () {
    test('1970-01-01 should be 庚戌 (position 46)', () {
      final date = DateTime(1970, 1, 1);
      expect(StemBranchCalculator.cyclePosition(date), 46);
      expect(StemBranchCalculator.stemName(date), '庚'); // index 6
      expect(StemBranchCalculator.branchName(date), '戌'); // index 10
      expect(StemBranchCalculator.fullName(date), '庚戌');
    });

    test('1970-01-02 should be position 47 (辛亥)', () {
      final date = DateTime(1970, 1, 2);
      expect(StemBranchCalculator.cyclePosition(date), 47);
      expect(StemBranchCalculator.fullName(date), '辛亥');
    });

    test('cycle position wraps around at 60', () {
      // 60 days after position 0 should also be position 0
      // Position 0 is 甲子. From 1970-01-01 (pos 46), we need
      // to go 14 days forward to reach position 0 (60 - 46 = 14)
      final date = DateTime(1970, 1, 15);
      expect(StemBranchCalculator.cyclePosition(date), 0);
      expect(StemBranchCalculator.fullName(date), '甲子');
    });

    test('60 days later returns same cycle position', () {
      final date1 = DateTime(2026, 1, 1);
      final date2 = DateTime(2026, 3, 2); // 60 days later
      expect(
        StemBranchCalculator.cyclePosition(date1),
        StemBranchCalculator.cyclePosition(date2),
      );
    });

    test('isToraNoHi correctly identifies tiger days (branch index 2)', () {
      // Find a 寅の日 by checking branch index
      // From 1970-01-01 (pos 46, branch=10=戌), we need branch=2=寅
      // Branch increments by 1 each day, so need 4 days: 1970-01-05 (pos 50, branch=2)
      // Wait, branch = pos % 12, so pos 50 % 12 = 2 ✓
      final toraDay = DateTime(1970, 1, 5);
      expect(StemBranchCalculator.branchIndex(toraDay), 2);
      expect(StemBranchCalculator.isToraNoHi(toraDay), true);

      // Next day should not be tiger day
      final nextDay = DateTime(1970, 1, 6);
      expect(StemBranchCalculator.isToraNoHi(nextDay), false);
    });

    test('isMiNoHi correctly identifies snake days (branch index 5)', () {
      // branch=5=巳, pos 50+3=53, 53%12=5 ✓
      final miDay = DateTime(1970, 1, 8);
      expect(StemBranchCalculator.branchIndex(miDay), 5);
      expect(StemBranchCalculator.isMiNoHi(miDay), true);
    });

    test('isTsuchinotoMiNoHi correctly identifies position 5', () {
      // Position 5 in cycle = 己巳
      // From 1970-01-01 (pos 46), pos 5 is 46->5 means going forward 19 days
      // (5 - 46 + 60) = 19
      final tsuchinotoMi = DateTime(1970, 1, 20);
      expect(StemBranchCalculator.cyclePosition(tsuchinotoMi), 5);
      expect(StemBranchCalculator.isTsuchinotoMiNoHi(tsuchinotoMi), true);
      // Also verify it's 己巳
      expect(StemBranchCalculator.stemName(tsuchinotoMi), '己');
      expect(StemBranchCalculator.branchName(tsuchinotoMi), '巳');
    });

    test('stem_index returns values 0-9', () {
      for (int i = 0; i < 10; i++) {
        final date = DateTime(1970, 1, 1).add(Duration(days: i));
        final stemIdx = StemBranchCalculator.stemIndex(date);
        expect(stemIdx, greaterThanOrEqualTo(0));
        expect(stemIdx, lessThan(10));
      }
    });

    test('branch_index returns values 0-11', () {
      for (int i = 0; i < 12; i++) {
        final date = DateTime(1970, 1, 1).add(Duration(days: i));
        final branchIdx = StemBranchCalculator.branchIndex(date);
        expect(branchIdx, greaterThanOrEqualTo(0));
        expect(branchIdx, lessThan(12));
      }
    });

    test('handles dates before epoch correctly', () {
      final date = DateTime(1969, 12, 31);
      final pos = StemBranchCalculator.cyclePosition(date);
      expect(pos, 45); // One day before 46
      expect(pos, greaterThanOrEqualTo(0));
      expect(pos, lessThan(60));
    });

    test('handles dates in 2026 range', () {
      final date = DateTime(2026, 2, 11);
      final pos = StemBranchCalculator.cyclePosition(date);
      expect(pos, greaterThanOrEqualTo(0));
      expect(pos, lessThan(60));
      // Verify stem and branch are valid
      expect(StemBranchCalculator.stems.contains(StemBranchCalculator.stemName(date)), true);
      expect(StemBranchCalculator.branches.contains(StemBranchCalculator.branchName(date)), true);
    });
  });
}
