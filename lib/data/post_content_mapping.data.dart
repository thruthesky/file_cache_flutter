/// 필고 게시글 번호 매핑 데이터 (PhilGo Post Content Mapping Data)
///
/// 앱의 각 화면에서 표시할 필고 게시글 번호를 정의합니다.
/// 새로운 화면을 추가할 때 이 파일에 글 번호를 추가하세요.
///
/// ### 사용법 (Usage):
/// ```dart
/// // 글 번호 가져오기
/// final postId = PostContentMapping.orRenewal;
///
/// // PostContentViewer 위젯에서 사용
/// PostContentViewer(postId: PostContentMapping.orRenewal)
/// ```
///
/// ### 새 매핑 추가 방법 (How to add new mapping):
/// 1. 이 파일에 새 상수 추가
/// 2. 해당 화면에서 PostContentViewer 위젯 사용
class PostContentMapping {
  /// 비공개 생성자 (Private constructor)
  /// 인스턴스화 방지
  PostContentMapping._();

  // ============================================================
  // 자동차 관련 (Car Related)
  // ============================================================

  /// 자동차 - OR 리뉴얼 정보 글 번호 (Car - OR Renewal Info Post ID)
  ///
  /// 필리핀 자동차 OR(Official Receipt) 리뉴얼 관련 정보
  static const int orRenewal = 1275694642;

  /// 자동차 - 자동차 구매 정보 글 번호 (Car - Car Purchase Info Post ID)
  ///
  /// 필리핀에서 자동차 구매 관련 정보
  /// TODO: 글 번호 설정 필요
  static const int carPurchase = 0;

  /// 자동차 - 자동차 보험 정보 글 번호 (Car - Car Insurance Info Post ID)
  ///
  /// 필리핀 자동차 보험 관련 정보
  /// TODO: 글 번호 설정 필요
  static const int carInsurance = 0;

  // ============================================================
  // 출입국 & 비자 관련 (Immigration & Visa Related)
  // ============================================================

  /// 출입국 - e트래블 정보 글 번호 (Immigration - eTravel Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int eTravel = 0;

  /// 출입국 - 여행비자 정보 글 번호 (Immigration - Travel Visa Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelVisa = 0;

  /// 출입국 - 워킹비자 정보 글 번호 (Immigration - Working Visa Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int workingVisa = 0;

  /// 출입국 - 은퇴비자 정보 글 번호 (Immigration - Retirement Visa Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int retirementVisa = 0;

  // ============================================================
  // 교통 수단 관련 (Transportation Related)
  // ============================================================

  /// 교통 - 택시 정보 글 번호 (Transportation - Taxi Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int taxi = 0;

  /// 교통 - 그랩 정보 글 번호 (Transportation - Grab Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int grab = 0;

  /// 교통 - 지프니 정보 글 번호 (Transportation - Jeepney Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int jeepney = 0;

  /// 교통 - 버스 정보 글 번호 (Transportation - Bus Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int bus = 0;

  /// 교통 - MRT/LRT 정보 글 번호 (Transportation - MRT/LRT Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int mrtLrt = 0;

  // ============================================================
  // 콘도/주택 임대 관련 (Housing Rental Related)
  // ============================================================

  /// 주택 - 콘도 임대 정보 글 번호 (Housing - Condo Rental Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int condoRental = 0;

  /// 주택 - 주택 임대 정보 글 번호 (Housing - House Rental Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int houseRental = 0;

  /// 주택 - 분양 정보 글 번호 (Housing - Sale Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int houseSale = 0;

  // ============================================================
  // 추천 거주 지역 관련 (Recommended Residence Area Related)
  // ============================================================

  /// 거주 지역 - BGC 정보 글 번호 (Residence - BGC Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int residenceBgc = 0;

  /// 거주 지역 - 올티가스 정보 글 번호 (Residence - Ortigas Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int residenceOrtigas = 0;

  /// 거주 지역 - 알라방 정보 글 번호 (Residence - Alabang Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int residenceAlabang = 0;

  // ============================================================
  // 달력/휴일 관련 (Calendar/Holiday Related)
  // ============================================================

  /// 달력 - 정규 휴일 정보 글 번호 (Calendar - Regular Holiday Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int regularHoliday = 0;

  /// 달력 - 특별 비근무일 정보 글 번호 (Calendar - Special Non-Working Day Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int specialWorkingDay = 0;

  // ============================================================
  // 필리핀 추천 여행지 관련 (Philippine Travel Destination Related)
  // ============================================================

  /// 여행지 - 마닐라 정보 글 번호 (Travel - Manila Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelManila = 0;

  /// 여행지 - 세부 정보 글 번호 (Travel - Cebu Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelCebu = 0;

  /// 여행지 - 수빅 정보 글 번호 (Travel - Subic Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelSubic = 0;

  /// 여행지 - 보홀 정보 글 번호 (Travel - Bohol Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelBohol = 0;

  /// 여행지 - 보라카이 정보 글 번호 (Travel - Boracay Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelBoracay = 0;

  /// 여행지 - 팔라완 정보 글 번호 (Travel - Palawan Info Post ID)
  /// TODO: 글 번호 설정 필요
  static const int travelPalawan = 0;
}
