import 'package:flutter/material.dart';
import '../../../models/lucky_day.dart';

class LuckyDayTag extends StatelessWidget {
  final LuckyDayType type;
  final bool compact;
  final VoidCallback? onTap;

  const LuckyDayTag({
    super.key,
    required this.type,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 2 : 6,
          vertical: compact ? 1 : 2,
        ),
        decoration: BoxDecoration(
          color: type.color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          type.displayName,
          style: TextStyle(
            color: type.textColor,
            fontSize: compact ? 6 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
