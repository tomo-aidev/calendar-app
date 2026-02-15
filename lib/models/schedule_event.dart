enum RepeatType { none, daily, weekly, monthly, yearly }

extension RepeatTypeExtension on RepeatType {
  String get displayName {
    switch (this) {
      case RepeatType.none:
        return 'なし';
      case RepeatType.daily:
        return '毎日';
      case RepeatType.weekly:
        return '毎週';
      case RepeatType.monthly:
        return '毎月';
      case RepeatType.yearly:
        return '毎年';
    }
  }
}

class NotifyBefore {
  static const Duration none = Duration.zero;
  static const Duration fiveMinutes = Duration(minutes: 5);
  static const Duration fifteenMinutes = Duration(minutes: 15);
  static const Duration thirtyMinutes = Duration(minutes: 30);
  static const Duration oneHour = Duration(hours: 1);
  static const Duration oneDay = Duration(days: 1);

  static const List<Duration> options = [
    none,
    fiveMinutes,
    fifteenMinutes,
    thirtyMinutes,
    oneHour,
    oneDay,
  ];

  static String displayName(Duration duration) {
    if (duration == Duration.zero) return 'なし';
    if (duration == fiveMinutes) return '5分前';
    if (duration == fifteenMinutes) return '15分前';
    if (duration == thirtyMinutes) return '30分前';
    if (duration == oneHour) return '1時間前';
    if (duration == oneDay) return '1日前';
    return '${duration.inMinutes}分前';
  }
}

class TravelTime {
  static const Duration none = Duration.zero;
  static const Duration fiveMinutes = Duration(minutes: 5);
  static const Duration fifteenMinutes = Duration(minutes: 15);
  static const Duration thirtyMinutes = Duration(minutes: 30);
  static const Duration oneHour = Duration(hours: 1);
  static const Duration twoHours = Duration(hours: 2);

  static const List<Duration> options = [
    none,
    fiveMinutes,
    fifteenMinutes,
    thirtyMinutes,
    oneHour,
    twoHours,
  ];

  static String displayName(Duration duration) {
    if (duration == Duration.zero) return 'なし';
    if (duration.inHours >= 1) return '${duration.inHours}時間';
    return '${duration.inMinutes}分';
  }
}

class ScheduleEvent {
  final String id;
  final String title;
  final String? location;
  final DateTime date;
  final bool isAllDay;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration travelTime;
  final RepeatType repeat;
  final Duration notifyBefore;
  final String? nativeCalendarId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleEvent({
    required this.id,
    required this.title,
    this.location,
    required this.date,
    this.isAllDay = true,
    this.startTime,
    this.endTime,
    this.travelTime = Duration.zero,
    this.repeat = RepeatType.none,
    this.notifyBefore = Duration.zero,
    this.nativeCalendarId,
    required this.createdAt,
    required this.updatedAt,
  });

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? date,
    bool? isAllDay,
    DateTime? startTime,
    DateTime? endTime,
    Duration? travelTime,
    RepeatType? repeat,
    Duration? notifyBefore,
    String? nativeCalendarId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      isAllDay: isAllDay ?? this.isAllDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      travelTime: travelTime ?? this.travelTime,
      repeat: repeat ?? this.repeat,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      nativeCalendarId: nativeCalendarId ?? this.nativeCalendarId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
