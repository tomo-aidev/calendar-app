import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../app.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  Gender _gender = Gender.female;
  DateTime? _birthday;
  BloodType? _bloodType;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canStart =>
      _birthday != null && _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // App icon/title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '開運日がわかるカレンダー',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '今日から運勢を占います！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Name
                _buildLabel('名前（ニックネーム）'),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onEditingComplete: () =>
                      FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'お名前を入力',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Gender
                _buildLabel('性別'),
                _buildGenderSelector(),
                const SizedBox(height: 20),
                // Birthday
                _buildLabel('生年月日'),
                InkWell(
                  onTap: _pickBirthday,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _birthday != null
                          ? '${_birthday!.year}年${_birthday!.month}月${_birthday!.day}日'
                          : 'タップして選択',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _birthday != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Blood type
                _buildLabel('血液型'),
                _buildBloodTypeSelector(),
                const SizedBox(height: 40),
                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canStart ? _start : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('はじめる'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    const genderColors = {
      Gender.female: (AppColors.femaleBg, AppColors.femaleSelected),
      Gender.male: (AppColors.maleBg, AppColors.maleSelected),
      Gender.other: (AppColors.otherBg, AppColors.otherSelected),
    };
    return Column(
      children: Gender.values.map((g) {
        final isSelected = _gender == g;
        final colors = genderColors[g]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.$2 : colors.$1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? colors.$2 : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isSelected ? '◉' : '○',
                    style: TextStyle(
                      fontSize: 20,
                      color: isSelected ? Colors.white : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    g.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBloodTypeSelector() {
    const bloodColors = {
      BloodType.a: (AppColors.bloodABg, AppColors.bloodASelected),
      BloodType.b: (AppColors.bloodBBg, AppColors.bloodBSelected),
      BloodType.o: (AppColors.bloodOBg, AppColors.bloodOSelected),
      BloodType.ab: (AppColors.bloodABBg, AppColors.bloodABSelected),
    };
    return Row(
      children: BloodType.values.map((b) {
        final isSelected = _bloodType == b;
        final colors = bloodColors[b]!;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: b != BloodType.values.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _bloodType = b),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colors.$2 : colors.$1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.$2 : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isSelected ? '◉' : '○',
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickBirthday() async {
    DateTime tempDate = _birthday ?? DateTime(1990, 1, 1);
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'キャンセル',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _birthday = tempDate);
                        Navigator.pop(context);
                      },
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
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _birthday ?? DateTime(1990, 1, 1),
                  minimumDate: DateTime(1920),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _start() async {
    final profile = UserProfile(
      name: _nameController.text.trim(),
      gender: _gender,
      birthday: _birthday,
      bloodType: _bloodType,
    );
    await ref.read(profileProvider.notifier).saveProfile(profile);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }
}
