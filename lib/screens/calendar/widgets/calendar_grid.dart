import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../models/schedule_event.dart';
import '../../../providers/calendar_provider.dart';
import '../../schedule/schedule_form_screen.dart';
import '../dialogs/day_detail_modal.dart';
import 'day_cell.dart';

class CalendarGrid extends ConsumerWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final days = ref.watch(monthCalendarProvider(currentMonth));

    // Calculate first day offset (0=Sunday start)
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sun, 1=Mon...

    // Calculate number of rows needed for this month
    final totalCells = firstWeekday + days.length;
    final rowCount = (totalCells / 7).ceil();

    const double weekdayHeaderHeight = 25.0;
    const double gridSpacing = 2.0;
    const double horizontalPadding = 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Calculate dynamic aspect ratio to fill the entire available space
        final gridHeight = availableHeight - weekdayHeaderHeight;
        final cellHeight =
            (gridHeight - (gridSpacing * (rowCount - 1))) / rowCount;
        final cellWidth =
            (availableWidth - horizontalPadding * 2 - gridSpacing * 6) / 7;
        final aspectRatio =
            cellHeight > 0 ? cellWidth / cellHeight : 0.65;

        return Column(
          children: [
            // Weekday headers
            SizedBox(
              height: weekdayHeaderHeight,
              child: Container(
                color: AppColors.offWhite,
                child: Row(
                  children: [
                    '\u65e5', '\u6708', '\u706b', '\u6c34', '\u6728', '\u91d1', '\u571f'
                  ].asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: index == 0
                                ? AppColors.sunday
                                : index == 6
                                    ? AppColors.saturday
                                    : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Calendar grid - fills remaining space
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) {
                    return const SizedBox.shrink();
                  }
                  final dayIndex = index - firstWeekday;
                  if (dayIndex >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final day = days[dayIndex];
                  return DayCell(
                    day: day,
                    onTap: () => showDayDetailModal(context, ref, day),
                    onEventTap: (ScheduleEvent event) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleFormScreen(
                            initialDate: day.date,
                            existingEvent: event,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
