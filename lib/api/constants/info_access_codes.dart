/// Info 콘텐츠 access_code 상수 레지스트리
///
/// AI가 info 콘텐츠를 생성/수정/삭제할 때마다 이 파일을 자동 업데이트한다.
///
/// 동기화 대상 파일 (3개):
///   1. PHP: lib/info/InfoAccessCodes.php
///   2. 문서: data/info/ACCESS_CODES.md
///   3. Dart: lib/api/constants/info_access_codes.dart (이 파일)
class InfoAccessCodes {
  InfoAccessCodes._();

  // ===========================================================================
  // contact — 연락처
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
  // immigration — 출입국/비자
  // ===========================================================================

  /// 필리핀 eTravel 전자 입국 신고서
  static const eTravel = 'info:immigration:e-travel';

  // ===========================================================================
  // travel — 여행지
  // ===========================================================================

  /// 보홀 알로나 비치
  static const alonaBeach = 'info:travel:bohol:alona-beach';

  /// 보라카이 화이트 비치
  static const whiteBeach = 'info:travel:boracay:white-beach';

  /// 반타얀 섬
  static const bantayanIsland = 'info:travel:cebu:bantayan-island';

  /// 가와산 폭포
  static const kawasanFalls = 'info:travel:cebu:kawasan-falls';

  /// 마젤란 십자가
  static const magellansCross = 'info:travel:cebu:magellans-cross';

  /// 모알보알 사르디나 런
  static const moalboalSardineRun = 'info:travel:cebu:moalboal-sardine-run';

  /// 세부 오션 파크
  static const oceanPark = 'info:travel:cebu:ocean-park';

  /// 오슬롭 고래상어 투어
  static const oslobWhaleShark = 'info:travel:cebu:oslob-whale-shark';

  /// 코론 (팔라완)
  static const coron = 'info:travel:palawan:coron';

  /// 엘니도 (팔라완)
  static const elNido = 'info:travel:palawan:el-nido';

  // ===========================================================================
  // 전체 목록
  // ===========================================================================

  static const all = [
    embassy, emergencyNumbers, hospitals, koreanAssociation,
    otherAgencies, policeStations, eTravel,
    alonaBeach, whiteBeach, bantayanIsland, kawasanFalls,
    magellansCross, moalboalSardineRun, oceanPark, oslobWhaleShark,
    coron, elNido,
  ];

  static const names = {
    embassy: '필리핀 내 대한민국 대사관 및 영사관',
    emergencyNumbers: '필리핀 긴급 연락처',
    hospitals: '필리핀 주요 병원 연락처',
    koreanAssociation: '필리핀 한인회 연락처',
    otherAgencies: '필리핀 기타 기관 연락처',
    policeStations: '필리핀 주요 경찰서 연락처',
    eTravel: '필리핀 eTravel 전자 입국 신고서',
    alonaBeach: '보홀 알로나 비치',
    whiteBeach: '보라카이 화이트 비치',
    bantayanIsland: '반타얀 섬',
    kawasanFalls: '가와산 폭포',
    magellansCross: '마젤란 십자가',
    moalboalSardineRun: '모알보알 사르디나 런',
    oceanPark: '세부 오션 파크',
    oslobWhaleShark: '오슬롭 고래상어 투어',
    coron: '코론 (팔라완)',
    elNido: '엘니도 (팔라완)',
  };
}
