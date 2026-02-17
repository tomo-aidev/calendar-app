import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../models/user_profile.dart';
import '../../../providers/profile_provider.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const ProfileFormScreen({super.key, required this.profile});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  late TextEditingController _nameController;
  late Gender _gender;
  late DateTime? _birthday;
  late BloodType? _bloodType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name ?? '');
    _gender = widget.profile.gender;
    _birthday = widget.profile.birthday;
    _bloodType = widget.profile.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('プロフィール編集'),
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              const Text('名前（ニックネーム）',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                onEditingComplete: () =>
                    FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'お名前を入力',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Gender
              const Text('性別', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildGenderSelector(),
              const SizedBox(height: 24),
              // Birthday
              const Text('生年月日',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickBirthday,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _birthday != null
                        ? '${_birthday!.year}年${_birthday!.month}月${_birthday!.day}日'
                        : '選択してください',
                    style: TextStyle(
                      fontSize: 16,
                      color: _birthday != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Blood type
              const Text('血液型',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildBloodTypeSelector(),
            ],
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

  Future<void> _save() async {
    final profile = UserProfile(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      gender: _gender,
      birthday: _birthday,
      bloodType: _bloodType,
    );
    await ref.read(profileProvider.notifier).saveProfile(profile);
    if (mounted) Navigator.pop(context);
  }
}
