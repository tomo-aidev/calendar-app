import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/user_profile.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'widgets/profile_form.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyNotificationEnabled = false;
  int _notificationHour = AppConstants.defaultNotificationHour;
  int _notificationMinute = AppConstants.defaultNotificationMinute;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    final storage = StorageService.instance;
    setState(() {
      _dailyNotificationEnabled =
          storage.getSetting<bool>('dailyNotificationEnabled') ?? false;
      _notificationHour =
          storage.getSetting<int>('notificationHour') ?? AppConstants.defaultNotificationHour;
      _notificationMinute =
          storage.getSetting<int>('notificationMinute') ?? AppConstants.defaultNotificationMinute;
    });
  }

  Future<void> _toggleDailyNotification(bool value) async {
    setState(() => _dailyNotificationEnabled = value);
    await StorageService.instance.saveSetting('dailyNotificationEnabled', value);

    if (value) {
      if (!kIsWeb) {
        await NotificationService.instance.requestPermissions();
        await NotificationService.instance.scheduleDailyMessage(
          hour: _notificationHour,
          minute: _notificationMinute,
        );
      }
    } else {
      await NotificationService.instance.cancelDailyMessage();
    }
  }

  Future<void> _pickNotificationTime() async {
    int selectedHour = _notificationHour;
    int selectedMinute = _notificationMinute;

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
            // Header with Done button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    child: const Text('完了', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      setState(() {
                        _notificationHour = selectedHour;
                        _notificationMinute = selectedMinute;
                      });
                      await StorageService.instance.saveSetting('notificationHour', selectedHour);
                      await StorageService.instance.saveSetting('notificationMinute', selectedMinute);

                      if (_dailyNotificationEnabled) {
                        await NotificationService.instance.scheduleDailyMessage(
                          hour: selectedHour,
                          minute: selectedMinute,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Time picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2026, 1, 1, _notificationHour, _notificationMinute),
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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final isGridView = ref.watch(isGridViewProvider);

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
            // Notification settings
            const _SectionHeader(title: '通知設定'),
            SwitchListTile(
              secondary: const Icon(Icons.notifications, color: AppColors.gold),
              title: const Text('日替わりメッセージ通知'),
              subtitle: const Text('毎朝、開運メッセージをお届け'),
              value: _dailyNotificationEnabled,
              activeTrackColor: AppColors.gold,
              onChanged: _toggleDailyNotification,
            ),
            if (_dailyNotificationEnabled)
              ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.gold),
                title: const Text('通知時刻'),
                trailing: Text(
                  '${_notificationHour.toString().padLeft(2, '0')}:${_notificationMinute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: _pickNotificationTime,
              ),
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
                      '六曜・吉日がわかる開運カレンダーアプリです。',
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
