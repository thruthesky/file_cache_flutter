import 'package:philgo/api/api.service.dart';

import 'company.model.dart';

/// 업소록 API 서비스
///
/// 업소록 관련 모든 v7 API 호출을 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final companies = await CompanyService.list(category: 'food');
/// final company = await CompanyService.get(1025);
/// final mine = await CompanyService.mine();
/// final updated = await CompanyService.update({'name': '새 이름'});
/// ```
class CompanyService {
  CompanyService._();

  /// 업소 목록 조회
  ///
  /// API: company.list (인증 불필요)
  ///
  /// [category] 카테고리 필터 (선택)
  /// [page] 페이지 번호 (기본 1)
  /// [limit] 최대 조회 수 (기본 20, 최대 100)
  ///
  /// 반환: CompanyModel 목록
  static Future<List<CompanyModel>> list({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await ApiService.v7api(
      'company.list',
      data: {
        if (category != null) 'category': category,
        'page': page,
        'limit': limit,
      },
      debug: true,
    );

    final raw = result['items'];
    if (raw == null || raw is! List) return [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .toList();
  }

  /// 업소 단건 조회
  ///
  /// API: company.get (인증 불필요)
  ///
  /// [idx] 업소 고유번호
  /// 반환: CompanyModel 또는 null (업소가 없을 경우)
  static Future<CompanyModel?> get(int idx) async {
    final result = await ApiService.v7api('company.get', data: {'idx': idx});
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 내 업소 조회
  ///
  /// API: company.mine (인증 필수)
  ///
  /// 업소가 없으면 서버에서 자동 생성된다 (status='').
  /// 반환: CompanyModel 또는 null
  static Future<CompanyModel?> mine() async {
    final result = await ApiService.v7api('company.mine');
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 업소 생성 (최초 등록)
  ///
  /// API: company.create (인증 필수)
  ///
  /// 반환: 생성된 CompanyModel 또는 null
  static Future<CompanyModel?> create() async {
    final result = await ApiService.v7api('company.create');
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 업소 정보 수정
  ///
  /// API: company.update (인증 필수, 소유자 또는 관리자)
  ///
  /// [data] 수정할 필드 맵 (예: {'name': '새 이름', 'description': '새 설명'})
  ///
  /// description, title_image_url, photo_url 변경 시 status가 'p'(심사중)로
  /// 자동 전환된다.
  ///
  /// 반환: 수정된 CompanyModel 또는 null
  static Future<CompanyModel?> update(Map<String, dynamic> data) async {
    final result = await ApiService.v7api('company.update', data: data);
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 개발용 시드 데이터
  ///
  /// API 서버에 데이터가 없을 때 UI 개발/테스트용으로 사용하는 더미 업소 목록.
  /// 16개 카테고리 전체를 커버하는 20개 업소를 반환한다.
  static List<CompanyModel> seedData() {
    final items = [
      // public-office
      const CompanyModel(
        idx: 1001,
        idxMember: 1,
        name: 'Metro City Hall',
        title: '시청 민원 서비스 센터',
        description: '각종 민원 서류 발급 및 행정 서비스를 제공합니다. 여권, 주민등록등본, 인감증명서 등 모든 서류를 빠르게 처리해 드립니다.',
        category: 'public-office',
        location: 'Manila',
        address: '1 City Hall Dr, Manila, 1000 Metro Manila',
        phoneNumber: '+63-2-8527-3940',
        mobileNumber: '+63-917-123-4001',
        kakaotalkId: 'cityhall_manila',
        telegramId: '',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 1,
      ),
      // education
      const CompanyModel(
        idx: 1002,
        idxMember: 2,
        name: 'Sunshine Academy',
        title: '선샤인 어학원',
        description: '영어, 한국어, 필리핀어 전문 어학원입니다. 원어민 강사진과 함께하는 체계적인 커리큘럼으로 빠른 실력 향상을 보장합니다.',
        category: 'education',
        location: 'Cebu',
        address: 'A. Soriano Ave, Cebu City, 6000 Cebu',
        phoneNumber: '+63-32-412-8800',
        mobileNumber: '+63-918-234-5002',
        kakaotalkId: 'sunshine_academy',
        telegramId: '@sunshine_edu',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // food
      const CompanyModel(
        idx: 1003,
        idxMember: 3,
        name: 'Seoul Garden BBQ',
        title: '서울가든 한국 바베큐',
        description: '정통 한국식 삼겹살과 갈비를 즐길 수 있는 한식 레스토랑입니다. 신선한 식재료와 집에서 만든 김치로 고향의 맛을 제공합니다.',
        category: 'food',
        location: 'Manila',
        address: 'Jupiter St, Makati, 1209 Metro Manila',
        phoneNumber: '+63-2-8890-1234',
        mobileNumber: '+63-919-345-6003',
        kakaotalkId: 'seoulgardenbbq',
        telegramId: '',
        logoUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200',
        photoUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // food (2nd)
      const CompanyModel(
        idx: 1004,
        idxMember: 4,
        name: 'Jollibee Rivals Grill',
        title: '필리핀 로컬 그릴 맛집',
        description: '현지인도 즐겨찾는 필리핀 전통 그릴 요리 전문점. 이나솔(Inasal) 치킨과 신선한 망고 디저트가 인기 메뉴입니다.',
        category: 'food',
        location: 'Davao',
        address: 'Magsaysay Park, Davao City, 8000 Davao del Sur',
        phoneNumber: '+63-82-227-5678',
        mobileNumber: '+63-920-456-7004',
        kakaotalkId: '',
        telegramId: '@davao_grill',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 0,
      ),
      // transport
      const CompanyModel(
        idx: 1005,
        idxMember: 5,
        name: 'FastLink Shuttle',
        title: '패스트링크 공항 셔틀',
        description: '마닐라 공항에서 시내 주요 지점까지 안전하고 빠른 셔틀 서비스를 제공합니다. 24시간 예약 가능, 무료 와이파이 탑재.',
        category: 'transport',
        location: 'Manila',
        address: 'NAIA Terminal 3, Pasay, 1309 Metro Manila',
        phoneNumber: '+63-2-8551-9900',
        mobileNumber: '+63-921-567-8005',
        kakaotalkId: 'fastlink_shuttle',
        telegramId: '@fastlink_ph',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // hospital
      const CompanyModel(
        idx: 1006,
        idxMember: 6,
        name: 'MedCare Clinic',
        title: '메드케어 한인 의원',
        description: '한국어 통역 가능한 내과, 외과, 피부과 전문 클리닉입니다. 한국인 의사 상주, 한국 건강보험 청구 서류 발급 가능.',
        category: 'hospital',
        location: 'Cebu',
        address: 'Colon St, Cebu City, 6000 Cebu',
        phoneNumber: '+63-32-253-6600',
        mobileNumber: '+63-922-678-9006',
        kakaotalkId: 'medcare_cebu',
        telegramId: '',
        logoUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=200',
        photoUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 1,
      ),
      // mart
      const CompanyModel(
        idx: 1007,
        idxMember: 7,
        name: 'K-Mart Express',
        title: 'K마트 한국식품 전문점',
        description: '한국 라면, 과자, 조미료, 신선 식품까지 한국 식품을 한 곳에서 구입할 수 있습니다. 온라인 주문 및 배달 서비스도 제공합니다.',
        category: 'mart',
        location: 'Manila',
        address: 'Ermita, Manila, 1000 Metro Manila',
        phoneNumber: '+63-2-8523-7700',
        mobileNumber: '+63-923-789-0007',
        kakaotalkId: 'kmart_manila',
        telegramId: '@kmart_ph',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9c8a213?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9c8a213?w=800',
        status: 'a',
        showQrCode: 0,
      ),
      // bank
      const CompanyModel(
        idx: 1008,
        idxMember: 8,
        name: 'Global Remittance Hub',
        title: '글로벌 환전 송금 센터',
        description: '한국 원화, 미국 달러, 필리핀 페소 실시간 환전 서비스. 한국으로 가장 빠르고 저렴하게 송금할 수 있습니다.',
        category: 'bank',
        location: 'Manila',
        address: 'Binondo, Manila, 1006 Metro Manila',
        phoneNumber: '+63-2-8241-8800',
        mobileNumber: '+63-924-890-1008',
        kakaotalkId: 'global_remit',
        telegramId: '',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1601597111158-2fceff292cdc?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 1,
      ),
      // gadget
      const CompanyModel(
        idx: 1009,
        idxMember: 9,
        name: 'TechZone PH',
        title: '테크존 전자기기 전문점',
        description: '스마트폰, 노트북, 태블릿, 액세서리를 합리적인 가격에 판매합니다. 공식 삼성, LG, 애플 파트너샵으로 정품만 취급합니다.',
        category: 'gadget',
        location: 'Manila',
        address: 'SM City North EDSA, Quezon City, 1105 Metro Manila',
        phoneNumber: '+63-2-8929-4400',
        mobileNumber: '+63-925-901-2009',
        kakaotalkId: 'techzone_ph',
        telegramId: '@techzone_shop',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // travel-agency
      const CompanyModel(
        idx: 1010,
        idxMember: 10,
        name: 'Island Hopper Tours',
        title: '아일랜드 호퍼 투어',
        description: '보라카이, 팔라완, 세부 섬 투어 전문 여행사. 한국인 가이드 동행, 숙소·항공·투어 일정 원스톱 패키지 제공.',
        category: 'travel-agency',
        location: 'Cebu',
        address: 'IT Park, Lahug, Cebu City, 6000 Cebu',
        phoneNumber: '+63-32-415-2200',
        mobileNumber: '+63-926-012-3010',
        kakaotalkId: 'islandhopper',
        telegramId: '@island_tours',
        logoUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200',
        photoUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // hotel
      const CompanyModel(
        idx: 1011,
        idxMember: 11,
        name: 'Pearl Bay Resort',
        title: '펄베이 리조트 호텔',
        description: '해변 전망의 프리미엄 리조트. 수영장, 스파, 레스토랑을 갖춘 5성급 서비스를 합리적인 가격으로 제공합니다.',
        category: 'hotel',
        location: 'Boracay',
        address: 'Station 1, Boracay Island, 5608 Aklan',
        phoneNumber: '+63-36-288-5500',
        mobileNumber: '+63-927-123-4011',
        kakaotalkId: 'pearlbay_resort',
        telegramId: '',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // rentcar
      const CompanyModel(
        idx: 1012,
        idxMember: 12,
        name: 'DriveEasy Car Rental',
        title: '드라이브이지 렌터카',
        description: '경제형부터 SUV, 럭셔리 세단까지 다양한 차종을 보유하고 있습니다. 기사 포함 옵션 가능, 24시간 긴급출동 서비스 제공.',
        category: 'rentcar',
        location: 'Manila',
        address: 'Ortigas Center, Pasig, 1605 Metro Manila',
        phoneNumber: '+63-2-8633-7700',
        mobileNumber: '+63-928-234-5012',
        kakaotalkId: 'driveeasy_ph',
        telegramId: '@driveeasy',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 0,
      ),
      // beauty
      const CompanyModel(
        idx: 1013,
        idxMember: 13,
        name: 'K-Beauty Salon',
        title: 'K뷰티 한국 미용실',
        description: '한국 최신 트렌드 헤어 스타일링 전문 살롱. 한국식 드라이, 매직 스트레이트, 염색, 파마 전문. 한국어 상담 가능.',
        category: 'beauty',
        location: 'Cebu',
        address: 'Ayala Center Cebu, Cebu City, 6000 Cebu',
        phoneNumber: '+63-32-231-8800',
        mobileNumber: '+63-929-345-6013',
        kakaotalkId: 'kbeauty_salon',
        telegramId: '',
        logoUrl: 'https://images.unsplash.com/photo-1560066984-138daaa4e8cb?w=200',
        photoUrl: 'https://images.unsplash.com/photo-1560066984-138daaa4e8cb?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1560066984-138daaa4e8cb?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // real-estate
      const CompanyModel(
        idx: 1014,
        idxMember: 14,
        name: 'Prime Properties PH',
        title: '프라임 부동산 필리핀',
        description: '콘도, 아파트, 상가 임대 및 매매 전문. BGC, 마카티, 오르티가스 지역 한국인 선호 매물 다수 보유. 한국어 계약 지원.',
        category: 'real-estate',
        location: 'Manila',
        address: 'BGC, Taguig, 1634 Metro Manila',
        phoneNumber: '+63-2-8818-9900',
        mobileNumber: '+63-930-456-7014',
        kakaotalkId: 'primeprop_ph',
        telegramId: '@prime_realty',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        status: 'a',
        showQrCode: 0,
      ),
      // ktv
      const CompanyModel(
        idx: 1015,
        idxMember: 15,
        name: 'StarNight KTV',
        title: '스타나잇 노래방',
        description: '최신 한국, 팝, OPM 노래를 즐길 수 있는 프리미엄 노래방. 개인실 20개, 음향 시스템 최신화, 케이터링 서비스 제공.',
        category: 'ktv',
        location: 'Manila',
        address: 'Malate, Manila, 1004 Metro Manila',
        phoneNumber: '+63-2-8525-4400',
        mobileNumber: '+63-931-567-8015',
        kakaotalkId: 'starnight_ktv',
        telegramId: '',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 1,
      ),
      // spa
      const CompanyModel(
        idx: 1016,
        idxMember: 16,
        name: 'Lotus Wellness Spa',
        title: '로터스 웰니스 스파',
        description: '전통 태국 마사지와 한국식 때밀이를 결합한 프리미엄 스파. 1시간 전신 마사지부터 당일 패키지까지 다양한 코스 운영.',
        category: 'spa',
        location: 'Cebu',
        address: 'Capitol Site, Cebu City, 6000 Cebu',
        phoneNumber: '+63-32-255-6600',
        mobileNumber: '+63-932-678-9016',
        kakaotalkId: 'lotus_spa',
        telegramId: '@lotus_wellness',
        logoUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=200',
        photoUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // etc
      const CompanyModel(
        idx: 1017,
        idxMember: 17,
        name: 'Expat Services PH',
        title: '익스팻 서비스 필리핀',
        description: '비자 연장, 외국인 등록증(ACR), 사업자 등록, 법인 설립 등 외국인 생활에 필요한 모든 행정 서비스를 대행합니다.',
        category: 'etc',
        location: 'Manila',
        address: 'Intramuros, Manila, 1002 Metro Manila',
        phoneNumber: '+63-2-8527-8800',
        mobileNumber: '+63-933-789-0017',
        kakaotalkId: 'expat_services',
        telegramId: '@expat_ph',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 0,
      ),
      // food (3rd — pending review)
      const CompanyModel(
        idx: 1018,
        idxMember: 18,
        name: 'Bingsu & Coffee Corner',
        title: '빙수카페 코너',
        description: '정통 한국식 빙수와 아메리카노를 즐길 수 있는 디저트 카페. 인절미 빙수, 딸기 빙수, 망고 빙수가 인기 메뉴.',
        category: 'food',
        location: 'Davao',
        address: 'Lanang, Davao City, 8000 Davao del Sur',
        phoneNumber: '+63-82-235-7700',
        mobileNumber: '+63-934-890-1018',
        kakaotalkId: 'bingsu_davao',
        telegramId: '',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
        titleImageUrl: '',
        status: 'p',
        showQrCode: 0,
      ),
      // education (2nd)
      const CompanyModel(
        idx: 1019,
        idxMember: 19,
        name: 'TalentKids Learning Hub',
        title: '탤런트키즈 학습 센터',
        description: '유아·초등 대상 영어, 수학, 미술 통합 학습 센터. 소수 정예 클래스로 아이 한 명 한 명에게 집중하는 맞춤형 교육을 제공합니다.',
        category: 'education',
        location: 'Manila',
        address: 'Greenhills, San Juan, 1502 Metro Manila',
        phoneNumber: '+63-2-8726-3300',
        mobileNumber: '+63-935-901-2019',
        kakaotalkId: 'talentkids',
        telegramId: '',
        logoUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=200',
        photoUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
        titleImageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
        status: 'a',
        showQrCode: 1,
      ),
      // hotel (2nd)
      const CompanyModel(
        idx: 1020,
        idxMember: 20,
        name: 'Green Leaf Pension',
        title: '그린리프 게스트하우스',
        description: '배낭여행자와 장기 체류자를 위한 아늑한 게스트하우스. 공동 주방, 무료 와이파이, 관광 안내 서비스 제공.',
        category: 'hotel',
        location: 'Baguio',
        address: 'Session Rd, Baguio City, 2600 Benguet',
        phoneNumber: '+63-74-442-5500',
        mobileNumber: '+63-936-012-3020',
        kakaotalkId: 'greenleaf_baguio',
        telegramId: '@greenleaf_ph',
        logoUrl: '',
        photoUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
        titleImageUrl: '',
        status: 'a',
        showQrCode: 0,
      ),
    ];
    return items;
  }
}
