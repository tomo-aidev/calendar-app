import 'dart:math';
import '../models/fortune.dart';
import '../models/user_profile.dart';

/// Deterministic fortune generator
/// Same date + same profile = same fortune (seeded random)
class FortuneService {
  static const List<String> _luckyColors = [
    '金', '赤', '白', 'ピンク', '黄', '緑', '青', '紫', 'オレンジ', '水色',
    'ラベンダー', 'シルバー', 'ベージュ', 'ネイビー', 'ブラウン',
  ];

  static const List<String> _adviceMessages = [
    '新しいことに挑戦するのに最適な日です。思い切って一歩踏み出しましょう。',
    '周りの人への感謝を伝えると、良い運気が巡ってきます。',
    '直感を信じて行動すると、思わぬ幸運に恵まれるでしょう。',
    '今日は自分磨きの日。美容やスキルアップに時間を使いましょう。',
    '大切な人との時間を大切にすると、心が満たされます。',
    '金運が上昇中。貯蓄を始めるのに良いタイミングです。',
    '笑顔を心がけると、自然と良いことが引き寄せられます。',
    '今日の出会いが未来を変えるかもしれません。オープンな気持ちで。',
    '小さな幸せに気づける日。日常の中の美しさを見つけましょう。',
    '整理整頓をすると、心もスッキリして運気アップにつながります。',
    '夢に向かって具体的な計画を立てるのに良い日です。',
    '水分をしっかり取って、体を大切にしましょう。健康が開運の基本です。',
    '趣味や好きなことに没頭すると、良いアイデアが生まれます。',
    '今日は静かに過ごすのが吉。読書や瞑想がおすすめです。',
    '友人からの誘いには積極的に応じましょう。良縁に恵まれます。',
    'お気に入りの服を着て出かけると、自信がアップします。',
    '朝の時間を大切にすると、一日のリズムが良くなります。',
    '感謝の気持ちを日記に書くと、幸せが倍増します。',
    '自然に触れると心が癒されます。公園や花に目を向けて。',
    '今日は決断の日。迷っていたことに答えを出しましょう。',
    '甘いものを楽しむと、心がほっとして良い気分転換に。',
    '丁寧な言葉遣いを心がけると、人間関係が好転します。',
    '今日のラッキーアクションは深呼吸。心を落ち着けて。',
    '新しいレシピに挑戦すると、食卓に幸せが広がります。',
    '昔の友人に連絡すると、嬉しい知らせがあるかもしれません。',
    '部屋に花を飾ると、運気がアップします。',
    'ゆっくりお風呂に浸かって、一日の疲れを癒しましょう。',
    '今日は「ありがとう」を10回言うことを目標に。',
    '好きな音楽を聴くと、心が元気になります。',
    '早起きして朝日を浴びると、一日中ポジティブでいられます。',
  ];

  /// Generate a fortune for the given date and user profile
  Fortune generate(DateTime date, UserProfile profile) {
    final seed = _computeSeed(date, profile);
    final rng = Random(seed);

    return Fortune(
      date: date,
      overallLuck: _generateLuck(rng),
      loveLuck: _generateLuck(rng),
      workLuck: _generateLuck(rng),
      moneyLuck: _generateLuck(rng),
      healthLuck: _generateLuck(rng),
      adviceMessage: _adviceMessages[rng.nextInt(_adviceMessages.length)],
      luckyColor: _luckyColors[rng.nextInt(_luckyColors.length)],
      luckyNumber: rng.nextInt(9) + 1,
    );
  }

  int _computeSeed(DateTime date, UserProfile profile) {
    int seed = date.year * 10000 + date.month * 100 + date.day;
    if (profile.birthday != null) {
      seed += profile.birthday!.month * 100 + profile.birthday!.day;
    }
    if (profile.bloodType != null) {
      seed += profile.bloodType!.index * 1000;
    }
    return seed;
  }

  /// Generate a luck value 1-5, weighted toward middle values
  int _generateLuck(Random rng) {
    // Weighted distribution: less likely to get 1 or 5
    final roll = rng.nextInt(100);
    if (roll < 5) return 1;
    if (roll < 20) return 2;
    if (roll < 55) return 3;
    if (roll < 85) return 4;
    return 5;
  }
}
