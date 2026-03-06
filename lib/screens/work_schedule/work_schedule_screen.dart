import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../models/work_entry.dart';
import '../../providers/work_entry_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/responsive_wrapper.dart';

class WorkScheduleScreen extends ConsumerStatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  ConsumerState<WorkScheduleScreen> createState() =>
      _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends ConsumerState<WorkScheduleScreen> {
  static const _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];
  static const _reminderOptions = [0, 30, 60, 90, 120];

  String _reminderLabel(int minutes) {
    if (minutes == 0) return 'なし';
    return '$minutes分前';
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(currentWorkScheduleConfigsProvider);

    final shiftConfig =
        configs[WorkEntryType.shift] ?? WorkScheduleConfig(startHour: 9, startMinute: 0);
    final wfhConfig =
        configs[WorkEntryType.workFromHome] ?? WorkScheduleConfig(startHour: 9, startMinute: 0);
    final holidayConfig =
        configs[WorkEntryType.holiday] ?? WorkScheduleConfig();

    // Collect all used weekdays to support exclusive selection
    final allUsedWeekdays = <WorkEntryType, Set<int>>{
      WorkEntryType.shift: shiftConfig.repeatWeekdays,
      WorkEntryType.workFromHome: wfhConfig.repeatWeekdays,
      WorkEntryType.holiday: holidayConfig.repeatWeekdays,
    };

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              border: Border(
                bottom: BorderSide(color: AppColors.red, width: 2),
              ),
            ),
            child: const Center(
              child: Text(
                'シフト・在宅管理',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ResponsiveWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '曜日ごとの勤務パターンを設定します。\n個別設定は日付で設定した内容が優先されます。',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Shift section
                    _buildWorkTypeSection(
                      type: WorkEntryType.shift,
                      config: shiftConfig,
                      allUsedWeekdays: allUsedWeekdays,
                      hasTime: true,
                      hasReminder: true,
                    ),

                    const Divider(height: 1),

                    // WFH section
                    _buildWorkTypeSection(
                      type: WorkEntryType.workFromHome,
                      config: wfhConfig,
                      allUsedWeekdays: allUsedWeekdays,
                      hasTime: true,
                      hasReminder: true,
                    ),

                    const Divider(height: 1),

                    // Holiday section
                    _buildWorkTypeSection(
                      type: WorkEntryType.holiday,
                      config: holidayConfig,
                      allUsedWeekdays: allUsedWeekdays,
                      hasTime: false,
                      hasReminder: false,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTypeSection({
    required WorkEntryType type,
    required WorkScheduleConfig config,
    required Map<WorkEntryType, Set<int>> allUsedWeekdays,
    required bool hasTime,
    required bool hasReminder,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: config.repeatWeekdays.isNotEmpty,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(type.emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        title: Text(
          '${type.displayName}登録',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: config.repeatWeekdays.isNotEmpty
            ? Text(
                _buildSummary(config, hasTime),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Start time (shift / WFH only)
                if (hasTime) ...[
                  _buildTimeRow(type, config),
                  const SizedBox(height: 16),
                ],

                // Weekday repeat
                _buildWeekdayRow(type, config, allUsedWeekdays),
                const SizedBox(height: 16),

                // Reminder (shift / WFH only)
                if (hasReminder) _buildReminderRow(type, config),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummary(WorkScheduleConfig config, bool hasTime) {
    final parts = <String>[];
    if (hasTime && config.startHour != null && config.startMinute != null) {
      parts.add(
        '${config.startHour!.toString().padLeft(2, '0')}:${config.startMinute!.toString().padLeft(2, '0')}〜',
      );
    }
    if (config.repeatWeekdays.isNotEmpty) {
      final days = config.repeatWeekdays.toList()..sort();
      parts.add(days.map((d) => _weekdayLabels[d - 1]).join('・'));
    }
    if (config.reminderMinutes > 0) {
      parts.add('${config.reminderMinutes}分前通知');
    }
    return parts.join(' / ');
  }

  Widget _buildTimeRow(WorkEntryType type, WorkScheduleConfig config) {
    final hour = config.startHour ?? 9;
    final minute = config.startMinute ?? 0;
    return Row(
      children: [
        Icon(Icons.access_time, size: 20, color: type.color),
        const SizedBox(width: 8),
        const Text('開始時間', style: TextStyle(fontSize: 14)),
        const Spacer(),
        GestureDetector(
          onTap: () => _pickStartTime(type, config),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: type.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}〜',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: type.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(
    WorkEntryType type,
    WorkScheduleConfig config,
    Map<WorkEntryType, Set<int>> allUsedWeekdays,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.repeat, size: 20, color: type.color),
            const SizedBox(width: 8),
            const Text('繰り返し', style: TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(7, (index) {
            final weekday = index + 1; // 1=Mon, 7=Sun
            final isSelected = config.repeatWeekdays.contains(weekday);

            // Check if used by another type
            WorkEntryType? usedByOther;
            for (final entry in allUsedWeekdays.entries) {
              if (entry.key != type && entry.value.contains(weekday)) {
                usedByOther = entry.key;
                break;
              }
            }

            return FilterChip(
              label: Text(
                _weekdayLabels[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : usedByOther != null
                          ? usedByOther.color.withValues(alpha: 0.5)
                          : Colors.black87,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _toggleWeekday(type, config, weekday, selected, allUsedWeekdays);
              },
              selectedColor: type.color,
              checkmarkColor: Colors.white,
              backgroundColor: usedByOther != null
                  ? usedByOther.color.withValues(alpha: 0.08)
                  : Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReminderRow(WorkEntryType type, WorkScheduleConfig config) {
    return Row(
      children: [
        Icon(Icons.notifications_none, size: 20, color: type.color),
        const SizedBox(width: 8),
        const Text('リマインダー通知', style: TextStyle(fontSize: 14)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: config.reminderMinutes,
              isDense: true,
              items: _reminderOptions.map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text(
                    _reminderLabel(minutes),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateReminder(type, config, value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickStartTime(
      WorkEntryType type, WorkScheduleConfig config) async {
    final hour = config.startHour ?? 9;
    final minute = config.startMinute ?? 0;
    int selectedHour = hour;
    int selectedMinute = minute;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('キャンセル'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('完了',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final newConfig = config.copyWith(
                        startHour: selectedHour,
                        startMinute: selectedMinute,
                      );
                      ref
                          .read(workScheduleConfigsProvider.notifier)
                          .saveConfig(type, newConfig);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2026, 1, 1, hour, minute),
                onDateTimeChanged: (DateTime dateTime) {
                  selectedHour = dateTime.hour;
                  selectedMinute = dateTime.minute;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWeekday(
    WorkEntryType type,
    WorkScheduleConfig config,
    int weekday,
    bool selected,
    Map<WorkEntryType, Set<int>> allUsedWeekdays,
  ) {
    final newWeekdays = Set<int>.from(config.repeatWeekdays);

    if (selected) {
      newWeekdays.add(weekday);

      // Remove from other types (exclusive)
      for (final otherType in WorkEntryType.values) {
        if (otherType != type) {
          final otherConfig =
              ref.read(currentWorkScheduleConfigsProvider)[otherType];
          if (otherConfig != null &&
              otherConfig.repeatWeekdays.contains(weekday)) {
            final otherWeekdays = Set<int>.from(otherConfig.repeatWeekdays)
              ..remove(weekday);
            ref.read(workScheduleConfigsProvider.notifier).saveConfig(
                  otherType,
                  otherConfig.copyWith(repeatWeekdays: otherWeekdays),
                );
          }
        }
      }
    } else {
      newWeekdays.remove(weekday);
    }

    final newConfig = config.copyWith(repeatWeekdays: newWeekdays);
    ref.read(workScheduleConfigsProvider.notifier).saveConfig(type, newConfig);

    // Request notification permission if reminder is set
    if (newConfig.reminderMinutes > 0 && !kIsWeb) {
      NotificationService.instance.requestPermissions();
    }
  }

  void _updateReminder(
      WorkEntryType type, WorkScheduleConfig config, int minutes) {
    final newConfig = config.copyWith(reminderMinutes: minutes);
    ref.read(workScheduleConfigsProvider.notifier).saveConfig(type, newConfig);

    // Request notification permission
    if (minutes > 0 && !kIsWeb) {
      NotificationService.instance.requestPermissions();
    }
  }
}
