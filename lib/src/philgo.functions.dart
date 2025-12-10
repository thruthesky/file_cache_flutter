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
///   print(result.postId);    // 'freetalk' (nullable)
///   print(result.idx);       // 123 (nullable)
///   print(result.category);  // '취미' (nullable)
///   print(result.page);      // 1 (nullable)
/// }
/// ```
typedef PhilgoUrlResult = ({
  String? postId,
  int? idx,
  String? category,
  int? page,
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
///   print('Post ID: ${result.postId}');    // nullable
///   print('IDX: ${result.idx}');           // nullable
///   print('Category: ${result.category}'); // nullable
///   print('Page: ${result.page}');         // nullable
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
    } else if (uri.query.isNotEmpty &&
        RegExp(r'^\d+$').hasMatch(uri.query)) {
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

    /// Named Record로 반환
    /// Return as Named Record
    return (postId: postId, idx: idx, category: category, page: page);
  } catch (e) {
    /// URL 파싱 실패 시 null 반환
    /// Return null if URL parsing fails
    return null;
  }
}
