/// v7 Settings API 응답 모델
///
/// v7 api.php → settings.get 엔드포인트 응답을 파싱하는 모델.
/// 앱 버전 정보, 이벤트 토글 등 DB(sf_config) 기반 동적 설정을 담는다.
///
/// 응답 예시:
/// ```json
/// {
///   "app_version_android": "2.0.16",
///   "app_version_android_build": "46",
///   "app_version_ios": "2.0.16",
///   "app_version_ios_build": "46",
///   "company_qr_event_enabled": "Y",
///   "event_entry_enabled": "Y",
///   "available_starbucks_coupons": 5
/// }
/// ```
class V7Settings {
  final String appVersionAndroid;
  final String appVersionAndroidBuild;
  final String appVersionIos;
  final String appVersionIosBuild;
  final bool companyQrEventEnabled;
  final bool eventEntryEnabled;
  final int availableStarbucksCoupons;

  V7Settings({
    required this.appVersionAndroid,
    required this.appVersionAndroidBuild,
    required this.appVersionIos,
    required this.appVersionIosBuild,
    required this.companyQrEventEnabled,
    required this.eventEntryEnabled,
    required this.availableStarbucksCoupons,
  });

  /// JSON 응답에서 V7Settings 생성
  ///
  /// "Y"/"N" 문자열을 bool로 변환한다.
  factory V7Settings.fromJson(Map<String, dynamic> json) {
    return V7Settings(
      appVersionAndroid: json['app_version_android']?.toString() ?? '',
      appVersionAndroidBuild:
          json['app_version_android_build']?.toString() ?? '',
      appVersionIos: json['app_version_ios']?.toString() ?? '',
      appVersionIosBuild: json['app_version_ios_build']?.toString() ?? '',
      companyQrEventEnabled:
          (json['company_qr_event_enabled']?.toString() ?? 'N') == 'Y',
      eventEntryEnabled:
          (json['event_entry_enabled']?.toString() ?? 'N') == 'Y',
      availableStarbucksCoupons:
          (json['available_starbucks_coupons'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'V7Settings('
        'android: $appVersionAndroid+$appVersionAndroidBuild, '
        'ios: $appVersionIos+$appVersionIosBuild, '
        'qrEvent: $companyQrEventEnabled, '
        'eventEntry: $eventEntryEnabled, '
        'starbucksCoupons: $availableStarbucksCoupons)';
  }
}
