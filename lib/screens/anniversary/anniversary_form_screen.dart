import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../models/anniversary_event.dart';
import '../../providers/anniversary_provider.dart';

class AnniversaryFormScreen extends ConsumerStatefulWidget {
  final AnniversaryEvent? existingEvent;

  const AnniversaryFormScreen({
    super.key,
    this.existingEvent,
  });

  @override
  ConsumerState<AnniversaryFormScreen> createState() =>
      _AnniversaryFormScreenState();
}

class _AnniversaryFormScreenState
    extends ConsumerState<AnniversaryFormScreen> {
  late DateTime _date;
  late String _personName;
  late AnniversaryType _type;
  late String _customTypeName;
  late String _memo;
  late bool _showEveryYear;
  late bool _showOnCalendar;

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    _date = event?.date ?? DateTime.now();
    _personName = event?.personName ?? '';
    _type = event?.type ?? AnniversaryType.firstMet;
    _customTypeName = event?.customTypeName ?? '';
    _memo = event?.memo ?? '';
    _showEveryYear = event?.showEveryYear ?? true;
    _showOnCalendar = event?.showOnCalendar ?? true;
  }

  static const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

  String _formatDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    return '${dt.year}年${dt.month}月${dt.day}日($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          widget.existingEvent != null ? '記念日を編集' : '記念日を登録',
        ),
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
          // Date section
          _buildCard([
            _buildTile(
              icon: Icons.calendar_today,
              label: '日付',
              trailing: Text(
                _formatDate(_date),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _pickDate,
            ),
          ]),

          const SizedBox(height: 8),

          // Name section
          _buildCard([
            _buildTile(
              icon: Icons.person_outline,
              label: _personName.isEmpty ? '名前' : _personName,
              isPlaceholder: _personName.isEmpty,
              onTap: _editName,
              showChevron: true,
            ),
          ]),

          const SizedBox(height: 8),

          // Anniversary type section
          _buildCard([
            _buildTile(
              icon: Icons.celebration_outlined,
              label: '記念日',
              trailing: Text(
                _type == AnniversaryType.custom
                    ? (_customTypeName.isEmpty ? 'その他' : _customTypeName)
                    : _type.displayName,
                style: TextStyle(
                  color: AppColors.warmBrown.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              onTap: _pickType,
              showChevron: true,
            ),
          ]),

          const SizedBox(height: 8),

          // Memo section
          _buildCard([
            _buildTile(
              icon: Icons.note_outlined,
              label: _memo.isEmpty ? 'メモ（任意）' : _memo,
              isPlaceholder: _memo.isEmpty,
              onTap: _editMemo,
              showChevron: true,
            ),
          ]),

          const SizedBox(height: 8),

          // Options section
          _buildCard([
            _buildCheckboxTile(
              icon: Icons.repeat,
              label: '毎年表示する',
              value: _showEveryYear,
              onChanged: (v) =>
                  setState(() => _showEveryYear = v ?? true),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Divider(
                height: 1,
                color: Colors.grey[200],
              ),
            ),
            _buildCheckboxTile(
              icon: Icons.calendar_month,
              label: 'カレンダーに表示',
              value: _showOnCalendar,
              onChanged: (v) =>
                  setState(() => _showOnCalendar = v ?? true),
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
                      'この記念日を削除',
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

  Widget _buildCheckboxTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.warmBrown,
                ),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  // --- Date Picker ---

  void _pickDate() {
    DateTime selected = _date;

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
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  const Text(
                    '日付',
                    style: TextStyle(
                      color: AppColors.warmBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _date = selected);
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
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _date,
                minimumDate: DateTime(1920),
                maximumDate: DateTime(2035, 12, 31),
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

  // --- Name Input ---

  Future<void> _editName() async {
    final controller = TextEditingController(text: _personName);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: AppColors.warmBrown.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const Text(
                  '名前',
                  style: TextStyle(
                    color: AppColors.warmBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text),
                  child: const Text(
                    '完了',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.warmBrown,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: '例：太郎、花子',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result != null) {
      setState(() => _personName = result);
    }
  }

  // --- Memo Input ---

  Future<void> _editMemo() async {
    final controller = TextEditingController(text: _memo);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: AppColors.warmBrown.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const Text(
                  'メモ',
                  style: TextStyle(
                    color: AppColors.warmBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text),
                  child: const Text(
                    '完了',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(
                color: AppColors.warmBrown,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'メモを入力',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result != null) {
      setState(() => _memo = result);
    }
  }

  // --- Anniversary Type Picker ---

  void _pickType() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AnniversaryTypePicker(
        currentType: _type,
        customTypeName: _customTypeName,
        onSelected: (type, customName) {
          setState(() {
            _type = type;
            if (customName != null) {
              _customTypeName = customName;
            }
          });
        },
      ),
    );
  }

  // --- Save / Delete ---

  Future<void> _save() async {
    if (_personName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('名前を入力してください'),
          backgroundColor: AppColors.gold,
        ),
      );
      return;
    }

    if (_type == AnniversaryType.custom && _customTypeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('記念日の名前を入力してください'),
          backgroundColor: AppColors.gold,
        ),
      );
      return;
    }

    if (widget.existingEvent != null) {
      await ref.read(anniversaryProvider.notifier).updateAnniversary(
            widget.existingEvent!.copyWith(
              date: _date,
              personName: _personName,
              type: _type,
              customTypeName:
                  _type == AnniversaryType.custom ? _customTypeName : null,
              memo: _memo.isNotEmpty ? _memo : null,
              showEveryYear: _showEveryYear,
              showOnCalendar: _showOnCalendar,
            ),
          );
    } else {
      await ref.read(anniversaryProvider.notifier).addAnniversary(
            date: _date,
            personName: _personName,
            type: _type,
            customTypeName:
                _type == AnniversaryType.custom ? _customTypeName : null,
            memo: _memo.isNotEmpty ? _memo : null,
            showEveryYear: _showEveryYear,
            showOnCalendar: _showOnCalendar,
          );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('確認',
            style: TextStyle(color: AppColors.warmBrown)),
        content: const Text('この記念日を削除しますか？'),
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
          .read(anniversaryProvider.notifier)
          .deleteAnniversary(widget.existingEvent!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

// --- Anniversary Type Picker (categorized) ---

class _AnniversaryTypePicker extends StatefulWidget {
  final AnniversaryType currentType;
  final String customTypeName;
  final void Function(AnniversaryType type, String? customName) onSelected;

  const _AnniversaryTypePicker({
    required this.currentType,
    required this.customTypeName,
    required this.onSelected,
  });

  @override
  State<_AnniversaryTypePicker> createState() =>
      _AnniversaryTypePickerState();
}

class _AnniversaryTypePickerState extends State<_AnniversaryTypePicker> {
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customController.text = widget.customTypeName;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
              child: const Center(
                child: Text(
                  '記念日の種類',
                  style: TextStyle(
                    color: AppColors.warmBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  for (final category in AnniversaryCategory.values) ...[
                    // Category header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Text(
                        '${category.emoji} ${category.displayName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    // Types in this category
                    ...AnniversaryType.values
                        .where((t) =>
                            t != AnniversaryType.custom &&
                            t.category == category)
                        .map((type) {
                      final isSelected = type == widget.currentType;
                      return InkWell(
                        onTap: () {
                          widget.onSelected(type, null);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    Colors.grey[200]!.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  type.displayName,
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
                  ],
                  // Custom (free input) at the bottom
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Text(
                      '✏️ その他（自由入力）',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customController,
                            style: const TextStyle(
                              color: AppColors.warmBrown,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: '記念日名を入力',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.gold,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_customController.text.isNotEmpty) {
                              widget.onSelected(
                                AnniversaryType.custom,
                                _customController.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('決定'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
