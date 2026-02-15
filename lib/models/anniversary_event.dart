/// 記念日カテゴリ
enum AnniversaryCategory {
  couple,
  family,
  lifeEvent,
  healthPetOther,
  longevity,
}

extension AnniversaryCategoryExtension on AnniversaryCategory {
  String get displayName {
    switch (this) {
      case AnniversaryCategory.couple:
        return 'カップル・パートナー';
      case AnniversaryCategory.family:
        return '子供・家族';
      case AnniversaryCategory.lifeEvent:
        return 'ライフイベント・キャリア';
      case AnniversaryCategory.healthPetOther:
        return '健康・ペット・その他';
      case AnniversaryCategory.longevity:
        return '長寿・周年の祝い';
    }
  }

  String get emoji {
    switch (this) {
      case AnniversaryCategory.couple:
        return '💑';
      case AnniversaryCategory.family:
        return '👶';
      case AnniversaryCategory.lifeEvent:
        return '🎓';
      case AnniversaryCategory.healthPetOther:
        return '🐾';
      case AnniversaryCategory.longevity:
        return '🎉';
    }
  }
}

/// 記念日の種類（プルダウン用）
enum AnniversaryType {
  // --- カップル・パートナー ---
  firstMet,
  firstDate,
  confession,
  proposal,
  meetParents,
  yuinou,
  marriageRegistration,
  weddingCeremony,
  startLivingTogether,
  honeymoon,

  // --- 子供・家族 ---
  pregnancyDiscovered,
  dueDate,
  oshichiya,
  omiyamairi,
  okuizome,
  halfBirthday,
  hatsuZekku,
  firstWalk,
  firstWord,
  weaning,
  diaperGraduation,
  enrollment,
  graduation,
  comingOfAge,
  leavingHome,

  // --- ライフイベント・キャリア ---
  examPass,
  schoolGraduation,
  startWork,
  promotion,
  jobChange,
  startBusiness,
  retirement,
  homePurchase,
  carDelivery,
  firstOverseasTrip,
  qualificationObtained,

  // --- 健康・ペット・その他 ---
  petAdoption,
  quitSmoking,
  dietStart,
  recoveryDay,
  memorialDay,

  // --- 長寿・周年の祝い ---
  kanreki,
  koki,
  silverWedding,
  goldenWedding,

  // --- フリーワード ---
  custom,
}

extension AnniversaryTypeExtension on AnniversaryType {
  String get displayName {
    switch (this) {
      // カップル・パートナー
      case AnniversaryType.firstMet:
        return '出会った日';
      case AnniversaryType.firstDate:
        return '初デート記念日';
      case AnniversaryType.confession:
        return '告白記念日';
      case AnniversaryType.proposal:
        return 'プロポーズ記念日';
      case AnniversaryType.meetParents:
        return '両親への挨拶日';
      case AnniversaryType.yuinou:
        return '結納の日';
      case AnniversaryType.marriageRegistration:
        return '入籍記念日';
      case AnniversaryType.weddingCeremony:
        return '挙式記念日';
      case AnniversaryType.startLivingTogether:
        return '同棲開始日';
      case AnniversaryType.honeymoon:
        return '新婚旅行出発日';

      // 子供・家族
      case AnniversaryType.pregnancyDiscovered:
        return '妊娠判明日';
      case AnniversaryType.dueDate:
        return '出産予定日';
      case AnniversaryType.oshichiya:
        return 'お七夜（命名式）';
      case AnniversaryType.omiyamairi:
        return 'お宮参りの日';
      case AnniversaryType.okuizome:
        return 'お食い初めの日';
      case AnniversaryType.halfBirthday:
        return 'ハーフバースデー';
      case AnniversaryType.hatsuZekku:
        return '初節句';
      case AnniversaryType.firstWalk:
        return '初めて歩いた日';
      case AnniversaryType.firstWord:
        return '初めて喋った日';
      case AnniversaryType.weaning:
        return '断乳・卒乳の日';
      case AnniversaryType.diaperGraduation:
        return 'オムツ卒業の日';
      case AnniversaryType.enrollment:
        return '入園・入学記念日';
      case AnniversaryType.graduation:
        return '卒園・卒業記念日';
      case AnniversaryType.comingOfAge:
        return '成人式';
      case AnniversaryType.leavingHome:
        return '独り立ちの日';

      // ライフイベント・キャリア
      case AnniversaryType.examPass:
        return '受験合格日';
      case AnniversaryType.schoolGraduation:
        return '卒業記念日';
      case AnniversaryType.startWork:
        return '入社記念日';
      case AnniversaryType.promotion:
        return '昇進・昇格記念日';
      case AnniversaryType.jobChange:
        return '転職記念日';
      case AnniversaryType.startBusiness:
        return '起業・独立記念日';
      case AnniversaryType.retirement:
        return '退職記念日';
      case AnniversaryType.homePurchase:
        return 'マイホーム購入日';
      case AnniversaryType.carDelivery:
        return '納車記念日';
      case AnniversaryType.firstOverseasTrip:
        return '初海外旅行の日';
      case AnniversaryType.qualificationObtained:
        return '資格取得日';

      // 健康・ペット・その他
      case AnniversaryType.petAdoption:
        return 'ペットのお迎え記念日';
      case AnniversaryType.quitSmoking:
        return '禁煙開始日';
      case AnniversaryType.dietStart:
        return 'ダイエット開始日';
      case AnniversaryType.recoveryDay:
        return '病気完治の日';
      case AnniversaryType.memorialDay:
        return '命日';

      // 長寿・周年の祝い
      case AnniversaryType.kanreki:
        return '還暦（60歳）';
      case AnniversaryType.koki:
        return '古希（70歳）';
      case AnniversaryType.silverWedding:
        return '銀婚式（結婚25周年）';
      case AnniversaryType.goldenWedding:
        return '金婚式（結婚50周年）';

      // フリーワード
      case AnniversaryType.custom:
        return 'その他（自由入力）';
    }
  }

