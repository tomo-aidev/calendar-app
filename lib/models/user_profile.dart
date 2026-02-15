enum Gender { female, male, other }

enum BloodType { a, b, o, ab }

enum ZodiacSign {
  aries, // 牡羊座
  taurus, // 牡牛座
  gemini, // 双子座
  cancer, // 蟹座
  leo, // 獅子座
  virgo, // 乙女座
  libra, // 天秤座
  scorpio, // 蠍座
  sagittarius, // 射手座
  capricorn, // 山羊座
  aquarius, // 水瓶座
  pisces, // 魚座
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.female:
        return '女性';
      case Gender.male:
        return '男性';
      case Gender.other:
        return 'その他';
    }
  }
}

extension BloodTypeExtension on BloodType {
  String get displayName {
    switch (this) {
      case BloodType.a:
        return 'A型';
      case BloodType.b:
        return 'B型';
      case BloodType.o:
        return 'O型';
      case BloodType.ab:
        return 'AB型';
    }
  }
}

extension ZodiacSignExtension on ZodiacSign {
  String get displayName {
    switch (this) {
      case ZodiacSign.aries:
        return '牡羊座';
      case ZodiacSign.taurus:
        return '牡牛座';
      case ZodiacSign.gemini:
        return '双子座';
      case ZodiacSign.cancer:
        return '蟹座';
      case ZodiacSign.leo:
        return '獅子座';
      case ZodiacSign.virgo:
        return '乙女座';
      case ZodiacSign.libra:
        return '天秤座';
      case ZodiacSign.scorpio:
        return '蠍座';
      case ZodiacSign.sagittarius:
        return '射手座';
      case ZodiacSign.capricorn:
        return '山羊座';
      case ZodiacSign.aquarius:
        return '水瓶座';
      case ZodiacSign.pisces:
        return '魚座';
    }
  }

  String get emoji {
    switch (this) {
      case ZodiacSign.aries:
        return '♈';
      case ZodiacSign.taurus:
        return '♉';
      case ZodiacSign.gemini:
        return '♊';
      case ZodiacSign.cancer:
        return '♋';
      case ZodiacSign.leo:
        return '♌';
      case ZodiacSign.virgo:
        return '♍';
      case ZodiacSign.libra:
        return '♎';
      case ZodiacSign.scorpio:
        return '♏';
      case ZodiacSign.sagittarius:
        return '♐';
      case ZodiacSign.capricorn:
        return '♑';
      case ZodiacSign.aquarius:
        return '♒';
      case ZodiacSign.pisces:
        return '♓';
    }
  }
}

class UserProfile {
  final String? name;
  final Gender gender;
  final DateTime? birthday;
  final BloodType? bloodType;

  const UserProfile({
    this.name,
    this.gender = Gender.female,
    this.birthday,
    this.bloodType,
  });

  ZodiacSign? get zodiacSign {
    if (birthday == null) return null;
    final month = birthday!.month;
    final day = birthday!.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return ZodiacSign.aries;
    }
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return ZodiacSign.taurus;
    }
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) {
      return ZodiacSign.gemini;
    }
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) {
      return ZodiacSign.cancer;
    }
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return ZodiacSign.leo;
    }
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return ZodiacSign.virgo;
    }
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) {
      return ZodiacSign.libra;
    }
    if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) {
      return ZodiacSign.scorpio;
    }
    if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) {
      return ZodiacSign.sagittarius;
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return ZodiacSign.capricorn;
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return ZodiacSign.aquarius;
    }
    return ZodiacSign.pisces;
  }

  UserProfile copyWith({
    String? name,
    Gender? gender,
    DateTime? birthday,
    BloodType? bloodType,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      bloodType: bloodType ?? this.bloodType,
    );
  }
}
