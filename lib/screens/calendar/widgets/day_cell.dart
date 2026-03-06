import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../models/calendar_day.dart';
import '../../../models/rokuyo.dart';
import '../../../models/schedule_event.dart';
import '../../../models/work_entry.dart';
import '../../../providers/calendar_provider.dart';
import 'lucky_day_tag.dart';

class DayCell extends ConsumerWidget {
  final CalendarDay day;
  final VoidCallback? onTap;
  final void Function(ScheduleEvent)? onEventTap;

  // フォントサイズ定義: [S, M, L]
  static const _dateSizes = [13.0, 16.0, 19.0];
  static const _rokuyoSizes = [7.0, 9.0, 11.0];
  static const _scheduleSizes = [7.0, 9.0, 11.0];
  // 祝日ラベルはdateIdxに連動 (Lで大きく)
  static const _holidaySizes = [6.0, 7.0, 9.0];
  // 勤務ラベル (セル下部)
  static const _workLabelSizes = [6.0, 7.0, 8.0];

  const DayCell({
    super.key,
    required this.day,
    this.onTap,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateIdx = ref.watch(dateFontSizeIndexProvider);
    final schedIdx = ref.watch(scheduleFontSizeIndexProvider);

    final dateFontSize = _dateSizes[dateIdx];
    final rokuyoFontSize = _rokuyoSizes[dateIdx];
    final scheduleFontSize = _scheduleSizes[schedIdx];
    final holidayFontSize = _holidaySizes[dateIdx]; // dateIdxに連動
    final workLabelSize = _workLabelSizes[dateIdx];

    final weekday = day.date.weekday; // 1=Mon ... 7=Sun
    final isSunday = weekday == 7;
    final isSaturday = weekday == 6;
    final isRedDay = isSunday || day.isHoliday;

    // Work type background color
    Color bgColor;
    if (day.isToday) {
      bgColor = AppColors.today.withValues(alpha: 0.1);
    } else if (day.hasWorkType) {
      bgColor = day.workType!.color.withValues(alpha: 0.06);
    } else {
      bgColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: day.isToday ? AppColors.today : Colors.grey[300]!,
            width: day.isToday ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(3),
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
                    fontSize: dateFontSize,
                    fontWeight: FontWeight.bold,
                    color: isRedDay
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
                      fontSize: rokuyoFontSize,
                      fontWeight: day.rokuyo.isAuspicious
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: day.rokuyo.isAuspicious
                          ? AppColors.taian
                          : day.rokuyo.isInauspicious
                              ? AppColors.butsumetsu
                              : Colors.grey[600],
                    ),
                  ),
              ],
            ),
            // Holiday name
            if (day.isHoliday)
              Text(
                day.holiday!,
                style: TextStyle(
                  fontSize: holidayFontSize,
                  color: AppColors.sunday,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                              fontSize: scheduleFontSize,
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
                          fontSize: holidayFontSize,
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
                                style: TextStyle(
                                  fontSize: scheduleFontSize,
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
                          fontSize: scheduleFontSize,
                          color: AppColors.gold.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ] else if (!day.hasWorkType) ...[
              // Spacer when no events and no work type
              const Spacer(),
            ] else ...[
              const Spacer(),
            ],
            // Work type label at BOTTOM (fixed position)
            if (day.hasWorkType) _buildWorkLabel(day, workLabelSize),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkLabel(CalendarDay day, double fontSize) {
    final type = day.workType!;
    String label;
    if (type == WorkEntryType.holiday) {
      label = '休日';
    } else {
      final h = day.workStartHour;
      final m = day.workStartMinute;
      if (h != null && m != null) {
        label =
            '${type.displayName} ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}〜';
      } else {
        label = type.displayName;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
