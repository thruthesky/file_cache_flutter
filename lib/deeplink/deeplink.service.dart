/// 딥링크 파싱 결과 데이터 클래스
///
/// PhilGo URL을 파싱하여 추출한 정보를 담는 모델.
/// 게시글, 게시판 목록, 채팅방, 업소록, 홈 등 다양한 URL 유형을 지원한다.
class DeepLinkResult {
  final String? postId;
  final int? idx;
  final String? category;
  final int? page;
  final String? chatRoomId;
  final bool isPostView;
  final bool isPostList;
  final bool isHome;
  final bool isChatRoom;
  final bool isCompanyView;
  final bool isCompanyList;

  const DeepLinkResult({
    this.postId,
    this.idx,
    this.category,
    this.page,
    this.chatRoomId,
    this.isPostView = false,
    this.isPostList = false,
    this.isHome = false,
    this.isChatRoom = false,
    this.isCompanyView = false,
    this.isCompanyList = false,
  });
}

/// 필고 딥링크인지 확인하여 리다이렉트가 필요한지 판별한다.
///
/// GoRouter redirect에서 호출되며, v7 앱 내부 경로(이미 GoRouter에 등록된 경로)는
/// false를 반환하여 리다이렉트를 건너뛴다.
bool isDeepLinkUrl(Uri uri) {
  final path = uri.path;
  final query = uri.query;

  // .php 확장자가 포함된 레거시 URL
  if (path.contains('.php')) return true;

  // 레거시 숫자 전용 쿼리: /?1275666415
  if (query.isNotEmpty && RegExp(r'^\d+$').hasMatch(query)) return true;

  // v4 module=post 패턴
  if (uri.queryParameters.containsKey('module')) return true;

  // v7 클린 URL 패턴 (GoRouter에 등록되지 않은 경로)
  if (path == '/post/list') return true;
  if (path == '/company/view') return true;
  if (path == '/company' || path == '/company/') return true;

  return false;
}

/// PhilGo URL을 파싱하여 DeepLinkResult를 반환한다.
///
/// 지원하는 URL 패턴:
///
/// v7 클린 URL:
/// - `/post/view?idx=123&post_id=freetalk`
/// - `/post/list?post_id=buyandsell&category=핸드폰`
/// - `/company/view?idx=5422`
/// - `/company`
/// - `/chat`
///
/// v6 레거시 URL (.php 확장자):
/// - `/post/view.php?idx=123&post_id=freetalk`
/// - `/post/list.php?post_id=freetalk&category=취미`
/// - `/chat/index.php?id=xxx`
/// - `/company/view.php?idx=1025`
///
/// 기타 레거시:
/// - `/?1275666415` (숫자만)
/// - `/?module=post&action=view&post_id=travel&idx=123`
///
/// 인식할 수 없는 URL이면 null을 반환한다.
DeepLinkResult? parsePhilgoUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  final queryParams = uri.queryParameters;
  final path = uri.path;

  // post_id 추출
  final postId = queryParams['post_id'];

  // idx 추출: 일반 idx=값 또는 ?뒤에 숫자만 있는 레거시 패턴
  int? idx;
  final idxStr = queryParams['idx'];
  if (idxStr != null) {
    idx = int.tryParse(idxStr);
  } else if (uri.query.isNotEmpty && RegExp(r'^\d+$').hasMatch(uri.query)) {
    idx = int.tryParse(uri.query);
  }

  // category, page 추출
  final category = queryParams['category'];
  final pageStr = queryParams['page'];
  final page = pageStr != null ? int.tryParse(pageStr) : null;

  // URL 유형 판별 — v7 클린 URL + v6 .php URL 모두 지원
  final isPostView =
      path == '/post/view' ||
      path.contains('/post/view.php') ||
      (uri.query.isNotEmpty && RegExp(r'^\d+$').hasMatch(uri.query)) ||
      (queryParams['module'] == 'post' &&
          queryParams['action'] == 'view' &&
          idx != null);

  final isPostList = path == '/post/list' || path.contains('/post/list.php');

  final isChatRoom =
      path.contains('/chat/index.php') && queryParams.containsKey('id');

  final isCompanyView =
      path == '/company/view' || path.contains('/company/view.php');

  final isCompanyList = path == '/company' || path == '/company/';

  final isHome =
      !isPostView &&
      !isPostList &&
      !isChatRoom &&
      !isCompanyView &&
      !isCompanyList &&
      (path == '/' || path.isEmpty);

  // 채팅방 ID 추출
  final chatRoomId = queryParams['id'];

  return DeepLinkResult(
    postId: postId,
    idx: idx,
    category: category,
    page: page,
    chatRoomId: chatRoomId,
    isPostView: isPostView,
    isPostList: isPostList,
    isHome: isHome,
    isChatRoom: isChatRoom,
    isCompanyView: isCompanyView,
    isCompanyList: isCompanyList,
  );
}
