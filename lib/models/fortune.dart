class Fortune {
  final DateTime date;
  final int overallLuck; // 1-5
  final int loveLuck; // 1-5
  final int workLuck; // 1-5
  final int moneyLuck; // 1-5
  final int healthLuck; // 1-5
  final String adviceMessage;
  final String luckyColor;
  final int luckyNumber;

  const Fortune({
    required this.date,
    required this.overallLuck,
    required this.loveLuck,
    required this.workLuck,
    required this.moneyLuck,
    required this.healthLuck,
    required this.adviceMessage,
    required this.luckyColor,
    required this.luckyNumber,
  });
}
