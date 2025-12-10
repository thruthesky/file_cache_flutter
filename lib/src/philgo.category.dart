/// 필고 카테고리 클래스
///
/// PHP PostListHref 클래스의 post_id와 category 정보를 기반으로 생성된 클래스입니다.
/// - post_id: 메인 카테고리 (예: freetalk, buyandsell, qna 등)
/// - category: 서브 카테고리 (예: discussion, 백과, 취미 등)
///
/// 사용 예시:
/// ```dart
/// // 모든 메인 카테고리 가져오기
/// final mainCats = PhilgoCategory.mainCategories();
///
/// // 특정 메인 카테고리의 서브카테고리 가져오기
/// final subCats = PhilgoCategory.subCategories('freetalk');
///
/// // 모든 카테고리 맵 가져오기
/// final allCats = PhilgoCategory.mainCategoriesWithSubcategories();
/// ```
class PhilgoCategory {
  /// 내부 데이터: 메인 카테고리(post_id)별 서브카테고리 맵
  ///
  /// 서브카테고리가 없는 메인 카테고리는 빈 배열로 표시됩니다.
  /// 서브카테고리는 한글 또는 영문, 특수문자(슬래시 등)를 포함할 수 있습니다.
  static const Map<String, List<String>> _categoryMap = {
    // ===== 서브카테고리가 있는 메인 카테고리 =====

    /// freetalk (자유게시판) - 19개 서브카테고리
    'freetalk': [
      'discussion', // 토론
      '취미', // 취미
      'info', // 정보
      '코필커플', // 한국-필리핀 커플
      '코피노', // 코피노
      '이민', // 이민
      '사진', // 라이프샷
      '생활의팁', // 생활 팁
      '국제결혼', // 국제결혼
      '모임', // 모임
      'column', // 칼럼
      '먹방', // 먹방
      '뉴스', // 뉴스
      '경험담', // 경험담
      '공부', // 공부/학습
      '태풍', // 날씨/태풍
    ],

    /// buyandsell (사고팔기) - 13개 서브카테고리
    'buyandsell': [
      '사업/동업구함', // 사업 파트너
      '컴퓨터/인터넷', // 컴퓨터/인터넷
      '페소환전', // 환전
      '핸드폰', // 핸드폰
      '호텔', // 호텔
      '가전/생활용품', // 가전제품/생활용품
      '골프', // 골프
      'promotion', // 프로모션
      '개인장터', // 개인 거래
      'real_estate', // 부동산
      '주택임대', // 주택 임대
      '렌트카', // 렌트카
      '중고차', // 중고차
    ],

    // ===== 서브카테고리가 없는 메인 카테고리 =====

    /// qna (질문과 답변)
    'qna': [],

    /// blog (블로그)
    'blog': [],

    /// boarding_house (하숙집/기숙사)
    'boarding_house': [],

    /// business (비즈니스)
    'business': [],

    /// caution (주의/경고)
    'caution': [],

    /// company_info (회사 정보)
    'company_info': [],

    /// english_biz (영어 비즈니스)
    'english_biz': [],

    /// food_delivery (음식 배달)
    'food_delivery': [],

    /// greeting (인사)
    'greeting': [],

    /// lookfor (행방)
    'lookfor': [],

    /// massage (마사지)
    'massage': [],

    /// momcafe (맘카페)
    'momcafe': [],

    /// nature (자연/리포트)
    'nature': [],

    /// news (속보/헤드라인)
    'news': [],

    /// newcomer (새내기)
    'newcomer': [],

    /// rest (레스토랑)
    'rest': [],

    /// school (학교)
    'school': [],

    /// study (스터디/어학연수)
    'study': [],

    /// temp (임시)
    'temp': [],

    /// travel (여행)
    'travel': [],

    /// travel_good (추천 여행지)
    'travel_good': [],

    /// wanted (구직)
    'wanted': [],

    /// youtube (유튜브)
    'youtube': [],
  };

