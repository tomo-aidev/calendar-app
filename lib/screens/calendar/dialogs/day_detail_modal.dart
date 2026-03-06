import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../models/calendar_day.dart';
import '../../../models/lucky_day.dart';
import '../../../models/rokuyo.dart';
import '../../../models/work_entry.dart';
import '../../../providers/work_entry_provider.dart';
import '../../../services/google_calendar_service.dart';
import '../../schedule/schedule_form_screen.dart';
import 'tag_info_modal.dart';
import '../widgets/lucky_day_tag.dart';

void showDayDetailModal(BuildContext context, WidgetRef ref, CalendarDay day) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) =>
        DayDetailContent(day: day, parentContext: context),
  );
}

class DayDetailContent extends ConsumerWidget {
  final CalendarDay day;
  final BuildContext parentContext;

  const DayDetailContent(
      {super.key, required this.day, required this.parentContext});

  static const _weekdays = [
    '', '\u6708\u66dc\u65e5', '\u706b\u66dc\u65e5', '\u6c34\u66dc\u65e5',
    '\u6728\u66dc\u65e5', '\u91d1\u66dc\u65e5', '\u571f\u66dc\u65e5',
    '\u65e5\u66dc\u65e5',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Date header
              Text(
                '${day.date.year}\u5e74${day.date.month}\u6708${day.date.day}\u65e5\uff08${_weekdays[day.date.weekday]}\uff09',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Holiday
              if (day.isHoliday) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sunday.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.sunday.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🎌', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        day.holiday!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sunday,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Rokuyo
              if (day.rokuyo != Rokuyo.unknown) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Text(
                        day.rokuyo.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: day.rokuyo.isAuspicious
                              ? AppColors.taian
                              : day.rokuyo.isInauspicious
                                  ? AppColors.butsumetsu
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          day.rokuyo.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Work entry section
              _buildWorkEntrySection(context, ref),
              // Lucky days
              if (day.luckyDays.isNotEmpty) ...[
                const Text(
                  '\u5409\u65e5\u30fb\u51f6\u65e5',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...day.luckyDays.map((type) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => showTagInfoModal(context, type),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: type.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: type.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              LuckyDayTag(type: type),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  type.description,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                // Google Calendar button for auspicious days
                if (day.luckyDays.any((d) => d.isAuspicious)) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _addToGoogleCalendar(),
                      icon: const Icon(Icons.event_available,
                          color: AppColors.gold),
                      label: const Text('Googleカレンダーに吉日を追加'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warmBrown,
                        side: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              // Events
              const Text(
                '\u4e88\u5b9a',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (day.events.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '\u4e88\u5b9a\u306f\u3042\u308a\u307e\u305b\u3093',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...day.events.map((event) => ListTile(
                      leading: const Icon(
                        Icons.event,
                        color: AppColors.gold,
                      ),
                      title: Text(event.title),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (context) => ScheduleFormScreen(
                              initialDate: day.date,
                              existingEvent: event,
                            ),
                          ),
                        );
                      },
                    )),
              const SizedBox(height: 16),
              // Add schedule button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    Navigator.push(
                      parentContext, // Use parent context for navigation
                      MaterialPageRoute(
                        builder: (context) =>
                            ScheduleFormScreen(initialDate: day.date),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('\u4e88\u5b9a\u3092\u8ffd\u52a0'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkEntrySection(BuildContext context, WidgetRef ref) {
    final resolvedType = ref.watch(resolvedWorkTypeProvider(day.date));
    final individualEntry =
        ref.watch(workEntryProvider.notifier).getEntryForDate(day.date);
    final isIndividual = individualEntry != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '勤務',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (resolvedType != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: resolvedType.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: resolvedType.color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Text(resolvedType.emoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  resolvedType.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: resolvedType.color,
                  ),
                ),
                if (isIndividual) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('個別設定',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.grey, size: 20),
                  tooltip: 'この日の勤務を削除',
                  onPressed: () {
                    if (isIndividual) {
                      ref
                          .read(workEntryProvider.notifier)
                          .deleteWorkEntryForDate(day.date);
                    } else {
                      // Schedule-derived: exclude this specific date
                      ref
                          .read(excludedWorkDatesProvider.notifier)
                          .excludeDate(day.date);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('勤務設定なし',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showWorkEntryActionSheet(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('シフト・在宅・休日の追加'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.workShift,
              side: BorderSide(color: AppColors.workShift.withValues(alpha: 0.5)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showWorkEntryActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.business, color: AppColors.workShift),
              title: const Text('シフト'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ref.read(excludedWorkDatesProvider.notifier).removeExclusion(day.date);
                ref.read(workEntryProvider.notifier).addWorkEntry(
                      date: day.date,
                      type: WorkEntryType.shift,
                    );
                Navigator.pop(context); // close day detail
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: AppColors.workFromHome),
              title: const Text('在宅ワーク'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ref.read(excludedWorkDatesProvider.notifier).removeExclusion(day.date);
                ref.read(workEntryProvider.notifier).addWorkEntry(
                      date: day.date,
                      type: WorkEntryType.workFromHome,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.beach_access, color: AppColors.workHoliday),
              title: const Text('休日'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ref.read(excludedWorkDatesProvider.notifier).removeExclusion(day.date);
                ref.read(workEntryProvider.notifier).addWorkEntry(
                      date: day.date,
                      type: WorkEntryType.holiday,
                    );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addToGoogleCalendar() {
    final auspiciousDays =
        day.luckyDays.where((d) => d.isAuspicious).toList();
    final title = auspiciousDays.map((d) => d.displayName).join('・');
    final description = auspiciousDays
        .map((d) => '${d.displayName}: ${d.description}')
        .join('\n\n');

    GoogleCalendarService.addEvent(
      title: '【吉日】$title',
      date: day.date,
      description: description,
    );
  }
}
