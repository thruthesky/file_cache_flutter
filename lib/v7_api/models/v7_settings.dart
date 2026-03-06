/// v7 Settings API 응답 모델
///
/// v7 api.php → settings.get 엔드포인트 응답을 파싱하는 모델.
/// 앱 버전 정보, 이벤트 토글, 스피닝 휠 섹션/확률 등 DB(sf_config) 기반 동적 설정을 담는다.
class V7Settings {
  final String appVersionAndroid;
  final String appVersionAndroidBuild;
  final String appVersionIos;
  final String appVersionIosBuild;
  final bool companyQrEventEnabled;
  final bool eventEntryEnabled;
  final int availableStarbucksCoupons;

  /// 스피닝 휠 10개 섹션 (서버 settings.get → spin_sections)
  /// 각 섹션: {section_index, points, weight, prize_type}
  final List<SpinSection> spinSections;

  /// 스피닝 휠 게임 참가비 (차감 포인트)
  final int spinCost;

  /// 24시간 이내 스타벅스 재당첨 weight (0=불가, 1=0.1%, 기본 1)
  final int eventStarbucks24hWeight;

  V7Settings({
    required this.appVersionAndroid,
    required this.appVersionAndroidBuild,
    required this.appVersionIos,
    required this.appVersionIosBuild,
    required this.companyQrEventEnabled,
    required this.eventEntryEnabled,
    required this.availableStarbucksCoupons,
    required this.spinSections,
    required this.spinCost,
    required this.eventStarbucks24hWeight,
  });

  /// JSON 응답에서 V7Settings 생성
  ///
  /// "Y"/"N" 문자열을 bool로 변환한다.
  factory V7Settings.fromJson(Map<String, dynamic> json) {
    /// spin_sections 파싱
    final rawSections = json['spin_sections'] as List<dynamic>? ?? [];
    final sections = rawSections
        .map((e) => SpinSection.fromJson(e as Map<String, dynamic>))
        .toList();

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
      spinSections: sections,
      spinCost: (json['spin_cost'] as num?)?.toInt() ?? 200,
      eventStarbucks24hWeight:
          int.tryParse(json['event_starbucks_24h_weight']?.toString() ?? '') ??
              1,
    );
  }

  @override
  String toString() {
    return 'V7Settings('
        'android: $appVersionAndroid+$appVersionAndroidBuild, '
        'ios: $appVersionIos+$appVersionIosBuild, '
        'qrEvent: $companyQrEventEnabled, '
        'eventEntry: $eventEntryEnabled, '
        'starbucksCoupons: $availableStarbucksCoupons, '
        'spinCost: $spinCost, '
        'starbucks24hWeight: $eventStarbucks24hWeight, '
        'spinSections: ${spinSections.length})';
  }
}

/// 스피닝 휠 섹션 모델
///
/// 서버 settings.get → spin_sections 배열 요소.
/// weight 합계 1000 기준 확률 계산.
class SpinSection {
  final int sectionIndex;
  final int points;
  final int weight;
  final String prizeType;

  SpinSection({
    required this.sectionIndex,
    required this.points,
    required this.weight,
    required this.prizeType,
  });

  factory SpinSection.fromJson(Map<String, dynamic> json) {
    return SpinSection(
      sectionIndex: (json['section_index'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      prizeType: json['prize_type']?.toString() ?? 'point',
    );
  }

  /// weight / 10 = 퍼센트 (총 1000 기준)
  double get percent => weight / 10.0;

  /// 표시용 라벨
  String get label {
    switch (prizeType) {
      case 'starbucks':
        return '스타벅스';
      case 'miss':
        return '꽝';
      default:
        return '${points}P';
    }
  }
}