  AnniversaryCategory get category {
    switch (this) {
      case AnniversaryType.firstMet:
      case AnniversaryType.firstDate:
      case AnniversaryType.confession:
      case AnniversaryType.proposal:
      case AnniversaryType.meetParents:
      case AnniversaryType.yuinou:
      case AnniversaryType.marriageRegistration:
      case AnniversaryType.weddingCeremony:
      case AnniversaryType.startLivingTogether:
      case AnniversaryType.honeymoon:
        return AnniversaryCategory.couple;

      case AnniversaryType.pregnancyDiscovered:
      case AnniversaryType.dueDate:
      case AnniversaryType.oshichiya:
      case AnniversaryType.omiyamairi:
      case AnniversaryType.okuizome:
      case AnniversaryType.halfBirthday:
      case AnniversaryType.hatsuZekku:
      case AnniversaryType.firstWalk:
      case AnniversaryType.firstWord:
      case AnniversaryType.weaning:
      case AnniversaryType.diaperGraduation:
      case AnniversaryType.enrollment:
      case AnniversaryType.graduation:
      case AnniversaryType.comingOfAge:
      case AnniversaryType.leavingHome:
        return AnniversaryCategory.family;

      case AnniversaryType.examPass:
      case AnniversaryType.schoolGraduation:
      case AnniversaryType.startWork:
      case AnniversaryType.promotion:
      case AnniversaryType.jobChange:
      case AnniversaryType.startBusiness:
      case AnniversaryType.retirement:
      case AnniversaryType.homePurchase:
      case AnniversaryType.carDelivery:
      case AnniversaryType.firstOverseasTrip:
      case AnniversaryType.qualificationObtained:
        return AnniversaryCategory.lifeEvent;

      case AnniversaryType.petAdoption:
      case AnniversaryType.quitSmoking:
      case AnniversaryType.dietStart:
      case AnniversaryType.recoveryDay:
      case AnniversaryType.memorialDay:
        return AnniversaryCategory.healthPetOther;

      case AnniversaryType.kanreki:
      case AnniversaryType.koki:
      case AnniversaryType.silverWedding:
      case AnniversaryType.goldenWedding:
        return AnniversaryCategory.longevity;

      case AnniversaryType.custom:
        return AnniversaryCategory.healthPetOther;
    }
  }
}

/// 記念日データモデル
class AnniversaryEvent {
  final String id;
  final DateTime date;
  final String personName;
  final AnniversaryType type;
  final String? customTypeName; // type == custom の場合に使用
  final String? memo;
  final bool showEveryYear; // 毎年表示する
  final bool showOnCalendar; // カレンダーに表示
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnniversaryEvent({
    required this.id,
    required this.date,
    required this.personName,
    required this.type,
    this.customTypeName,
    this.memo,
    this.showEveryYear = true,
    this.showOnCalendar = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 表示用の記念日名
  String get displayTypeName {
    if (type == AnniversaryType.custom) {
      return customTypeName ?? 'その他';
    }
    return type.displayName;
  }

  /// 経過日数（今日からの差分）
  int get daysSince {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    return today.difference(eventDate).inDays;
  }

  /// 次の記念日までの日数
  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime nextDate = DateTime(now.year, date.month, date.day);
    if (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today)) {
      nextDate = DateTime(now.year + 1, date.month, date.day);
    }
    return nextDate.difference(today).inDays;
  }

  /// 何周年か
  int get yearsElapsed {
    final now = DateTime.now();
    int years = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  AnniversaryEvent copyWith({
    String? id,
    DateTime? date,
    String? personName,
    AnniversaryType? type,
    String? customTypeName,
    String? memo,
    bool? showEveryYear,
    bool? showOnCalendar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnniversaryEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      customTypeName: customTypeName ?? this.customTypeName,
      memo: memo ?? this.memo,
      showEveryYear: showEveryYear ?? this.showEveryYear,
      showOnCalendar: showOnCalendar ?? this.showOnCalendar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