  /// 모든 메인 카테고리(post_id) 목록을 반환합니다.
  ///
  /// 반환값: 26개의 메인 카테고리 문자열 배열
  ///
  /// 주의: 홈페이지에 표시할 때에는 majorCategories() 메서드를 통해서 메인 카테고리를 표시해야 합니다.
  ///
  /// 예시:
  /// ```dart
  /// final categories = PhilgoCategory.mainCategories();
  /// // ['freetalk', 'qna', 'buyandsell', 'blog', ...]
  /// ```
  static List<String> mainCategories() {
    return _categoryMap.keys.toList();
  }

  /// 사용자 또는 앱의 메뉴에 표시할 주요 메인 카테고리(post_id) 목록을 반환합니다.
  static List<String> majorCategories({bool includeTemp = false}) {
    return [
      if (includeTemp) 'temp', // 임시, Test forum.
      'freetalk', // 행불 포함
      'qna',
      'buyandsell',
      'wanted', // 구인구직
      'massage',
      'boarding_house',
      'travel',
      'business',
      'school',
      'caution', // 주의사항
      'greeting',
      'food_delivery',
      'rest',
      'blog',
      'youtube',
    ];
  }

  /// 메뉴에 표시 할 메인 카테고리(post_id)와 해당 서브카테고리(category) 쌍의 목록을 반환합니다.
  /// 참고로, 서브카테고리가 없는 경우, category는 null로 표시됩니다.
  /// 예:
  /// ```dart
  /// final menuCats = PhilgoCategory.menuCategories();
  /// ```
  static List<(String, String?)> menuCategories() {
    return [
      ('freetalk', null),
      ('qna', null),
      ('buyandsell', null),
      ('wanted', null),
      ('travel', null),
      ('massage', null),
      ('freetalk', '뉴스'),

      //
      ('buyandsell', '골프'),
      ('buyandsell', '렌트카'),
      ('buyandsell', 'real_estate'),

      //
      ('freetalk', 'info'),
      ('freetalk', '코필커플'),
      ('freetalk', '코피노'),
      ('freetalk', '이민'),
      ('freetalk', '국제결혼'),
      ('freetalk', '먹방'),
      ('freetalk', '경험담'),
      ('freetalk', '마닐라'),
      ('freetalk', '세부'),
      ('freetalk', '앙헬레스'),
      ('freetalk', '행방불명'),

      ('buyandsell', '핸드폰'),
      ('buyandsell', '컴퓨터/인터넷'),
      ('buyandsell', '페소환전'),
      ('buyandsell', '개인장터'),
      ('buyandsell', '사업/동업구함'),
      ('buyandsell', '가전/생활용품'),

      ///
      ('boarding_house', null),
      ('business', null),
      ('school', null),
      ('caution', null),
      ('greeting', null),
      ('food_delivery', null),
      ('rest', null),
      ('youtube', null),
      ('blog', null),
    ];
  }

  /// 메뉴에 표시 할 메인 카테고리(post_id)와 해당 서브카테고리(category) 쌍의 목록을 반환합니다.
  /// 참고로, 서브카테고리가 없는 경우, category는 null로 표시됩니다.
  /// 예:
  /// ```dart
  /// final menuCats = PhilgoCategory.menuCategories();
  /// ```
  static List<(String, String?)> homeMenuCategories() {
    return [
      ('freetalk', null),
      ('qna', null),
      ('buyandsell', null),
      ('wanted', null),
      ('travel', null),
      ('massage', null),
      ('freetalk', '뉴스'),
    ];
  }

