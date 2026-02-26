/// PhilGo URL 파싱 결과 타입 (Named Record)
/// PhilGo URL parsing result type (Named Record)
///
/// 모든 필드가 옵션입니다 (게시판 URL 외에도 다양한 URL 파싱 가능)
/// All fields are optional (can parse various URLs, not just post URLs)
///
/// 사용 예:
/// ```dart
/// final result = parsePhilgoUrl('https://philgo.com/post/view.php?idx=123&post_id=freetalk&category=취미&page=1');
/// if (result != null) {
/////   print(result.postId);      // 'freetalk' (nullable)
/////   print(result.idx);         // 123 (nullable)
/////   print(result.category);    // '취미' (nullable)
/////   print(result.page);        // 1 (nullable)
/////   print(result.chatRoomId);  // null (nullable, 채팅방 URL에서만 값 있음)
/// }
///
/// // 채팅방 URL 예시
/// final chatResult = parsePhilgoUrl('https://philgo.com/chat/room.php?id=RaHIcr45pvPzYdcDIv6JoW8DnSH2');
/// if (chatResult != null && chatResult.isChatRoom) {
/////   print(chatResult.chatRoomId);  // 'RaHIcr45pvPzYdcDIv6JoW8DnSH2'
/// }
/// ```
typedef PhilgoUrlResult = ({
  String? postId,
  int? idx,
  String? category,
  int? page,
  String? chatRoomId,
  bool isPostView,
  bool isPostList,
  bool isHome,
  bool isChatRoom,
});

/// PhilGo URL을 파싱하여 idx, post_id, category, page를 추출합니다.
/// Parses PhilGo URL and extracts idx, post_id, category, page.
///
/// [url] - PhilGo URL (게시판 URL 외에도 다양한 URL 파싱 가능)
///        예: https://philgo.com/post/view.php?idx=1275688865&post_id=freetalk&page=1
///        예: https://philgo.com/post/view.php?idx=1275674044&post_id=freetalk&category=%EC%B7%A8%EB%AF%B8&page=1
///        예: https://philgo.com/some/page.php?page=5
///        예: https://philgo.com/?1275666415 (특수 패턴: ?뒤에 숫자만 있으면 idx로 처리)
///
/// 반환값:
/// - 성공 시: ({postId: String?, idx: int?, category: String?, page: int?}) Named Record
/// - 실패 시: null (URL 형식이 올바르지 않은 경우)
///
/// 참고: category는 URL 인코딩된 문자열로 전달됨 (예: %EC%B7%A8%EB%AF%B8 = 취미)
///       Uri.parse가 자동으로 디코딩함
///
/// 특수 패턴:
/// - https://philgo.com/?1275666415 형태의 URL은
/// - https://philgo.com/?idx=1275666415 와 동일하게 처리됨
/// - ?뒤에 숫자로만 이루어진 값이 있으면 idx로 인식
///
/// 사용 예:
/// ```dart
/// final result = parsePhilgoUrl(url);
/// if (result != null) {
/////   print('Post ID: ${result.postId}');    // nullable
/////   print('IDX: ${result.idx}');           // nullable
/////   print('Category: ${result.category}'); // nullable
/////   print('Page: ${result.page}');         // nullable
/// }
/// ```
PhilgoUrlResult? parsePhilgoUrl(String url) {
  try {
    /// URL 파싱
    /// Parse URL
    final uri = Uri.parse(url);

    /// 쿼리 파라미터 추출
    /// Extract query parameters
    final queryParams = uri.queryParameters;

    /// post_id 추출 (선택, String?)
    /// Extract post_id (optional, String?)
    final postId = queryParams['post_id'];

    /// idx 추출 (선택, int?)
    /// Extract idx (optional, int?)
    ///
    /// 특수 패턴 처리: ?뒤에 숫자만 있는 경우 (예: ?1275666415)
    /// Special pattern: if query string is only digits (e.g., ?1275666415)
    /// uri.query는 전체 쿼리 문자열을 반환 (예: "1275666415" 또는 "idx=123&page=1")
    int? idx;
    final idxStr = queryParams['idx'];
    if (idxStr != null) {
      /// 일반적인 idx=값 형태
      /// Normal idx=value format
      idx = int.tryParse(idxStr);
    } else if (uri.query.isNotEmpty && RegExp(r'^\d+$').hasMatch(uri.query)) {
      /// 특수 패턴: ?뒤에 숫자만 있는 경우
      /// Special pattern: only digits after ?
      /// 예: https://philgo.com/?1275666415
      idx = int.tryParse(uri.query);
    }

    /// category 추출 (선택, String?)
    /// Extract category (optional, String?)
    /// URL 인코딩된 문자열은 Uri.parse가 자동으로 디코딩함
    /// URL encoded string is automatically decoded by Uri.parse
    final category = queryParams['category'];

    /// page 추출 (선택, int?)
    /// Extract page (optional, int?)
    final pageStr = queryParams['page'];
    final page = pageStr != null ? int.tryParse(pageStr) : null;

    /// URL 유형 판별
    /// Determine URL type
    /// - 게시글 보기: /post/view.php
    /// - 게시글 목록: /post/list.php
    /// - 홈: /
    /// - 채팅방: /chat/room.php 또는 /chat/rooms.php
    final path = uri.path;

    /// 게시글 보기 URL 판별 (v6 및 v4 호환)
    /// Determine if URL is a post view URL (v6 and v4 compatible)
    ///
    /// v6 패턴: /post/view.php?idx=123&post_id=freetalk
    /// v4 패턴들:
    ///   - /?1275637807 (숫자만 있는 경우)
    ///   - /?module=post&action=view&post_id=travel&idx=1275657361
    ///   - /?action=view&module=post&post_id=freetalk&category=한인총연합회&idx=1275655295
    ///   - /?page_no=853&action=view&module=post&post_id=buyandsell&idx=1275377734
    final isPostView =
        path.contains('/post/view.php') ||
        // v4 패턴: ?뒤에 숫자만 있는 경우 (idx만 있으면 게시글 보기로 간주)
        // v4 pattern: only digits after ? (treat as post view if only idx exists)
        (uri.query.isNotEmpty && RegExp(r'^\d+$').hasMatch(uri.query)) ||
        // v4 패턴: module=post && action=view && idx 존재
        // v4 pattern: module=post && action=view && idx exists
        (queryParams['module'] == 'post' &&
            queryParams['action'] == 'view' &&
            idx != null);

    final isPostList = path.contains('/post/list.php');
    final isHome = path == '/' || path.isEmpty;

    /// 채팅방 URL 패턴 체크
    /// Check chat room URL patterns
    /// - /chat/index.php?id=xxx (단수형, 새 패턴)
    /// - /chat/index.php?id=xxx (복수형, 기존 패턴)
    final isChatRoom =
        path.contains('/chat/index.php') || path.contains('/chat/index.php');

    /// 채팅방 ID 추출 (선택, String?)
    /// Extract chat room ID (optional, String?)
    /// 쿼리 파라미터에서 'id' 값을 추출
    final chatRoomId = queryParams['id'];

    /// Named Record로 반환
    /// Return as Named Record
    return (
      postId: postId,
      idx: idx,
      category: category,
      page: page,
      chatRoomId: chatRoomId,
      isPostView: isPostView,
      isPostList: isPostList,
      isHome: isHome,
      isChatRoom: isChatRoom,
    );
  } catch (e) {
    /// URL 파싱 실패 시 null 반환
    /// Return null if URL parsing fails
    return null;
  }
}
