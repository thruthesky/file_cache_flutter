/// v7 settings.get API 응답 모델
///
/// settings.get API가 반환하는 전체 설정 데이터를 담는다.
/// 앱 버전, 이벤트 토글, 관리자 목록, 스피닝 휠 정보 등을 포함한다.
class Settings {
  final String appVersionAndroid;
  final String appVersionAndroidBuild;
  final String appVersionIos;
  final String appVersionIosBuild;
  final bool companyQrEventEnabled;
  final bool eventEntryEnabled;
  final List<String> adminUids;
  final String chatAdmin;
  final int availableStarbucksCoupons;
  final int spinCost;
  final List<SpinSection> spinSections;

  Settings({
    required this.appVersionAndroid,
    required this.appVersionAndroidBuild,
    required this.appVersionIos,
    required this.appVersionIosBuild,
    required this.companyQrEventEnabled,
    required this.eventEntryEnabled,
    required this.adminUids,
    required this.chatAdmin,
    required this.availableStarbucksCoupons,
    required this.spinCost,
    required this.spinSections,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    final admins = json['admins'] as Map<String, dynamic>?;
    final sectionsList = json['spin_sections'] as List<dynamic>? ?? [];

    return Settings(
      appVersionAndroid: json['app_version_android']?.toString() ?? '',
      appVersionAndroidBuild:
          json['app_version_android_build']?.toString() ?? '',
      appVersionIos: json['app_version_ios']?.toString() ?? '',
      appVersionIosBuild: json['app_version_ios_build']?.toString() ?? '',
      companyQrEventEnabled: json['company_qr_event_enabled'] == 'Y',
      eventEntryEnabled: json['event_entry_enabled'] == 'Y',
      adminUids:
          admins != null ? List<String>.from(admins['admins'] ?? []) : [],
      chatAdmin: admins?['chat_admin']?.toString() ?? '',
      availableStarbucksCoupons: _toInt(json['available_starbucks_coupons']),
      spinCost: _toInt(json['spin_cost']),
      spinSections:
          sectionsList
              .map((e) => SpinSection.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// 스피닝 휠 섹션 데이터
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
      sectionIndex: _toInt(json['section_index']),
      points: _toInt(json['points']),
      weight: _toInt(json['weight']),
      prizeType: json['prize_type']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
