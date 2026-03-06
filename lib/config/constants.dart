class AppConstants {
  AppConstants._();

  static const String appName = '吉日カレンダー';
  static const String appVersion = '1.0.0';

  // Calendar data range
  static const int calendarStartYear = 2020;
  static const int calendarEndYear = 2035;

  // Default notification time (7:00 AM)
  static const int defaultNotificationHour = 7;
  static const int defaultNotificationMinute = 0;

  // Hive box names
  static const String profileBox = 'profile';
  static const String schedulesBox = 'schedules';
  static const String settingsBox = 'settings';
  static const String workEntriesBox = 'workEntries';

  // AdMob IDs (本番バナー広告ユニットID)
  static const String adMobBannerIdAndroid =
      'ca-app-pub-4861952933639074/3909732792';
  static const String adMobBannerIdIos =
      'ca-app-pub-4861952933639074/2109565961';

  // Heavenly Stems (天干)
  static const List<String> heavenlyStems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸',
  ];

  // Earthly Branches (地支)
  static const List<String> earthlyBranches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥',
  ];

  // Rokuyo names
  static const List<String> rokuyoNames = [
    '大安', '赤口', '先勝', '友引', '先負', '仏滅',
  ];
}
