import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/daily_message.dart';

/// Service for providing daily inspirational messages
class DailyMessageService {
  List<DailyMessage>? _messages;

  /// Initialize by loading messages from bundled JSON
  Future<void> initialize() async {
    if (_messages != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/daily_messages_ja.json',
    );
    final List<dynamic> data = json.decode(jsonString);
    _messages = data.map((item) {
      return DailyMessage.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  /// Get the message for today (or a specific date)
  DailyMessage getMessage(DateTime date) {
    if (_messages == null || _messages!.isEmpty) {
      return const DailyMessage(
        dayOfYear: 0,
        message: '今日も素敵な一日になりますように。',
      );
    }

    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final index = dayOfYear % _messages!.length;
    return _messages![index];
  }

  bool get isInitialized => _messages != null;
}
