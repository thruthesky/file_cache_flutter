import 'package:flutter/foundation.dart' show kDebugMode;

class AppConfig {
  static const String playstoreUrl =
      'https://play.google.com/store/apps/details?id=com.withcenter.philgo';
  static const String appstoreUrl =
      'https://apps.apple.com/us/app/philgo/id1480215987';

  static const String dataApiKey =
      "FAK7%2BJL3rqrFr7Wtn%2FxkKhW8hq1zDsite%2FxQdIwug4pDLD5bsqFJDKzroRXTkY8fm5LXMMMzIaTuvl%2F4iDtQ%2Bw%3D%3D";

  /// v7 설정 갱신 주기 (디버그: 30초, 프로덕션: 5분)
  static Duration get v7SettingsRefreshInterval =>
      kDebugMode ? const Duration(seconds: 30) : const Duration(minutes: 5);
}
