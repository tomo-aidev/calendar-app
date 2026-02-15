import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../models/anniversary_event.dart';
import '../../providers/anniversary_provider.dart';
import 'anniversary_form_screen.dart';

class AnniversaryScreen extends ConsumerWidget {
  const AnniversaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anniversaries = ref.watch(anniversaryProvider);

    // Sort by next occurrence (closest first)
    final sorted = List<AnniversaryEvent>.from(anniversaries)
      ..sort((a, b) => a.daysUntilNext.compareTo(b.daysUntilNext));

    return SafeArea(
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
                '記念日・誕生日',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: anniversaries.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _AnniversaryCard(
                        event: sorted[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnniversaryFormScreen(
                                existingEvent: sorted[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // Add button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnniversaryFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  '記念日を追加',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cake_outlined,
            size: 64,
            color: AppColors.gold.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '記念日・誕生日を登録しましょう',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.warmBrown.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '大切な日を忘れずに管理できます',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnniversaryCard extends StatelessWidget {
  final AnniversaryEvent event;
  final VoidCallback? onTap;

  const _AnniversaryCard({
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = event.daysUntilNext;
    final yearsElapsed = event.yearsElapsed;
    final isUpcoming = daysUntil <= 30;

    return Card(
      elevation: isUpcoming ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUpcoming
            ? const BorderSide(color: AppColors.gold, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Date circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.date.month}/${event.date.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isUpcoming ? AppColors.gold : AppColors.warmBrown,
                      ),
                    ),
                    if (yearsElapsed > 0)
                      Text(
                        '$yearsElapsed年',
                        style: TextStyle(
                          fontSize: 9,
                          color: isUpcoming
                              ? AppColors.gold.withValues(alpha: 0.7)
                              : Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.personName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warmBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 14,
                          color: event.type.category.emoji == '💑'
                              ? Colors.pink[300]
                              : AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.displayTypeName,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  AppColors.warmBrown.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.memo != null && event.memo!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        event.memo!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Days until next
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (daysUntil == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '今日！',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      'あと$daysUntil日',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isUpcoming ? AppColors.gold : Colors.grey[500],
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.date.year}/${event.date.month}/${event.date.day}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