  /// 모든 메인 카테고리와 해당 서브카테고리를 맵으로 반환합니다.
  ///
  /// 반환값: {메인카테고리: [서브카테고리들]} 형태의 맵
  /// 서브카테고리가 없는 메인 카테고리는 빈 배열을 가집니다.
  ///
  /// 예시:
  /// ```dart
  /// final allCategories = PhilgoCategory.mainCategoriesWithSubcategories();
  /// // {
  /// //   'freetalk': ['discussion', '백과', '취미', ...],
  /// //   'qna': ['여권/비자'],
  /// //   'buyandsell': ['사업/동업구함', ...],
  /// //   'blog': [],
  /// //   ...
  /// // }
  /// ```
  static Map<String, List<String>> mainCategoriesWithSubcategories() {
    // 불변 맵의 복사본을 반환하여 외부에서 수정 방지
    return Map<String, List<String>>.from(
      _categoryMap.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  /// 특정 메인 카테고리(post_id)의 서브카테고리 목록을 반환합니다.
  ///
  /// [postId]: 메인 카테고리 ID (예: 'freetalk', 'buyandsell', 'qna')
  ///
  /// 반환값: 해당 메인 카테고리의 서브카테고리 배열
  /// - 서브카테고리가 있는 경우: 서브카테고리 문자열 배열
  /// - 서브카테고리가 없거나 존재하지 않는 postId인 경우: 빈 배열
  ///
  /// 예시:
  /// ```dart
  /// final freetalkSubs = PhilgoCategory.subCategories('freetalk');
  /// // ['discussion', '백과', '취미', 'info', ...]
  ///
  /// final qnaSubs = PhilgoCategory.subCategories('qna');
  /// // ['여권/비자']
  ///
  /// final blogSubs = PhilgoCategory.subCategories('blog');
  /// // [] (빈 배열)
  ///
  /// final invalidSubs = PhilgoCategory.subCategories('invalid');
  /// // [] (빈 배열)
  /// ```
  static List<String> subCategories(String postId) {
    // 존재하지 않는 postId인 경우 빈 배열 반환
    if (!_categoryMap.containsKey(postId)) {
      return [];
    }
    // 불변 리스트의 복사본을 반환하여 외부에서 수정 방지
    return List<String>.from(_categoryMap[postId]!);
  }

  /// 특정 메인 카테고리에 서브카테고리가 있는지 확인합니다.
  ///
  /// [postId]: 메인 카테고리 ID
  ///
  /// 반환값: 서브카테고리가 있으면 true, 없으면 false
  ///
  /// 예시:
  /// ```dart
  /// PhilgoCategory.hasSubCategories('freetalk'); // true
  /// PhilgoCategory.hasSubCategories('blog'); // false
  /// ```
  static bool hasSubCategories(String postId) {
    return _categoryMap.containsKey(postId) && _categoryMap[postId]!.isNotEmpty;
  }

  /// 메인 카테고리가 유효한지 확인합니다.
  ///
  /// [postId]: 확인할 메인 카테고리 ID
  ///
  /// 반환값: 유효한 메인 카테고리이면 true, 아니면 false
  ///
  /// 예시:
  /// ```dart
  /// PhilgoCategory.isValidMainCategory('freetalk'); // true
  /// PhilgoCategory.isValidMainCategory('invalid'); // false
  /// ```
  static bool isValidMainCategory(String postId) {
    return _categoryMap.containsKey(postId);
  }

  /// 서브카테고리가 특정 메인 카테고리에 속하는지 확인합니다.
  ///
  /// [postId]: 메인 카테고리 ID
  /// [category]: 확인할 서브카테고리
  ///
  /// 반환값: 해당 서브카테고리가 메인 카테고리에 속하면 true, 아니면 false
  ///
  /// 예시:
  /// ```dart
  /// PhilgoCategory.isValidSubCategory('freetalk', 'discussion'); // true
  /// PhilgoCategory.isValidSubCategory('freetalk', 'invalid'); // false
  /// PhilgoCategory.isValidSubCategory('qna', '여권/비자'); // true
  /// ```
  static bool isValidSubCategory(String postId, String category) {
    if (!_categoryMap.containsKey(postId)) {
      return false;
    }
    return _categoryMap[postId]!.contains(category);
  }
}
