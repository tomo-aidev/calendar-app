class DailyMessage {
  final int dayOfYear; // 1-366
  final String message;
  final String? author;

  const DailyMessage({
    required this.dayOfYear,
    required this.message,
    this.author,
  });

  factory DailyMessage.fromJson(Map<String, dynamic> json) {
    return DailyMessage(
      dayOfYear: json['dayOfYear'] as int,
      message: json['message'] as String,
      author: json['author'] as String?,
    );
  }
}
