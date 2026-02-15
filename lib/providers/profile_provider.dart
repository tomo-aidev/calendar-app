import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(const UserProfile());

  void loadProfile() {
    final storage = StorageService.instance;
    final data = storage.getProfile();

    state = UserProfile(
      name: data['name'] as String?,
      gender: _parseGender(data['gender']),
      birthday: data['birthday'] != null
          ? DateTime.tryParse(data['birthday'] as String)
          : null,
      bloodType: _parseBloodType(data['bloodType']),
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final storage = StorageService.instance;
    await storage.saveProfile({
      'name': profile.name,
      'gender': profile.gender.name,
      'birthday': profile.birthday?.toIso8601String(),
      'bloodType': profile.bloodType?.name,
    });
    state = profile;
  }

  Gender _parseGender(dynamic value) {
    if (value == null) return Gender.female;
    return Gender.values.firstWhere(
      (g) => g.name == value,
      orElse: () => Gender.female,
    );
  }

  BloodType? _parseBloodType(dynamic value) {
    if (value == null) return null;
    try {
      return BloodType.values.firstWhere((b) => b.name == value);
    } catch (_) {
      return null;
    }
  }
}

/// Whether the user has completed initial profile setup
final hasProfileProvider = Provider<bool>((ref) {
  return StorageService.instance.hasProfile;
});
