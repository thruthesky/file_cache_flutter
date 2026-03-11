/// 카카오 네이티브 앱 키 (Flutter/iOS/Android용)
const String kakaoNativeAppKey = 'cf75184c7c72f507d6bb5e39627925d3';

/// v7 API 엔드포인트 (--dart-define=V7_API_ENDPOINT 으로 설정 가능)
final String v7ApiEndpoint = const String.fromEnvironment(
  'V7_API_ENDPOINT',
  defaultValue: 'https://philgo.com/api.php',
);

/// v7 서버 베이스 URL (파일/이미지 URL 조합에 사용)
/// 예: 'https://philgo.com' 또는 'https://v7-local.philgo.com'
final String v7BaseUrl = () {
  final uri = Uri.tryParse(v7ApiEndpoint);
  if (uri == null) return 'https://philgo.com';
  return 'https://${uri.host}';
}();

/// 포럼 카테고리 데이터 (postId, category, 한글 라벨)
const forumCategories = <(String, String?, String)>[
  ('freetalk', null, '자유게시판'),
  ('qna', null, '질문답변'),
  ('buyandsell', null, '사고팔기'),
  ('wanted', null, '구인구직'),
  ('travel', null, '여행'),
  ('massage', null, '마사지'),
  ('buyandsell', 'real_estate', '부동산'),
  ('freetalk', '뉴스', '뉴스'),
  ('buyandsell', '골프', '골프'),
  ('buyandsell', '렌트카', '렌트카'),
  ('freetalk', 'info', '정보'),
  ('freetalk', '코필커플', '코필커플'),
  ('freetalk', '코피노', '코피노'),
  ('freetalk', '이민', '이민'),
  ('freetalk', '국제결혼', '국제결혼'),
  ('freetalk', '먹방', '먹방'),
  ('freetalk', '경험담', '경험담'),
  ('freetalk', '마닐라', '마닐라'),
  ('freetalk', '세부', '세부'),
  ('freetalk', '앙헬레스', '앙헬레스'),
  ('freetalk', '행방불명', '행방불명'),
  ('buyandsell', '핸드폰', '핸드폰'),
  ('buyandsell', '컴퓨터/인터넷', '컴퓨터/인터넷'),
  ('buyandsell', '페소환전', '페소환전'),
  ('buyandsell', '개인장터', '개인장터'),
  ('buyandsell', '사업/동업구함', '사업/동업구함'),
  ('buyandsell', '가전/생활용품', '가전/생활용품'),
  ('boarding_house', null, '하숙/기숙사'),
  ('business', null, '비즈니스'),
  ('school', null, '학교'),
  ('study', null, '스터디'),
  ('caution', null, '주의사항'),
  ('greeting', null, '인사'),
  ('food_delivery', null, '음식배달'),
  ('rest', null, '레스토랑'),
  ('youtube', null, '유튜브'),
  ('blog', null, '블로그'),
];
