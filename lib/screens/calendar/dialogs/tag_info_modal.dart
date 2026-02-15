import 'package:flutter/material.dart';
import '../../../models/lucky_day.dart';
import '../widgets/lucky_day_tag.dart';

void showTagInfoModal(BuildContext context, LuckyDayType type) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          LuckyDayTag(type: type),
          const SizedBox(width: 8),
          Text(type.displayName),
        ],
      ),
      content: Text(
        type.description,
        style: const TextStyle(fontSize: 14, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('\u9589\u3058\u308b'),
        ),
      ],
    ),
  );
}
