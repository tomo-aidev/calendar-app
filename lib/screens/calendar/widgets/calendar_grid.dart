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

    return Column(
      children: [
        // Weekday headers
        Container(
          color: AppColors.offWhite,
          child: Row(
            children: [
              '\u65e5', '\u6708', '\u706b', '\u6c34', '\u6728', '\u91d1', '\u571f'
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.65,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: firstWeekday + days.length,
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
  }
}
