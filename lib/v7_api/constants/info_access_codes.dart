/// Info 콘텐츠 access_code 상수 레지스트리
///
/// AI가 info 콘텐츠를 생성/수정/삭제할 때마다 이 파일을 자동 업데이트한다.
/// Flutter 앱에서 access_code를 사용할 때 이 상수를 참조하여 오타를 방지한다.
///
/// 사용 예시:
/// ```dart
/// final embassy = await v7api('info.getByAccessCode', {
///   'access_code': InfoAccessCodes.embassy,
/// });
/// ```
///
/// 동기화 대상 파일 (3개):
///   1. PHP: lib/info/InfoAccessCodes.php
///   2. 문서: data/info/ACCESS_CODES.md
///   3. Dart: lib/v7_api/constants/info_access_codes.dart (이 파일)
class InfoAccessCodes {
  InfoAccessCodes._(); // 인스턴스화 방지

  // ===========================================================================
  // contact — 연락처 (대사관, 경찰서, 병원, 한인회, 긴급연락처)
  // ===========================================================================

  /// 필리핀 내 대한민국 대사관 및 영사관
  static const embassy = 'info:contact:embassy';

  /// 필리핀 긴급 연락처 (911, 경찰, 소방, 앰뷸런스)
  static const emergencyNumbers = 'info:contact:emergency-numbers';

  /// 필리핀 주요 병원 연락처
  static const hospitals = 'info:contact:hospitals';

  /// 필리핀 한인회 연락처 종합 안내
  static const koreanAssociation = 'info:contact:korean-association';

  /// 필리핀 기타 기관 연락처 (이민국, 기상청, 교통부)
  static const otherAgencies = 'info:contact:other-agencies';

  /// 필리핀 주요 경찰서 연락처
  static const policeStations = 'info:contact:police-stations';

  // ===========================================================================
  // 전체 access_code 목록
  // ===========================================================================

  /// 모든 access_code를 리스트로 반환
  static const all = [
    embassy,
    emergencyNumbers,
    hospitals,
    koreanAssociation,
    otherAgencies,
    policeStations,
  ];

  /// access_code → 한글 이름 매핑
  static const names = {
    embassy: '필리핀 내 대한민국 대사관 및 영사관',
    emergencyNumbers: '필리핀 긴급 연락처 (911, 경찰, 소방, 앰뷸런스)',
    hospitals: '필리핀 주요 병원 연락처',
    koreanAssociation: '필리핀 한인회 연락처 종합 안내',
    otherAgencies: '필리핀 기타 기관 연락처 (이민국, 기상청, 교통부)',
    policeStations: '필리핀 주요 경찰서 연락처',
  };
}
