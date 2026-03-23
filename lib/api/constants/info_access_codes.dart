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

  /// 필리핀 여행비자 안내
  static const touristVisa = 'info:immigration:tourist-visa';

  /// 필리핀 워킹비자 안내
  static const workingVisa = 'info:immigration:working-visa';

  /// 필리핀 은퇴비자 안내
  static const retirementVisa = 'info:immigration:retirement-visa';

  // ===========================================================================
  // transport — 교통 수단
  // ===========================================================================

  /// 그랩 택시
  static const grabTaxi = 'info:transport:grab-taxi';

  /// 일반 택시
  static const regularTaxi = 'info:transport:regular-taxi';

  /// 고속 버스
  static const expressBus = 'info:transport:express-bus';

  /// 렌트카
  static const rentalCar = 'info:transport:rental-car';

  // ===========================================================================
  // housing — 콘도/주택 임대
  // ===========================================================================

  /// 월세
  static const monthlyRent = 'info:housing:monthly-rent';

  /// 에어비앤비
  static const airbnb = 'info:housing:airbnb';

  /// 호텔
  static const hotel = 'info:housing:hotel';

  // ===========================================================================
  // car — 자동차
  // ===========================================================================

  /// 자동차 구매
  static const carPurchase = 'info:car:purchase';

  /// 자동차 보험
  static const carInsurance = 'info:car:insurance';

  /// OR 리뉴얼
  static const orRenewal = 'info:car:or-renewal';

  // ===========================================================================
  // area — 추천 거주 지역
  // ===========================================================================

  /// BGC (보니파시오 글로벌 시티)
  static const bgc = 'info:area:bgc';

  /// 올티가스
  static const ortigas = 'info:area:ortigas';

  /// 알라방
  static const alabang = 'info:area:alabang';

  // ===========================================================================
  // helper — 도우미 & 가정교사
  // ===========================================================================

  /// 하우스헬퍼
  static const houseHelper = 'info:helper:house-helper';

  /// 운전기사
  static const driver = 'info:helper:driver';

  /// 가정교사
  static const tutor = 'info:helper:tutor';

  // ===========================================================================
  // travel — 여행지
  // ===========================================================================

  /// 마닐라
  static const manila = 'info:travel:manila';

  /// 세부
  static const cebu = 'info:travel:cebu';

  /// 수빅
  static const subic = 'info:travel:subic';

  /// 보홀
  static const bohol = 'info:travel:bohol';

  /// 보라카이
  static const boracay = 'info:travel:boracay';

  /// 팔라완
  static const palawan = 'info:travel:palawan';

  /// 엘니도
  static const elNidoOverview = 'info:travel:el-nido';

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
  // entertainment — 먹거리, 놀거리, 볼거리
  // ===========================================================================

  /// 여행 명소
  static const attractions = 'info:entertainment:attractions';

  /// 골프
  static const golf = 'info:entertainment:golf';

  /// 마사지
  static const massage = 'info:entertainment:massage';

  /// 밤문화
  static const nightlife = 'info:entertainment:nightlife';

  /// 시장 투어
  static const marketTour = 'info:entertainment:market-tour';

  /// 해산물
  static const seafood = 'info:entertainment:seafood';

  /// 맛집
  static const restaurants = 'info:entertainment:restaurants';

  /// 수상스포츠
  static const waterSports = 'info:entertainment:water-sports';

  /// 섬투어
  static const islandTour = 'info:entertainment:island-tour';

  /// 축제
  static const festivals = 'info:entertainment:festivals';

  // ===========================================================================
  // 전체 목록
  // ===========================================================================

  static const all = [
    embassy, emergencyNumbers, hospitals, koreanAssociation,
    otherAgencies, policeStations,
    eTravel, touristVisa, workingVisa, retirementVisa,
    grabTaxi, regularTaxi, expressBus, rentalCar,
    monthlyRent, airbnb, hotel,
    carPurchase, carInsurance, orRenewal,
    bgc, ortigas, alabang,
    houseHelper, driver, tutor,
    manila, cebu, subic, bohol, boracay, palawan, elNidoOverview,
    alonaBeach, whiteBeach, bantayanIsland, kawasanFalls,
    magellansCross, moalboalSardineRun, oceanPark, oslobWhaleShark,
    coron, elNido,
    attractions, golf, massage, nightlife, marketTour,
    seafood, restaurants, waterSports, islandTour, festivals,
  ];

  static const names = {
    embassy: '필리핀 내 대한민국 대사관 및 영사관',
    emergencyNumbers: '필리핀 긴급 연락처',
    hospitals: '필리핀 주요 병원 연락처',
    koreanAssociation: '필리핀 한인회 연락처',
    otherAgencies: '필리핀 기타 기관 연락처',
    policeStations: '필리핀 주요 경찰서 연락처',
    eTravel: '필리핀 eTravel 전자 입국 신고서',
    touristVisa: '필리핀 여행비자 안내',
    workingVisa: '필리핀 워킹비자 안내',
    retirementVisa: '필리핀 은퇴비자 안내',
    grabTaxi: '그랩 택시',
    regularTaxi: '일반 택시',
    expressBus: '고속 버스',
    rentalCar: '렌트카',
    monthlyRent: '월세',
    airbnb: '에어비앤비',
    hotel: '호텔',
    carPurchase: '자동차 구매',
    carInsurance: '자동차 보험',
    orRenewal: 'OR 리뉴얼',
    bgc: 'BGC (보니파시오 글로벌 시티)',
    ortigas: '올티가스',
    alabang: '알라방',
    houseHelper: '하우스헬퍼',
    driver: '운전기사',
    tutor: '가정교사',
    manila: '마닐라',
    cebu: '세부',
    subic: '수빅',
    bohol: '보홀',
    boracay: '보라카이',
    palawan: '팔라완',
    elNidoOverview: '엘니도',
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
    attractions: '여행 명소',
    golf: '골프',
    massage: '마사지',
    nightlife: '밤문화',
    marketTour: '시장 투어',
    seafood: '해산물',
    restaurants: '맛집',
    waterSports: '수상스포츠',
    islandTour: '섬투어',
    festivals: '축제',
  };
}
