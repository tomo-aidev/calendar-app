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
    return Scaffold(
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
    );
  }

  Widget _buildGenderSelector() {
    const genderColors = {
      Gender.female: (AppColors.femaleBg, AppColors.femaleSelected),
      Gender.male: (AppColors.maleBg, AppColors.maleSelected),
      Gender.other: (AppColors.otherBg, AppColors.otherSelected),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Row(
          children: Gender.values.map((g) {
            final isSelected = _gender == g;
            final colors = genderColors[g]!;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.$2 : colors.$1,
                    border: Border(
                      left: g != Gender.values.first
                          ? BorderSide(color: Colors.grey[300]!)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    g.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    const bloodColors = {
      BloodType.a: (AppColors.bloodABg, AppColors.bloodASelected),
      BloodType.b: (AppColors.bloodBBg, AppColors.bloodBSelected),
      BloodType.o: (AppColors.bloodOBg, AppColors.bloodOSelected),
      BloodType.ab: (AppColors.bloodABBg, AppColors.bloodABSelected),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Row(
          children: BloodType.values.map((b) {
            final isSelected = _bloodType == b;
            final colors = bloodColors[b]!;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _bloodType = b),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.$2 : colors.$1,
                    border: Border(
                      left: b != BloodType.values.first
                          ? BorderSide(color: Colors.grey[300]!)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    b.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );
    if (date != null) {
      setState(() => _birthday = date);
    }
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
