/// 앱 번역 데이터
///
/// easy_localization의 커스텀 AssetLoader에서 사용하는 번역 Map입니다.
/// JSON 파일 대신 Dart 코드에서 직접 번역 텍스트를 관리합니다.
/// 키는 반드시 한글로 작성합니다.
class Translations {
  Translations._();

  static const Map<String, dynamic> ko = {
    // 공통
    '로그인': '로그인',
    '로그아웃': '로그아웃',
    '로그인이 필요합니다': '로그인이 필요합니다',

    // 하단 네비게이션
    '홈': '홈',
    '게시판': '게시판',
    '채팅': '채팅',
    '업소록': '업소록',
    '메뉴': '메뉴',

    // 홈 화면
    '로그인이 필요합니다.': '로그인이 필요합니다.',
    '다음 레벨까지 {}%': '다음 레벨까지 {}%',
    '전화번호': '전화번호',
    '게시글': '게시글',
    '댓글': '댓글',
    '{}개': '{}개',
    '성별': '성별',
    '남성': '남성',
    '여성': '여성',
    '앱 설정': '앱 설정',
    'API 엔드포인트': 'API 엔드포인트',
    '베이스 URL': '베이스 URL',
    '포럼 카테고리': '포럼 카테고리',
    '카카오 앱 키': '카카오 앱 키',

    // 메뉴 화면
    '메뉴를 이용하려면 로그인해 주세요.': '메뉴를 이용하려면 로그인해 주세요.',
    '내 정보': '내 정보',
    '내 활동': '내 활동',
    '필리핀 생활 정보': '필리핀 생활 정보',
    '프로필 수정': '프로필 수정',
    '내 게시글': '내 게시글',
    '글쓰기': '글쓰기',
    '친구 검색': '친구 검색',
    '차단된 사용자': '차단된 사용자',
    '이벤트 쿠폰': '이벤트 쿠폰',
    '포인트 내역': '포인트 내역',
    '필수 정보': '필수 정보',
    '공지': '공지',
    '환율': '환율',
    '날씨': '날씨',
    '긴급연락처': '긴급연락처',
    '초보 필독': '초보 필독',
    '한달살기': '한달살기',
    '여행': '여행',
    '{}개 게시물': '{}개 게시물',
    '{}개 댓글': '{}개 댓글',

    // 로그인 화면
    '필고에 오신 것을 환영합니다': '필고에 오신 것을 환영합니다',
    '소셜 계정으로 간편하게 로그인하세요': '소셜 계정으로 간편하게 로그인하세요',
    '카카오로 로그인': '카카오로 로그인',
    'Google로 로그인': 'Google로 로그인',
  };

  static const Map<String, dynamic> en = {
    // 공통
    '로그인': 'Login',
    '로그아웃': 'Logout',
    '로그인이 필요합니다': 'Login required',

    // 하단 네비게이션
    '홈': 'Home',
    '게시판': 'Forum',
    '채팅': 'Chat',
    '업소록': 'Company',
    '메뉴': 'Menu',

    // 홈 화면
    '로그인이 필요합니다.': 'Please login to continue.',
    '다음 레벨까지 {}%': '{}% to next level',
    '전화번호': 'Phone',
    '게시글': 'Posts',
    '댓글': 'Comments',
    '{}개': '{}',
    '성별': 'Gender',
    '남성': 'Male',
    '여성': 'Female',
    '앱 설정': 'App Settings',
    'API 엔드포인트': 'API Endpoint',
    '베이스 URL': 'Base URL',
    '포럼 카테고리': 'Forum Categories',
    '카카오 앱 키': 'Kakao App Key',

    // 메뉴 화면
    '메뉴를 이용하려면 로그인해 주세요.': 'Please login to use the menu.',
    '내 정보': 'My Profile',
    '내 활동': 'My Activity',
    '필리핀 생활 정보': 'Philippines Info',
    '프로필 수정': 'Edit Profile',
    '내 게시글': 'My Posts',
    '글쓰기': 'Write',
    '친구 검색': 'Find Friends',
    '차단된 사용자': 'Blocked Users',
    '이벤트 쿠폰': 'Event Coupons',
    '포인트 내역': 'Point History',
    '필수 정보': 'Essential Info',
    '공지': 'Notices',
    '환율': 'Exchange Rate',
    '날씨': 'Weather',
    '긴급연락처': 'Emergency',
    '초보 필독': 'Beginner Guide',
    '한달살기': 'Month Stay',
    '여행': 'Travel',
    '{}개 게시물': '{} posts',
    '{}개 댓글': '{} comments',

    // 로그인 화면
    '필고에 오신 것을 환영합니다': 'Welcome to PhilGo',
    '소셜 계정으로 간편하게 로그인하세요': 'Sign in with your social account',
    '카카오로 로그인': 'Sign in with Kakao',
    'Google로 로그인': 'Sign in with Google',
  };
}
