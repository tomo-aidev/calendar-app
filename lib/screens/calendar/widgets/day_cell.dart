import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../models/calendar_day.dart';
import '../../../models/rokuyo.dart';
import '../../../models/schedule_event.dart';
import 'lucky_day_tag.dart';

class DayCell extends StatelessWidget {
  final CalendarDay day;
  final VoidCallback? onTap;
  final void Function(ScheduleEvent)? onEventTap;

  const DayCell({
    super.key,
    required this.day,
    this.onTap,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = day.date.weekday; // 1=Mon ... 7=Sun
    final isSunday = weekday == 7;
    final isSaturday = weekday == 6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: day.isToday ? AppColors.today.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: day.isToday ? AppColors.today : Colors.grey[300]!,
            width: day.isToday ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date number + Rokuyo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${day.date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSunday
                        ? AppColors.sunday
                        : isSaturday
                            ? AppColors.saturday
                            : Colors.black87,
                  ),
                ),
                if (day.rokuyo != Rokuyo.unknown)
                  Text(
                    day.rokuyo.shortName,
                    style: TextStyle(
                      fontSize: 7,
                      color: day.rokuyo.isAuspicious
                          ? AppColors.taian
                          : day.rokuyo.isInauspicious
                              ? AppColors.butsumetsu
                              : Colors.grey[600],
                    ),
                  ),
              ],
            ),
            // Lucky day tags
            if (day.luckyDays.isNotEmpty) ...[
              const SizedBox(height: 1),
              Wrap(
                spacing: 1,
                runSpacing: 1,
                children: day.luckyDays
                    .map((type) => LuckyDayTag(
                          type: type,
                          compact: true,
                        ))
                    .toList(),
              ),
            ],
            // Anniversary + Event labels
            if (day.hasAnniversaries || day.hasEvents) ...[
              const SizedBox(height: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Anniversary labels (above events)
                    ...day.anniversaries.take(1).map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '🎂${a.personName}',
                            style: TextStyle(
                              fontSize: 7,
                              color: AppColors.red.withValues(alpha: 0.8),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                    if (day.anniversaries.length > 1)
                      Text(
                        '+${day.anniversaries.length - 1}記念日',
                        style: TextStyle(
                          fontSize: 6,
                          color: AppColors.red.withValues(alpha: 0.6),
                        ),
                      ),
                    // Event labels
                    ...day.events.take(day.hasAnniversaries ? 1 : 2).map(
                          (event) => GestureDetector(
                            onTap: () {
                              if (onEventTap != null) {
                                onEventTap!(event);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 7,
                                  color: AppColors.warmBrown,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                    if (day.events.length > (day.hasAnniversaries ? 1 : 2))
                      Text(
                        '+${day.events.length - (day.hasAnniversaries ? 1 : 2)}',
                        style: TextStyle(
                          fontSize: 7,
                          color: AppColors.gold.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
