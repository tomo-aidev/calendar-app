import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_day.dart';
import '../services/calendar/holiday_calculator.dart';
import '../services/calendar/lucky_day_calculator.dart';
import '../services/calendar/rokuyo_calculator.dart';
import 'anniversary_provider.dart';
import 'schedule_provider.dart';
import 'work_entry_provider.dart';

/// Current displayed month
final currentMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Calendar view mode (grid/list)
final isGridViewProvider = StateProvider<bool>((ref) => true);

/// Font size index: 0=S, 1=M, 2=L
final dateFontSizeIndexProvider = StateProvider<int>((ref) => 1); // default: M
final scheduleFontSizeIndexProvider = StateProvider<int>((ref) => 0); // default: S

/// Provider for RokuyoCalculator
final rokuyoCalculatorProvider = Provider<RokuyoCalculator>((ref) {
  return RokuyoCalculator();
});

/// Provider for LuckyDayCalculator
final luckyDayCalculatorProvider = Provider<LuckyDayCalculator>((ref) {
  return LuckyDayCalculator();
});

/// Provides CalendarDay data for a specific month
final monthCalendarProvider =
    Provider.family<List<CalendarDay>, DateTime>((ref, month) {
  final rokuyoCalc = ref.watch(rokuyoCalculatorProvider);
  final luckyDayCalc = ref.watch(luckyDayCalculatorProvider);
  final scheduleNotifier = ref.watch(scheduleProvider.notifier);
  final anniversaryNotifier = ref.watch(anniversaryProvider.notifier);

  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final days = <CalendarDay>[];

  // Watch providers to rebuild when data changes
  ref.watch(scheduleProvider);
  ref.watch(anniversaryProvider);
  ref.watch(workEntryProvider);
  ref.watch(workScheduleConfigsProvider);

  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(month.year, month.month, day);
    final events = scheduleNotifier.getEventsForDate(date)
      ..sort((a, b) {
        // All-day events first, then by start time
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        return 0;
      });
    final anniversaries = anniversaryNotifier.getAnniversariesForDate(date);
    final workType = ref.read(resolvedWorkTypeProvider(date));
    final startTime = ref.read(resolvedWorkStartTimeProvider(date));
    days.add(CalendarDay(
      date: date,
      rokuyo: rokuyoCalc.calculate(date),
      luckyDays: luckyDayCalc.calculate(date),
      events: events,
      anniversaries: anniversaries,
      holiday: HolidayCalculator.getHoliday(date),
      workType: workType,
      workStartHour: startTime?.hour,
      workStartMinute: startTime?.minute,
    ));
  }

  return days;
});

/// Selected date provider
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
