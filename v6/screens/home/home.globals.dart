/// 홈 화면의 네비게이션 바 항목을 나타내는 enum
///
/// 각 항목은 BottomNavigationBar의 인덱스와 매핑됨
enum HomeNavigationItem {
  home, // 홈
  forum, // 게시판
  company, // 업소록
  chat, // 채팅
  menu, // 메뉴
}

/// Enum for chat screen navigation bar items
/// 채팅 화면 전용 하단 네비게이션 바 항목
///
/// When the user is on the chat screen, this navigation bar is displayed
/// instead of the default HomeNavigationItem navigation bar
enum ChatNavigationItem {
  home, // Home - Navigate to main home
  forum, // Forum - Navigate to forum
  adminChat, // Admin Chat - Enter admin chat room directly
  singleChat, // 1:1 Chat - Show single chat list
  menu, // Menu - Navigate to menu
}
