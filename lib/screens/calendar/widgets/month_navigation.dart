import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../providers/calendar_provider.dart';

class MonthNavigation extends ConsumerWidget {
  const MonthNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final isGridView = ref.watch(isGridViewProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: AppColors.offWhite,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(currentMonthProvider.notifier).state = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
                1,
              );
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showYearMonthPicker(context, ref, currentMonth),
              child: Text(
                '${currentMonth.year}\u5e74${currentMonth.month}\u6708',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkFooter,
                ),
              ),
            ),
          ),
          // View toggle
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.gold,
            ),
            onPressed: () {
              ref.read(isGridViewProvider.notifier).state = !isGridView;
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(currentMonthProvider.notifier).state = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
                1,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showYearMonthPicker(
      BuildContext context, WidgetRef ref, DateTime current) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedYear = current.year;
        int selectedMonth = current.month;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('\u5e74\u6708\u3092\u9078\u629e'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            setState(() => selectedYear--),
                      ),
                      Text(
                        '$selectedYear\u5e74',
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            setState(() => selectedYear++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (i) {
                      final month = i + 1;
                      final isSelected = month == selectedMonth;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedMonth = month),
                        child: Container(
                          width: 60,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$month\u6708',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('\u30ad\u30e3\u30f3\u30bb\u30eb'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(currentMonthProvider.notifier).state =
                        DateTime(selectedYear, selectedMonth, 1);
                    Navigator.pop(context);
                  },
                  child: const Text('\u6c7a\u5b9a'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
