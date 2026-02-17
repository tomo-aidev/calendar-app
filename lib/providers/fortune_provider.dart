import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/daily_message.dart';
import '../services/fortune_service.dart';
import '../services/daily_message_service.dart';
import 'profile_provider.dart';

final fortuneServiceProvider = Provider<FortuneService>((ref) {
  return FortuneService();
});

final dailyMessageServiceProvider = Provider<DailyMessageService>((ref) {
  return DailyMessageService.instance;
});

/// Today's fortune based on user profile
final todayFortuneProvider = Provider<Fortune>((ref) {
  final service = ref.watch(fortuneServiceProvider);
  final profile = ref.watch(profileProvider);
  return service.generate(DateTime.now(), profile);
});

/// Today's daily message
final todayMessageProvider = Provider<DailyMessage>((ref) {
  final service = ref.watch(dailyMessageServiceProvider);
  return service.getMessage(DateTime.now());
});
