import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/colors.dart';
import '../../providers/calendar_provider.dart';
import '../../widgets/responsive_wrapper.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_list.dart';
import 'widgets/month_navigation.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // スワイプアニメーション用
  int _swipeDirection = 0; // -1=前月, 0=なし, 1=次月

  @override
  Widget build(BuildContext context) {
    final isGridView = ref.watch(isGridViewProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              border: Border(
                bottom: BorderSide(color: AppColors.red, width: 2),
              ),
            ),
            child: const Center(
              child: Text(
                '\u2728 \u5409\u65e5\u30ab\u30ec\u30f3\u30c0\u30fc \u2728',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Month navigation + Calendar body (responsive for iPad)
          Expanded(
            child: ResponsiveWrapper(
              child: Column(
                children: [
                  const MonthNavigation(),
                  // Calendar body (swipe left/right to change month)
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity > 300) {
                          // Swipe right → previous month
                          final current = ref.read(currentMonthProvider);
                          setState(() => _swipeDirection = -1);
                          ref.read(currentMonthProvider.notifier).state = DateTime(
                            current.year,
                            current.month - 1,
                            1,
                          );
                        } else if (velocity < -300) {
                          // Swipe left → next month
                          final current = ref.read(currentMonthProvider);
                          setState(() => _swipeDirection = 1);
                          ref.read(currentMonthProvider.notifier).state = DateTime(
                            current.year,
                            current.month + 1,
                            1,
                          );
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          final offsetX = _swipeDirection >= 0 ? 1.0 : -1.0;
                          final slideIn = Tween<Offset>(
                            begin: Offset(offsetX, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ));
                          return SlideTransition(
                            position: slideIn,
                            child: child,
                          );
                        },
                        child: isGridView
                            ? CalendarGrid(key: ValueKey(ref.watch(currentMonthProvider)))
                            : CalendarList(key: ValueKey(ref.watch(currentMonthProvider))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
