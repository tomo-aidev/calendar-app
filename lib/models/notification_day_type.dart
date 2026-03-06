import 'lucky_day.dart';
import 'rokuyo.dart';

/// Unified notification type bridging Rokuyo and LuckyDayType for lucky day notifications
enum NotificationDayType {
  taian,            // 大安 (from Rokuyo)
  tomobiki,         // 友引 (from Rokuyo)
  tenshanichi,      // 天赦日 (from LuckyDayType)
  ichiryuManbaibi,  // 一粒万倍日 (from LuckyDayType)
  toranohi,         // 寅の日 (from LuckyDayType)
  minohi,           // 巳の日 (from LuckyDayType)
  tsuchinotoMinohi, // 己巳の日 (from LuckyDayType)
}

extension NotificationDayTypeExtension on NotificationDayType {
  String get displayName {
    switch (this) {
      case NotificationDayType.taian:
        return '大安';
      case NotificationDayType.tomobiki:
        return '友引';
      case NotificationDayType.tenshanichi:
        return '天赦日';
      case NotificationDayType.ichiryuManbaibi:
        return '一粒万倍日';
      case NotificationDayType.toranohi:
        return '寅の日';
      case NotificationDayType.minohi:
        return '巳の日';
      case NotificationDayType.tsuchinotoMinohi:
        return '己巳の日';
    }
  }

  /// Settings key for per-type toggle
  String get settingsKey {
    return 'luckyDayNotify_$name';
  }

  /// Check if a Rokuyo value matches this notification type
  bool matchesRokuyo(Rokuyo rokuyo) {
    switch (this) {
      case NotificationDayType.taian:
        return rokuyo == Rokuyo.taian;
      case NotificationDayType.tomobiki:
        return rokuyo == Rokuyo.tomobiki;
      default:
        return false;
    }
  }

  /// Check if a LuckyDayType matches this notification type
  bool matchesLuckyDayType(LuckyDayType luckyDayType) {
    switch (this) {
      case NotificationDayType.tenshanichi:
        return luckyDayType == LuckyDayType.tenshanichi;
      case NotificationDayType.ichiryuManbaibi:
        return luckyDayType == LuckyDayType.ichiryuManbaibi;
      case NotificationDayType.toranohi:
        return luckyDayType == LuckyDayType.toranohi;
      case NotificationDayType.minohi:
        return luckyDayType == LuckyDayType.minohi;
      case NotificationDayType.tsuchinotoMinohi:
        return luckyDayType == LuckyDayType.tsuchinotoMinohi;
      default:
        return false;
    }
  }

  /// Get all matching NotificationDayTypes for a given Rokuyo and LuckyDayType list
  static List<NotificationDayType> getMatchingTypes({
    required Rokuyo rokuyo,
    required List<LuckyDayType> luckyDays,
  }) {
    final result = <NotificationDayType>[];

    for (final type in NotificationDayType.values) {
      if (type.matchesRokuyo(rokuyo)) {
        result.add(type);
      } else {
        for (final luckyDay in luckyDays) {
          if (type.matchesLuckyDayType(luckyDay)) {
            result.add(type);
            break;
          }
        }
      }
    }

    return result;
  }
}
