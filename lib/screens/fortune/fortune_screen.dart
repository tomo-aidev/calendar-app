import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../models/lucky_day.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/fortune_provider.dart';
import '../../providers/profile_provider.dart';
import 'widgets/daily_message_card.dart';
import 'widgets/fortune_card.dart';

class FortuneScreen extends ConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortune = ref.watch(todayFortuneProvider);
    final message = ref.watch(todayMessageProvider);
    final profile = ref.watch(profileProvider);

    // Get today's calendar info
    final today = DateTime.now();
    final todayMonth = DateTime(today.year, today.month, 1);
    final days = ref.watch(monthCalendarProvider(todayMonth));
    final todayDay = days.isNotEmpty && today.day <= days.length
        ? days[today.day - 1]
        : null;

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
              child: Column(
                children: [
                  const Text(
                    '\u2728 \u4eca\u65e5\u306e\u904b\u52e2 \u2728',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${today.year}\u5e74${today.month}\u6708${today.day}\u65e5',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Daily message
                  DailyMessageCard(message: message.message),
                  const SizedBox(height: 16),
                  // Fortune card
                  FortuneCard(
                    fortune: fortune,
                    zodiacSign: profile.zodiacSign,
                  ),
                  const SizedBox(height: 16),
                  // Today's lucky day info
                  if (todayDay != null && todayDay.luckyDays.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.stars, color: AppColors.gold),
                                SizedBox(width: 8),
                                Text(
                                  '\u4eca\u65e5\u306e\u5409\u65e5\u30fb\u51f6\u65e5',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: todayDay.luckyDays.map((type) {
                                return Chip(
                                  backgroundColor:
                                      type.color.withValues(alpha: 0.15),
                                  label: Text(
                                    type.displayName,
                                    style: TextStyle(
                                      color: type.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  side: BorderSide(
                                    color: type.color.withValues(alpha: 0.3),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
