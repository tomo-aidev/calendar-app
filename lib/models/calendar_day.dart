import 'anniversary_event.dart';
import 'lucky_day.dart';
import 'rokuyo.dart';
import 'schedule_event.dart';
import 'work_entry.dart';

/// Composite model representing a single calendar day with all its metadata
class CalendarDay {
  final DateTime date;
  final Rokuyo rokuyo;
  final List<LuckyDayType> luckyDays;
  final List<ScheduleEvent> events;
  final List<AnniversaryEvent> anniversaries;
  final String? holiday;
  final WorkEntryType? workType;
  final int? workStartHour;
  final int? workStartMinute;

  const CalendarDay({
    required this.date,
    required this.rokuyo,
    this.luckyDays = const [],
    this.events = const [],
    this.anniversaries = const [],
    this.holiday,
    this.workType,
    this.workStartHour,
    this.workStartMinute,
  });

  bool get isHoliday => holiday != null;

  bool get hasFujoujubi => luckyDays.contains(LuckyDayType.fujoujubi);

  bool get hasAuspiciousDay =>
      luckyDays.any((day) => day != LuckyDayType.fujoujubi);

  bool get hasTenshanichi => luckyDays.contains(LuckyDayType.tenshanichi);

  bool get hasEvents => events.isNotEmpty;

  bool get hasAnniversaries => anniversaries.isNotEmpty;

  bool get hasWorkType => workType != null;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
