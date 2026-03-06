import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../models/calendar_day.dart';
import '../../../models/rokuyo.dart';
import '../../../models/work_entry.dart';
import '../../../providers/calendar_provider.dart';
import '../dialogs/day_detail_modal.dart';
import 'lucky_day_tag.dart';

class CalendarList extends ConsumerWidget {
  const CalendarList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final days = ref.watch(monthCalendarProvider(currentMonth));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return _DayListTile(
          day: day,
          onTap: () => showDayDetailModal(context, ref, day),
        );
      },
    );
  }
}

class _DayListTile extends ConsumerWidget {
  final CalendarDay day;
  final VoidCallback? onTap;

  // フォントサイズ定義: [S, M, L]
  static const _dateSizes = [17.0, 20.0, 23.0];
  static const _rokuyoSizes = [10.0, 12.0, 14.0];
  static const _eventCountSizes = [10.0, 12.0, 14.0];

  const _DayListTile({required this.day, this.onTap});

  static const _weekdays = [
    '', '\u6708', '\u706b', '\u6c34', '\u6728', '\u91d1', '\u571f', '\u65e5'
  ];

  String _workBadgeText(CalendarDay day) {
    final type = day.workType!;
    if (type == WorkEntryType.holiday) return '休日';
    final h = day.workStartHour;
    final m = day.workStartMinute;
    if (h != null && m != null) {
      return '${type.emoji} ${type.displayName} ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}〜';
    }
    return '${type.emoji} ${type.displayName}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateIdx = ref.watch(dateFontSizeIndexProvider);
    final schedIdx = ref.watch(scheduleFontSizeIndexProvider);

    final dateFontSize = _dateSizes[dateIdx];
    final rokuyoFontSize = _rokuyoSizes[dateIdx];
    final eventCountFontSize = _eventCountSizes[schedIdx];

    final isSunday = day.date.weekday == 7;
    final isSaturday = day.date.weekday == 6;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Date
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: day.isToday ? AppColors.gold : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.date.day}',
                      style: TextStyle(
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.bold,
                        color: day.isToday
                            ? Colors.white
                            : isSunday
                                ? AppColors.sunday
                                : isSaturday
                                    ? AppColors.saturday
                                    : Colors.black87,
                      ),
                    ),
                    Text(
                      _weekdays[day.date.weekday],
                      style: TextStyle(
                        fontSize: 10,
                        color: day.isToday ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rokuyo
                    if (day.rokuyo != Rokuyo.unknown)
                      Text(
                        day.rokuyo.displayName,
                        style: TextStyle(
                          fontSize: rokuyoFontSize,
                          color: day.rokuyo.isAuspicious
                              ? AppColors.taian
                              : Colors.grey[600],
                        ),
                      ),
                    // Lucky day tags
                    if (day.luckyDays.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: day.luckyDays
                            .map((type) => LuckyDayTag(type: type))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Work type + Event count badges
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (day.hasWorkType)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: day.workType!.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _workBadgeText(day),
                        style: TextStyle(
                          fontSize: eventCountFontSize,
                          color: day.workType!.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (day.hasEvents)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${day.events.length}\u4ef6',
                        style: TextStyle(
                          fontSize: eventCountFontSize,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
