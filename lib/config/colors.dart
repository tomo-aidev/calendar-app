import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Main colors
  static const Color gold = Color(0xFFD4AF37);
  static const Color red = Color(0xFFE73C3C);
  static const Color offWhite = Color(0xFFFFFBF0);
  static const Color darkFooter = Color(0xFF333333);
  static const Color orange = Color(0xFFFF8C00);

  // Header gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [gold, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Lucky day tag colors
  static const Color tenshanichi = Color(0xFFDAA520); // 天赦日 - Golden rod
  static const Color ichiryuManbaibi = Color(0xFFE91E8C); // 一粒万倍日 - Pink
  static const Color toranohi = Color(0xFFFFC107); // 寅の日 - Yellow
  static const Color minohi = Color(0xFF4CAF50); // 巳の日 - Green
  static const Color tsuchinotoMinohi = Color(0xFF009688); // 己巳の日 - Teal
  static const Color fujoujubi = Color(0xFF7F8C8D); // 不成就日 - Gray

  // Rokuyo colors
  static const Color taian = Color(0xFFE91E63); // 大安 - highlighted
  static const Color butsumetsu = Color(0xFF9E9E9E); // 仏滅 - muted

  // Calendar
  static const Color sunday = Color(0xFFE73C3C);
  static const Color saturday = Color(0xFF1976D2);
  static const Color today = Color(0xFFD4AF37);

  // Gender pastel colors
  static const Color femaleBg = Color(0xFFFCE4EC);
  static const Color femaleSelected = Color(0xFFF48FB1);
  static const Color maleBg = Color(0xFFBBDEFB);
  static const Color maleSelected = Color(0xFF42A5F5);
  static const Color otherBg = Color(0xFFF5F5F5);
  static const Color otherSelected = Color(0xFFE0E0E0);

  // Blood type pastel colors
  static const Color bloodABg = Color(0xFFBBDEFB);
  static const Color bloodASelected = Color(0xFF42A5F5);
  static const Color bloodBBg = Color(0xFFFCE4EC);
  static const Color bloodBSelected = Color(0xFFF48FB1);
  static const Color bloodOBg = Color(0xFFC8E6C9);
  static const Color bloodOSelected = Color(0xFF66BB6A);
  static const Color bloodABBg = Color(0xFFF3E5F5);
  static const Color bloodABSelected = Color(0xFFCE93D8);

  // Schedule form pop colors (feminine)
  static const Color popPink = Color(0xFFF48FB1);
  static const Color popPinkLight = Color(0xFFFCE4EC);
  static const Color popPinkBorder = Color(0xFFE0BFC7);
  static const Color warmBrown = Color(0xFF5D4037);
  static const Color formBg = Color(0xFFFFF0F5);

  // Fortune colors (Android only)
  static const Color fortuneOverall = Color(0xFFD4AF37);
  static const Color fortuneLove = Color(0xFFE91E63);
  static const Color fortuneWork = Color(0xFF1976D2);
  static const Color fortuneMoney = Color(0xFF4CAF50);
  static const Color fortuneHealth = Color(0xFFFF9800);

  // Work entry type colors
  static const Color workShift = Color(0xFF1976D2); // シフト - 青
  static const Color workFromHome = Color(0xFF4CAF50); // 在宅 - 緑
  static const Color workHoliday = Color(0xFFE91E63); // 休日 - ピンク

  // Lucky color map (Japanese name → Color)
  static const Map<String, Color> luckyColorMap = {
    '金': Color(0xFFD4AF37),
    '赤': Color(0xFFE73C3C),
    '青': Color(0xFF1976D2),
    '緑': Color(0xFF4CAF50),
    '黄': Color(0xFFFFC107),
    '紫': Color(0xFF9C27B0),
    'ピンク': Color(0xFFE91E63),
    'オレンジ': Color(0xFFFF9800),
    '白': Color(0xFF9E9E9E),
    '黒': Color(0xFF424242),
    '水色': Color(0xFF03A9F4),
    '茶': Color(0xFF795548),
    'シルバー': Color(0xFFBDBDBD),
  };
}
