/// 앱 번역 데이터
///
/// easy_localization의 커스텀 AssetLoader에서 사용하는 번역 Map입니다.
/// JSON 파일 대신 Dart 코드에서 직접 번역 텍스트를 관리합니다.
class Translations {
  Translations._();

  static const Map<String, dynamic> ko = {
    // 공통
    'login': '로그인',
    'logout': '로그아웃',
    'loginRequired': '로그인이 필요합니다',

    // 하단 네비게이션
    'nav': {
      'home': '홈',
      'forum': '게시판',
      'chat': '채팅',
      'company': '업소록',
      'menu': '메뉴',
    },

    // 홈 화면
    'home': {
      'loginRequired': '로그인이 필요합니다.',
      'nextLevel': '다음 레벨까지 {}%',
      'phoneNumber': '전화번호',
      'posts': '게시글',
      'comments': '댓글',
      'countUnit': '{}개',
      'gender': '성별',
      'male': '남성',
      'female': '여성',
      'appSettings': '앱 설정',
      'apiEndpoint': 'API 엔드포인트',
      'baseUrl': '베이스 URL',
      'forumCategories': '포럼 카테고리',
      'kakaoAppKey': '카카오 앱 키',
    },

    // 메뉴 화면
    'menu': {
      'title': '메뉴',
      'loginRequired': '로그인이 필요합니다',
      'loginMessage': '메뉴를 이용하려면 로그인해 주세요.',
      'myInfo': '내 정보',
      'myActivity': '내 활동',
      'philippinesInfo': '필리핀 생활 정보',
      'editProfile': '프로필 수정',
      'myPosts': '내 게시글',
      'write': '글쓰기',
      'searchFriends': '친구 검색',
      'blockedUsers': '차단된 사용자',
      'eventCoupons': '이벤트 쿠폰',
      'pointHistory': '포인트 내역',
      'essentialInfo': '필수 정보',
      'notices': '공지',
      'exchangeRate': '환율',
      'weather': '날씨',
      'emergencyContacts': '긴급연락처',
      'beginnerGuide': '초보 필독',
      'oneMonthLiving': '한달살기',
      'travel': '여행',
      'postCount': '{}개 게시물',
      'commentCount': '{}개 댓글',
    },

    // 로그인 화면
    'loginScreen': {
      'welcome': '필고에 오신 것을 환영합니다',
      'socialLoginMessage': '소셜 계정으로 간편하게 로그인하세요',
      'kakao': '카카오로 로그인',
      'google': 'Google로 로그인',
    },
  };

  static const Map<String, dynamic> en = {
    // 공통
    'login': 'Login',
    'logout': 'Logout',
    'loginRequired': 'Login required',

    // 하단 네비게이션
    'nav': {
      'home': 'Home',
      'forum': 'Forum',
      'chat': 'Chat',
      'company': 'Company',
      'menu': 'Menu',
    },

    // 홈 화면
    'home': {
      'loginRequired': 'Please login to continue.',
      'nextLevel': '{}% to next level',
      'phoneNumber': 'Phone',
      'posts': 'Posts',
      'comments': 'Comments',
      'countUnit': '{}',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'appSettings': 'App Settings',
      'apiEndpoint': 'API Endpoint',
      'baseUrl': 'Base URL',
      'forumCategories': 'Forum Categories',
      'kakaoAppKey': 'Kakao App Key',
    },

    // 메뉴 화면
    'menu': {
      'title': 'Menu',
      'loginRequired': 'Login required',
      'loginMessage': 'Please login to use the menu.',
      'myInfo': 'My Profile',
      'myActivity': 'My Activity',
      'philippinesInfo': 'Philippines Info',
      'editProfile': 'Edit Profile',
      'myPosts': 'My Posts',
      'write': 'Write',
      'searchFriends': 'Find Friends',
      'blockedUsers': 'Blocked Users',
      'eventCoupons': 'Event Coupons',
      'pointHistory': 'Point History',
      'essentialInfo': 'Essential Info',
      'notices': 'Notices',
      'exchangeRate': 'Exchange Rate',
      'weather': 'Weather',
      'emergencyContacts': 'Emergency',
      'beginnerGuide': 'Beginner Guide',
      'oneMonthLiving': 'Month Stay',
      'travel': 'Travel',
      'postCount': '{} posts',
      'commentCount': '{} comments',
    },

    // 로그인 화면
    'loginScreen': {
      'welcome': 'Welcome to PhilGo',
      'socialLoginMessage': 'Sign in with your social account',
      'kakao': 'Sign in with Kakao',
      'google': 'Sign in with Google',
    },
  };
}
