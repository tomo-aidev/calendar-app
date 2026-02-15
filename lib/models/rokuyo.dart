/// 六曜 (Rokuyō) - Six-day cycle of the Japanese calendar
enum Rokuyo {
  taian, // 大安 - Most auspicious
  shakku, // 赤口 - Only midday is lucky
  senshou, // 先勝 - Morning is lucky
  tomobiki, // 友引 - Avoid funerals
  senbu, // 先負 - Afternoon is lucky
  butsumetsu, // 仏滅 - Most inauspicious
  unknown, // Fallback for out-of-range dates
}

extension RokuyoExtension on Rokuyo {
  String get displayName {
    switch (this) {
      case Rokuyo.taian:
        return '大安';
      case Rokuyo.shakku:
        return '赤口';
      case Rokuyo.senshou:
        return '先勝';
      case Rokuyo.tomobiki:
        return '友引';
      case Rokuyo.senbu:
        return '先負';
      case Rokuyo.butsumetsu:
        return '仏滅';
      case Rokuyo.unknown:
        return '';
    }
  }

  String get shortName {
    switch (this) {
      case Rokuyo.taian:
        return '大安';
      case Rokuyo.shakku:
        return '赤口';
      case Rokuyo.senshou:
        return '先勝';
      case Rokuyo.tomobiki:
        return '友引';
      case Rokuyo.senbu:
        return '先負';
      case Rokuyo.butsumetsu:
        return '仏滅';
      case Rokuyo.unknown:
        return '';
    }
  }

  String get description {
    switch (this) {
      case Rokuyo.taian:
        return '万事において吉。結婚式・引っ越し・開業などに最適な日。';
      case Rokuyo.shakku:
        return '正午のみ吉。朝夕は凶とされる。';
      case Rokuyo.senshou:
        return '午前中は吉、午後は凶。急ぎ事に良い日。';
      case Rokuyo.tomobiki:
        return '朝夕は吉、昼は凶。葬儀は避ける日。';
      case Rokuyo.senbu:
        return '午前は凶、午後は吉。控えめに過ごすと良い日。';
      case Rokuyo.butsumetsu:
        return '万事に凶。お祝い事は避けた方が良い日。';
      case Rokuyo.unknown:
        return '';
    }
  }

  bool get isAuspicious => this == Rokuyo.taian;
  bool get isInauspicious => this == Rokuyo.butsumetsu;
}
