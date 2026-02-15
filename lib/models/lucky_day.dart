import 'package:flutter/material.dart';
import '../config/colors.dart';

/// 吉日種別
enum LuckyDayType {
  tenshanichi, // 天赦日
  ichiryuManbaibi, // 一粒万倍日
  toranohi, // 寅の日
  minohi, // 巳の日
  tsuchinotoMinohi, // 己巳の日
  fujoujubi, // 不成就日
}

extension LuckyDayTypeExtension on LuckyDayType {
  String get displayName {
    switch (this) {
      case LuckyDayType.tenshanichi:
        return '天赦日';
      case LuckyDayType.ichiryuManbaibi:
        return '一粒万倍日';
      case LuckyDayType.toranohi:
        return '寅の日';
      case LuckyDayType.minohi:
        return '巳の日';
      case LuckyDayType.tsuchinotoMinohi:
        return '己巳の日';
      case LuckyDayType.fujoujubi:
        return '不成就日';
    }
  }

  Color get color {
    switch (this) {
      case LuckyDayType.tenshanichi:
        return AppColors.tenshanichi;
      case LuckyDayType.ichiryuManbaibi:
        return AppColors.ichiryuManbaibi;
      case LuckyDayType.toranohi:
        return AppColors.toranohi;
      case LuckyDayType.minohi:
        return AppColors.minohi;
      case LuckyDayType.tsuchinotoMinohi:
        return AppColors.tsuchinotoMinohi;
      case LuckyDayType.fujoujubi:
        return AppColors.fujoujubi;
    }
  }

  Color get textColor {
    switch (this) {
      case LuckyDayType.toranohi:
      case LuckyDayType.tenshanichi:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  String get description {
    switch (this) {
      case LuckyDayType.tenshanichi:
        return '日本の暦の中で最上の大吉日。年に5〜6回しかない貴重な日。すべての神様が天に昇り、天が万物の罪を赦す日とされます。';
      case LuckyDayType.ichiryuManbaibi:
        return '一粒の籾（もみ）が万倍にも実る日。新しいことを始めるのに最適。ただし、借金や人から物を借りることは避けましょう。';
      case LuckyDayType.toranohi:
        return '金運に恵まれる日。寅（虎）は「千里行って千里帰る」とされ、お金を使っても戻ってくるといわれます。';
      case LuckyDayType.minohi:
        return '弁財天の縁日。金運・財運アップの日。芸術や音楽に関することにも吉。';
      case LuckyDayType.tsuchinotoMinohi:
        return '60日に一度の特別な弁財天の縁日。巳の日よりもさらに金運が高まるとされる最強の金運日。';
      case LuckyDayType.fujoujubi:
        return '何事も成就しない日とされる凶日。新しいことを始めるのは避けた方が良いでしょう。';
    }
  }

  bool get isAuspicious => this != LuckyDayType.fujoujubi;
}
