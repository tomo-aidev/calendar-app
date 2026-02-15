import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_calendar/models/user_profile.dart';
import 'package:lucky_calendar/services/fortune_service.dart';

void main() {
  late FortuneService service;

  setUp(() {
    service = FortuneService();
  });

  group('FortuneService', () {
    test('generates deterministic results for same date and profile', () {
      final date = DateTime(2026, 2, 11);
      final profile = UserProfile(
        name: 'テスト',
        gender: Gender.female,
        birthday: DateTime(1990, 5, 15),
        bloodType: BloodType.a,
      );

      final fortune1 = service.generate(date, profile);
      final fortune2 = service.generate(date, profile);

      expect(fortune1.overallLuck, fortune2.overallLuck);
      expect(fortune1.loveLuck, fortune2.loveLuck);
      expect(fortune1.workLuck, fortune2.workLuck);
      expect(fortune1.moneyLuck, fortune2.moneyLuck);
      expect(fortune1.healthLuck, fortune2.healthLuck);
      expect(fortune1.adviceMessage, fortune2.adviceMessage);
      expect(fortune1.luckyColor, fortune2.luckyColor);
      expect(fortune1.luckyNumber, fortune2.luckyNumber);
    });

    test('generates different results for different dates', () {
      final profile = UserProfile(
        name: 'テスト',
        gender: Gender.female,
        birthday: DateTime(1990, 5, 15),
        bloodType: BloodType.a,
      );

      final fortune1 = service.generate(DateTime(2026, 1, 1), profile);
      final fortune2 = service.generate(DateTime(2026, 1, 2), profile);

      // At least some values should differ (statistically very likely)
      final allSame = fortune1.overallLuck == fortune2.overallLuck &&
          fortune1.loveLuck == fortune2.loveLuck &&
          fortune1.workLuck == fortune2.workLuck &&
          fortune1.moneyLuck == fortune2.moneyLuck &&
          fortune1.healthLuck == fortune2.healthLuck;
      expect(allSame, false);
    });

    test('generates different results for different blood types', () {
      final date = DateTime(2026, 2, 11);
      final profileA = UserProfile(
        birthday: DateTime(1990, 5, 15),
        bloodType: BloodType.a,
      );
      final profileB = UserProfile(
        birthday: DateTime(1990, 5, 15),
        bloodType: BloodType.b,
      );

      final fortuneA = service.generate(date, profileA);
      final fortuneB = service.generate(date, profileB);

      // Results should differ for different blood types
      final allSame = fortuneA.overallLuck == fortuneB.overallLuck &&
          fortuneA.loveLuck == fortuneB.loveLuck &&
          fortuneA.workLuck == fortuneB.workLuck;
      expect(allSame, false);
    });

    test('luck values are always between 1 and 5', () {
      final profile = UserProfile(
        birthday: DateTime(1990, 5, 15),
        bloodType: BloodType.a,
      );

      // Test across many dates
      for (int i = 1; i <= 365; i++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: i));
        final fortune = service.generate(date, profile);

        expect(fortune.overallLuck, inInclusiveRange(1, 5));
        expect(fortune.loveLuck, inInclusiveRange(1, 5));
        expect(fortune.workLuck, inInclusiveRange(1, 5));
        expect(fortune.moneyLuck, inInclusiveRange(1, 5));
        expect(fortune.healthLuck, inInclusiveRange(1, 5));
      }
    });

    test('lucky number is between 1 and 9', () {
      final profile = UserProfile(
        birthday: DateTime(1990, 5, 15),
        bloodType: BloodType.o,
      );

      for (int i = 1; i <= 100; i++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: i));
        final fortune = service.generate(date, profile);
        expect(fortune.luckyNumber, inInclusiveRange(1, 9));
      }
    });

    test('lucky color is not empty', () {
      final profile = UserProfile(
        birthday: DateTime(1990, 5, 15),
      );
      final fortune = service.generate(DateTime(2026, 2, 11), profile);
      expect(fortune.luckyColor.isNotEmpty, true);
    });

    test('advice message is not empty', () {
      final profile = UserProfile(
        birthday: DateTime(1990, 5, 15),
      );
      final fortune = service.generate(DateTime(2026, 2, 11), profile);
      expect(fortune.adviceMessage.isNotEmpty, true);
    });

    test('works with minimal profile (no birthday, no blood type)', () {
      final profile = const UserProfile();
      final fortune = service.generate(DateTime(2026, 2, 11), profile);

      expect(fortune.overallLuck, inInclusiveRange(1, 5));
      expect(fortune.luckyColor.isNotEmpty, true);
    });
  });
}
