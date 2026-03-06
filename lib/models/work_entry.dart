import 'package:flutter/material.dart';
import '../config/colors.dart';

enum WorkEntryType { shift, workFromHome, holiday }

extension WorkEntryTypeExtension on WorkEntryType {
  String get displayName {
    switch (this) {
      case WorkEntryType.shift:
        return 'シフト';
      case WorkEntryType.workFromHome:
        return '在宅';
      case WorkEntryType.holiday:
        return '休日';
    }
  }

  String get emoji {
    switch (this) {
      case WorkEntryType.shift:
        return '🏢';
      case WorkEntryType.workFromHome:
        return '🏠';
      case WorkEntryType.holiday:
        return '🌸';
    }
  }

  Color get color {
    switch (this) {
      case WorkEntryType.shift:
        return AppColors.workShift;
      case WorkEntryType.workFromHome:
        return AppColors.workFromHome;
      case WorkEntryType.holiday:
        return AppColors.workHoliday;
    }
  }
}

/// Individual work entry for a specific date (overrides weekly routine)
class WorkEntry {
  final String id;
  final DateTime date;
  final WorkEntryType type;
  final DateTime createdAt;

  const WorkEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkEntry.fromMap(Map<String, dynamic> map) {
    return WorkEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      type: WorkEntryType.values[map['type'] as int],
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  WorkEntry copyWith({
    String? id,
    DateTime? date,
    WorkEntryType? type,
    DateTime? createdAt,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// タイプ別の勤務スケジュール設定（履歴管理対応）
class WorkScheduleConfig {
  /// 開始時間（時）— シフト・在宅のみ、休日はnull
  final int? startHour;

  /// 開始時間（分）— シフト・在宅のみ、休日はnull
  final int? startMinute;

  /// 繰り返し曜日 (1=月曜, 7=日曜)
  final Set<int> repeatWeekdays;

  /// リマインダー通知（分前）: 0=なし, 30, 60, 90, 120
  final int reminderMinutes;

  /// この設定が有効になった日（当日以降に適用）
  final DateTime effectiveFrom;

  WorkScheduleConfig({
    this.startHour,
    this.startMinute,
    this.repeatWeekdays = const {},
    this.reminderMinutes = 0,
    DateTime? effectiveFrom,
  }) : effectiveFrom = effectiveFrom ?? DateTime(2000, 1, 1);

  WorkScheduleConfig copyWith({
    int? startHour,
    int? startMinute,
    Set<int>? repeatWeekdays,
    int? reminderMinutes,
    DateTime? effectiveFrom,
  }) {
    return WorkScheduleConfig(
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      repeatWeekdays: repeatWeekdays ?? this.repeatWeekdays,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startHour': startHour,
      'startMinute': startMinute,
      'repeatWeekdays': repeatWeekdays.toList(),
      'reminderMinutes': reminderMinutes,
      'effectiveFrom': effectiveFrom.toIso8601String(),
    };
  }

  factory WorkScheduleConfig.fromMap(Map<String, dynamic> map) {
    return WorkScheduleConfig(
      startHour: map['startHour'] as int?,
      startMinute: map['startMinute'] as int?,
      repeatWeekdays: (map['repeatWeekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          {},
      reminderMinutes: (map['reminderMinutes'] as int?) ?? 0,
      effectiveFrom: map['effectiveFrom'] != null
          ? DateTime.parse(map['effectiveFrom'] as String)
          : DateTime(2000, 1, 1),
    );
  }
}
