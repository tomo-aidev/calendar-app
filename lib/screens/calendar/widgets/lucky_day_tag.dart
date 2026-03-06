import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/lucky_day.dart';
import '../../../providers/calendar_provider.dart';

class LuckyDayTag extends ConsumerWidget {
  final LuckyDayType type;
  final bool compact;
  final VoidCallback? onTap;

  const LuckyDayTag({
    super.key,
    required this.type,
    this.compact = false,
    this.onTap,
  });

  // compact font sizes indexed by dateFontSizeIndex: [S, M, L]
  static const _compactFontSizes = [7.0, 8.0, 10.0];
  static const _compactHPaddings = [2.0, 3.0, 4.0];
  static const _compactVPaddings = [1.0, 1.0, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateIdx = compact ? ref.watch(dateFontSizeIndexProvider) : 1;

    final fontSize = compact ? _compactFontSizes[dateIdx] : 10.0;
    final hPad = compact ? _compactHPaddings[dateIdx] : 6.0;
    final vPad = compact ? _compactVPaddings[dateIdx] : 2.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: vPad,
        ),
        decoration: BoxDecoration(
          color: type.color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          type.displayName,
          style: TextStyle(
            color: type.textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
