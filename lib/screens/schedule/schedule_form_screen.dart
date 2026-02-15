import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../models/schedule_event.dart';
import '../../providers/schedule_provider.dart';
import 'title_input_screen.dart';
import 'location_input_screen.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final ScheduleEvent? existingEvent;

  const ScheduleFormScreen({
    super.key,
    required this.initialDate,
    this.existingEvent,
  });

  @override
  ConsumerState<ScheduleFormScreen> createState() =>
      _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  late String _title;
  late String _location;
  late bool _isAllDay;
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  late Duration _travelTime;
  late RepeatType _repeat;
  late Duration _notifyBefore;

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    _title = event?.title ?? '';
    _location = event?.location ?? '';
    _isAllDay = event?.isAllDay ?? false;

    final date = event?.date ?? widget.initialDate;
    _startDateTime = event?.startTime ??
        DateTime(date.year, date.month, date.day, 9, 0);
    _endDateTime = event?.endTime ??
        DateTime(date.year, date.month, date.day, 10, 0);

    _travelTime = event?.travelTime ?? Duration.zero;
    _repeat = event?.repeat ?? RepeatType.none;
    _notifyBefore = event?.notifyBefore ?? Duration.zero;
  }

  static const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

  String _formatDateTime(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    return '${dt.year}年${dt.month}月${dt.day}日($weekday) ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    return '${dt.year}年${dt.month}月${dt.day}日($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(widget.existingEvent != null ? '予定を編集' : '予定を追加'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Title & Location section
          _buildCard([
            _buildTile(
              icon: Icons.edit_note,
              label: _title.isEmpty ? 'タイトル' : _title,
              isPlaceholder: _title.isEmpty,
              onTap: _editTitle,
              showChevron: true,
            ),
            _buildTileDivider(),
            _buildTile(
              icon: Icons.location_on_outlined,
              label: _location.isEmpty ? '場所' : _location,
              isPlaceholder: _location.isEmpty,
              onTap: _editLocation,
              showChevron: true,
            ),
          ]),

          const SizedBox(height: 8),

          // Date/Time section
          _buildCard([
            _buildTile(
              icon: Icons.play_arrow_rounded,
              label: '開始',
              trailing: Text(
                _isAllDay
                    ? _formatDate(_startDateTime)
                    : _formatDateTime(_startDateTime),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _pickDateTime(true),
            ),
            _buildTileDivider(),
            _buildTile(
              icon: Icons.stop_rounded,
              label: '終了',
              trailing: Text(
                _isAllDay
                    ? _formatDate(_endDateTime)
                    : _formatDateTime(_endDateTime),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _pickDateTime(false),
            ),
            _buildTileDivider(),
            _buildAllDaySwitchTile(),
          ]),

          const SizedBox(height: 8),

          // Options section
          _buildCard([
            _buildTile(
              icon: Icons.directions_car_outlined,
              label: '移動時間',
              trailing: Text(
                TravelTime.displayName(_travelTime),
                style: TextStyle(
                  color: AppColors.warmBrown.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              onTap: _pickTravelTime,
              showChevron: true,
            ),
            _buildTileDivider(),
            _buildTile(
              icon: Icons.repeat,
              label: '繰り返し',
              trailing: Text(
                _repeat.displayName,
                style: TextStyle(
                  color: AppColors.warmBrown.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              onTap: _pickRepeat,
              showChevron: true,
            ),
            _buildTileDivider(),
            _buildTile(
              icon: Icons.notifications_none,
              label: '通知',
              trailing: Text(
                NotifyBefore.displayName(_notifyBefore),
                style: TextStyle(
                  color: AppColors.warmBrown.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              onTap: _pickNotification,
              showChevron: true,
            ),
          ]),

          // Delete button
          if (widget.existingEvent != null) ...[
            const SizedBox(height: 16),
            _buildCard([
              InkWell(
                onTap: _delete,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      'この予定を削除',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  // --- UI Builder Helpers ---

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTileDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        height: 1,
        color: Colors.grey[300]!.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    bool isPlaceholder = false,
    Widget? trailing,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder
                      ? Colors.grey[400]
                      : AppColors.warmBrown,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
            if (showChevron) ...[
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[300]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllDaySwitchTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_outlined, size: 20, color: AppColors.gold),
          const SizedBox(width: 12),
          Text(
            '時間指定',
            style: TextStyle(
              fontSize: 14,
              fontWeight: !_isAllDay ? FontWeight.bold : FontWeight.normal,
              color: !_isAllDay ? AppColors.gold : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: _isAllDay,
            onChanged: (v) => setState(() => _isAllDay = v),
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.gold,
            inactiveTrackColor: AppColors.gold.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Text(
            '終日',
            style: TextStyle(
              fontSize: 14,
              fontWeight: _isAllDay ? FontWeight.bold : FontWeight.normal,
              color: _isAllDay ? AppColors.gold : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // --- Date/Time Picker (Drum UI) ---

  void _pickDateTime(bool isStart) {
    final initial = isStart ? _startDateTime : _endDateTime;
    DateTime selected = initial;

    final mode = _isAllDay
        ? CupertinoDatePickerMode.date
        : CupertinoDatePickerMode.dateAndTime;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'キャンセル',
                      style: TextStyle(
                        color: AppColors.warmBrown.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    isStart ? '開始' : '終了',
                    style: const TextStyle(
                      color: AppColors.warmBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isStart) {
                          _startDateTime = selected;
                          if (_endDateTime.isBefore(_startDateTime) ||
                              _endDateTime
                                  .isAtSameMomentAs(_startDateTime)) {
                            _endDateTime =
                                _startDateTime.add(const Duration(hours: 1));
                          }
                        } else {
                          _endDateTime = selected;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '完了',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Drum picker
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                initialDateTime: initial,
                minimumDate: DateTime(2020),
                maximumDate: DateTime(2035, 12, 31),
                use24hFormat: true,
                onDateTimeChanged: (dt) {
                  selected = dt;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Option Pickers (Pop Design) ---

  void _pickTravelTime() {
    _showOptionPicker(
      title: '移動時間',
      options: TravelTime.options,
      currentValue: _travelTime,
      displayName: TravelTime.displayName,
      onSelected: (d) => setState(() => _travelTime = d),
    );
  }

  void _pickRepeat() {
    _showOptionPicker(
      title: '繰り返し',
      options: RepeatType.values,
      currentValue: _repeat,
      displayName: (r) => r.displayName,
      onSelected: (r) => setState(() => _repeat = r),
    );
  }

  void _pickNotification() {
    _showOptionPicker(
      title: '通知',
      options: NotifyBefore.options,
      currentValue: _notifyBefore,
      displayName: NotifyBefore.displayName,
      onSelected: (d) => setState(() => _notifyBefore = d),
    );
  }

  void _showOptionPicker<T>({
    required String title,
    required List<T> options,
    required T currentValue,
    required String Function(T) displayName,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.warmBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...options.map((opt) {
              final isSelected = opt == currentValue;
              return InkWell(
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName(opt),
                          style: TextStyle(
                            fontSize: 15,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.warmBrown,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.gold,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Navigation ---

  Future<void> _editTitle() async {
    final history = ref.read(scheduleProvider.notifier).getTitleHistory();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => TitleInputScreen(
          initialValue: _title,
          history: history,
        ),
      ),
    );
    if (result != null) {
      setState(() => _title = result);
    }
  }

  Future<void> _editLocation() async {
    final history = ref.read(scheduleProvider.notifier).getLocationHistory();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationInputScreen(
          initialValue: _location,
          history: history,
        ),
      ),
    );
    if (result != null) {
      setState(() => _location = result);
    }
  }

  // --- Save / Delete ---

  Future<void> _save() async {
    if (_title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('タイトルを入力してください'),
          backgroundColor: AppColors.gold,
        ),
      );
      return;
    }

    final date = DateTime(
      _startDateTime.year,
      _startDateTime.month,
      _startDateTime.day,
    );

    DateTime? startTime;
    DateTime? endTime;
    if (!_isAllDay) {
      startTime = _startDateTime;
      endTime = _endDateTime;
    }

    if (widget.existingEvent != null) {
      await ref.read(scheduleProvider.notifier).updateSchedule(
            widget.existingEvent!.copyWith(
              title: _title,
              location: _location.isNotEmpty ? _location : null,
              date: date,
              isAllDay: _isAllDay,
              startTime: startTime,
              endTime: endTime,
              travelTime: _travelTime,
              repeat: _repeat,
              notifyBefore: _notifyBefore,
            ),
          );
    } else {
      await ref.read(scheduleProvider.notifier).addSchedule(
            title: _title,
            location: _location.isNotEmpty ? _location : null,
            date: date,
            isAllDay: _isAllDay,
            startTime: startTime,
            endTime: endTime,
            travelTime: _travelTime,
            repeat: _repeat,
            notifyBefore: _notifyBefore,
          );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('確認', style: TextStyle(color: AppColors.warmBrown)),
        content: const Text('この予定を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '削除',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(scheduleProvider.notifier)
          .deleteSchedule(widget.existingEvent!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
