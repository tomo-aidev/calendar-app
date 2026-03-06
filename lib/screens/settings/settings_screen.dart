import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/notification_day_type.dart';
import '../../models/user_profile.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_scheduler.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/responsive_wrapper.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'widgets/profile_form.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Lucky day notification settings
  bool _luckyDayEnabled = false;
  int _luckyDayHour = 8;
  int _luckyDayMinute = 0;
  final Map<NotificationDayType, bool> _luckyDayToggles = {};

  @override
  void initState() {
    super.initState();
    _loadFontSizeSettings();
    _loadNotificationSettings();
  }

  void _loadFontSizeSettings() {
    final storage = StorageService.instance;
    final dateIdx = storage.getSetting<int>('dateFontSizeIndex') ?? 1;
    final schedIdx = storage.getSetting<int>('scheduleFontSizeIndex') ?? 0;
    ref.read(dateFontSizeIndexProvider.notifier).state = dateIdx;
    ref.read(scheduleFontSizeIndexProvider.notifier).state = schedIdx;
  }

  void _loadNotificationSettings() {
    final storage = StorageService.instance;
    setState(() {
      _luckyDayEnabled =
          storage.getSetting<bool>('luckyDayNotificationEnabled') ?? false;
      _luckyDayHour =
          storage.getSetting<int>('luckyDayNotificationHour') ?? 8;
      _luckyDayMinute =
          storage.getSetting<int>('luckyDayNotificationMinute') ?? 0;

      for (final type in NotificationDayType.values) {
        _luckyDayToggles[type] =
            storage.getSetting<bool>(type.settingsKey) ?? true;
      }
    });
  }

  Future<void> _toggleLuckyDay(bool value) async {
    setState(() => _luckyDayEnabled = value);
    await StorageService.instance
        .saveSetting('luckyDayNotificationEnabled', value);
    if (value && !kIsWeb) {
      await NotificationService.instance.requestPermissions();
    }
    await NotificationScheduler.instance.rescheduleAllNotifications();
  }

  Future<void> _toggleLuckyDayType(
      NotificationDayType type, bool value) async {
    setState(() => _luckyDayToggles[type] = value);
    await StorageService.instance.saveSetting(type.settingsKey, value);
    await NotificationScheduler.instance.rescheduleAllNotifications();
  }

  Future<void> _pickTime({
    required int currentHour,
    required int currentMinute,
    required String hourKey,
    required String minuteKey,
    required void Function(int hour, int minute) onChanged,
  }) async {
    int selectedHour = currentHour;
    int selectedMinute = currentMinute;

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
                    onPressed: () async {
                      onChanged(selectedHour, selectedMinute);
                      await StorageService.instance
                          .saveSetting(hourKey, selectedHour);
                      await StorageService.instance
                          .saveSetting(minuteKey, selectedMinute);
                      await NotificationScheduler.instance
                          .rescheduleAllNotifications();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime:
                    DateTime(2026, 1, 1, currentHour, currentMinute),
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

  Widget _buildFontSizeSelector({
    required String label,
    required IconData icon,
    required int currentIndex,
    required ValueChanged<int> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: Text(label),
      trailing: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('S')),
          ButtonSegment(value: 1, label: Text('M')),
          ButtonSegment(value: 2, label: Text('L')),
        ],
        selected: {currentIndex},
        onSelectionChanged: (value) => onChanged(value.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.gold;
            }
            return null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return null;
          }),
        ),
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final isGridView = ref.watch(isGridViewProvider);
    final dateFontIdx = ref.watch(dateFontSizeIndexProvider);
    final schedFontIdx = ref.watch(scheduleFontSizeIndexProvider);

    return SafeArea(
      child: SingleChildScrollView(
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
                  '設定',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Settings content (responsive for iPad)
            ResponsiveWrapper(
              child: Column(
                children: [
            // Profile section
            const _SectionHeader(title: 'プロフィール'),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.gold),
              title: Text(profile.name ?? '未設定'),
              subtitle: Text(
                [
                  profile.gender.displayName,
                  if (profile.birthday != null)
                    '${profile.birthday!.year}/${profile.birthday!.month}/${profile.birthday!.day}',
                  if (profile.bloodType != null)
                    profile.bloodType!.displayName,
                  if (profile.zodiacSign != null)
                    '${profile.zodiacSign!.emoji} ${profile.zodiacSign!.displayName}',
                ].join(' ・ '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileFormScreen(profile: profile),
                  ),
                );
              },
            ),
            const Divider(),

            // Notification settings (lucky day only — work reminders are in schedule screen)
            const _SectionHeader(title: '通知設定'),

            // Lucky day notification
            SwitchListTile(
              secondary: const Icon(Icons.star, color: AppColors.gold),
              title: const Text('吉日通知'),
              subtitle: const Text('吉日の朝にお知らせ'),
              value: _luckyDayEnabled,
              activeTrackColor: AppColors.gold,
              onChanged: _toggleLuckyDay,
            ),
            if (_luckyDayEnabled) ...[
              ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.gold),
                title: const Text('通知時刻'),
                trailing: Text(
                  _formatTime(_luckyDayHour, _luckyDayMinute),
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () => _pickTime(
                  currentHour: _luckyDayHour,
                  currentMinute: _luckyDayMinute,
                  hourKey: 'luckyDayNotificationHour',
                  minuteKey: 'luckyDayNotificationMinute',
                  onChanged: (h, m) => setState(() {
                    _luckyDayHour = h;
                    _luckyDayMinute = m;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  '通知する吉日',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              ...NotificationDayType.values.map((type) => SwitchListTile(
                    title: Text(type.displayName),
                    value: _luckyDayToggles[type] ?? true,
                    activeTrackColor: AppColors.gold,
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 32),
                    onChanged: (value) =>
                        _toggleLuckyDayType(type, value),
                  )),
            ],
            const Divider(),

            // Display settings
            const _SectionHeader(title: '表示設定'),
            ListTile(
              leading: Icon(
                isGridView ? Icons.grid_view : Icons.view_list,
                color: AppColors.gold,
              ),
              title: const Text('デフォルト表示'),
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.grid_view, size: 18),
                    label: Text('グリッド'),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.view_list, size: 18),
                    label: Text('リスト'),
                  ),
                ],
                selected: {isGridView},
                onSelectionChanged: (value) {
                  ref.read(isGridViewProvider.notifier).state = value.first;
                  StorageService.instance.saveSetting('isGridView', value.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.gold;
                    }
                    return null;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return null;
                  }),
                ),
              ),
            ),
            _buildFontSizeSelector(
              label: '日付のフォントサイズ',
              icon: Icons.format_size,
              currentIndex: dateFontIdx,
              onChanged: (idx) {
                ref.read(dateFontSizeIndexProvider.notifier).state = idx;
                StorageService.instance.saveSetting('dateFontSizeIndex', idx);
              },
            ),
            _buildFontSizeSelector(
              label: '予定のフォントサイズ',
              icon: Icons.text_fields,
              currentIndex: schedFontIdx,
              onChanged: (idx) {
                ref.read(scheduleFontSizeIndexProvider.notifier).state = idx;
                StorageService.instance.saveSetting('scheduleFontSizeIndex', idx);
              },
            ),
            const Divider(),
            // App info
            const _SectionHeader(title: '情報'),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.gold),
              title: const Text('アプリについて'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  children: [
                    const Text(
                      '六曜・吉日・祝日がわかるカレンダーアプリです。',
                    ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.gold),
              title: const Text('利用規約'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: AppColors.gold),
              title: const Text('プライバシーポリシー'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'バージョン ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
