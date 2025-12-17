import 'dart:developer';

import 'package:philgo_api/philgo_api.dart';

List<String?> getEnvironmentalPostId(String? postId, String? category) {
  if (PhilgoConfig.isDevelopment) {
    if (category == null || category.isEmpty) {
      return ['temp', ''];
    } else {
      return ['temp', category];
    }
  }
  return [postId, category];
}

String? getEnvironmentalCategory(String? category) {
  return category;
}

/// 게시글 목록을 조회하는 함수
///
/// PhilGo v6 API의 'post_list' 엔드포인트를 호출하여
/// 게시글 목록을 가져옵니다.
///
/// ## 매개변수
///
/// - [postId]: 게시판 ID (예: 'freetalk', 'qna', 'notice' 등)
///   - null인 경우 전체 게시판에서 조회
///   - 특정 게시판의 글만 조회하려면 해당 게시판 ID 지정
///
/// - [category]: 카테고리 필터
///   - 게시판 내 세부 카테고리로 필터링할 때 사용
///   - null인 경우 카테고리 필터 없이 전체 조회
///
/// - [has_image]: 이미지 포함 여부 필터
///   - true: 이미지가 포함된 게시글만 조회 (API에 'has_image': 'y' 전달)
///   - false (기본값): 이미지 유무와 관계없이 전체 조회
///   - 갤러리, 포토 게시판 등에서 유용
///
/// - [page]: 페이지 번호 (1부터 시작, 기본값: 1)
///   - 페이지네이션에 사용
///   - 무한 스크롤 구현 시 페이지 값을 증가시켜 호출
///
/// - [limit]: 페이지당 게시글 수 (기본값: 20)
///   - 한 번에 가져올 게시글 개수
///   - 서버 부하와 UX를 고려하여 적절한 값 설정 권장
///
/// - [orderBy]: 정렬 기준 (선택)
///   - 'stamp DESC': 최신순 (기본값)
///   - 'no_of_comment DESC': 댓글 많은 순
///   - 'no_of_view DESC': 조회수 높은 순
///   - 'good DESC': 추천 많은 순
///   - 'no_of_comment DESC, stamp DESC': 댓글 많은 순 → 최신순 (인기글용)
///
/// - [extraConditions]: 추가 조건 (선택)
///   - 'within_days': 최근 N일 이내의 글만 조회 (인기글 조회 시 사용)
///   - 'minimal_fields': 'y' 설정 시 최소 필드만 조회 (성능 최적화)
///
/// ## 반환값
///
/// [PostList] 객체를 반환합니다.
/// - PostList.posts: 게시글 목록 (`List<Post>`)
/// - PostList.page: 현재 페이지 번호
/// - PostList.limit: 페이지당 게시글 수
/// - PostList.noMorePosts: 더 이상 게시글이 없는지 여부
///
/// ## 사용 예시
///
/// ```dart
/// // 전체 게시판에서 첫 페이지 조회
/// final posts = await postList();
///
/// // 특정 게시판에서 조회
/// final freeTalkPosts = await postList(postId: 'freetalk');
///
/// // 이미지가 있는 글만 조회 (갤러리용)
/// final galleryPosts = await postList(postId: 'gallery', has_image: true);
///
/// // 페이지네이션 (두 번째 페이지, 한 페이지에 30개)
/// final nextPage = await postList(postId: 'notice', page: 2, limit: 30);
///
/// // 카테고리 필터링
/// final filteredPosts = await postList(postId: 'qna', category: 'flutter');
///
/// // 인기글 조회 (최근 7일간 댓글 많은 순)
/// final popularPosts = await postList(
///   limit: 5,
///   orderBy: 'no_of_comment DESC, stamp DESC',
///   extraConditions: {'within_days': 7, 'minimal_fields': 'y'},
/// );
/// ```
///
/// ## API 요청 형식
///
/// POST 요청으로 다음 데이터를 전송:
/// - post_id: 게시판 ID (선택)
/// - category: 카테고리 (선택)
/// - has_image: 'y' (이미지 필터 적용 시)
/// - page: 페이지 번호
/// - limit: 페이지당 개수
/// - order_by: 정렬 기준 (선택)
/// - extra_conditions: 추가 조건 (선택)
///
/// ## 주의사항
///
/// - 개발 환경([PhilgoConfig.isDevelopment])에서는 [getEnvironmentalPostId]를
///   통해 테스트용 게시판 ID로 대체될 수 있음 (현재 주석 처리됨)
/// - 네트워크 오류 시 예외가 발생할 수 있으므로 try-catch로 감싸서 사용 권장
Future<PostList> postList({
  String? postId,
  String? category,
  bool has_image = false,
  int page = 1,
  int limit = 20,
  String? orderBy,
  Map<String, dynamic>? extraConditions,
}) async {
  // 개발 환경에서 테스트용 게시판 ID로 대체하는 로직 (현재 비활성화)
  // [postId, category] = getEnvironmentalPostId(postId, category);

  // PhilGo v6 API의 'post_list' 엔드포인트 호출
  final res = await func(
    'post_list',
    data: {
      // postId가 null이 아닌 경우에만 요청 데이터에 포함
      if (postId != null) 'post_id': postId,
      // category가 null이 아닌 경우에만 요청 데이터에 포함
      if (category != null) 'category': category,
      // 이미지 필터가 활성화된 경우 'y' 값으로 전달
      if (has_image) 'has_image': 'y',
      // 정렬 기준이 지정된 경우 전달
      if (orderBy != null) 'order_by': orderBy,
      // 추가 조건이 지정된 경우 전달 (within_days, minimal_fields 등)
      if (extraConditions != null) 'extra_conditions': extraConditions,
      // 페이지네이션 파라미터
      'page': page,
      'limit': limit,
    },
    // debug: true, // 디버그 모드 활성화 시 요청/응답 로깅
  );

  // API 응답을 PostList 객체로 변환하여 반환
  // debugLog('postList: $res');
  return PostList.fromJson(res);
}

/// 게시글/댓글 목록을 조회하는 핵심 함수 (get_posts API)
///
/// PhilGo v6 API의 가장 유연하고 강력한 'get_posts' 엔드포인트를 호출합니다.
/// 대부분의 게시글/댓글 목록 조회 요구사항을 충족할 수 있습니다.
///
/// ## 핵심 파라미터
///
/// - [postId]: 게시판 ID (예: 'freetalk', 'qna', 'wanted' 등)
///   - null인 경우 전체 게시판에서 조회
///
/// - [category]: 카테고리 필터
///   - 게시판 내 세부 카테고리로 필터링
///
/// - [firebaseUid]: Firebase UID로 특정 사용자의 글만 조회
///   - 자동으로 `idx_member`로 변환됨
///
/// - [idxMember]: 회원 번호로 특정 사용자의 글만 조회
///
/// - [page]: 페이지 번호 (1부터 시작, 기본값: 1)
///
/// - [limit]: 페이지당 게시글 수 (기본값: 20)
///
/// - [type]: 조회 유형
///   - 'post': 게시글만 (기본값)
///   - 'comment': 댓글만
///   - 그 외: 모두 조회
///
/// - [fields]: 조회할 필드 목록 (쉼표로 구분)
///   - null인 경우 기본 필드 사용 (POST_LIST_FIELDS)
///
/// - [userInfo]: 사용자 정보 포함 여부 (기본값: false)
///   - true: 작성자 정보 포함
///   - false: 작성자 정보 제외 (성능 최적화)
///
/// - [stripTags]: HTML 태그 제거 여부 (기본값: true)
///   - true: HTML 태그 제거된 순수 텍스트 반환
///   - false: HTML 태그 포함
///
/// - [orderBy]: 정렬 기준
///   - 'stamp DESC': 최신순 (기본값)
///   - 'no_of_comment DESC': 댓글 많은 순
///   - 'no_of_view DESC': 조회수 높은 순
///   - 'good DESC': 추천 많은 순
///   - 'no_of_comment DESC, stamp DESC': 인기글 (댓글 많은 순 → 최신순)
///
/// - [extraConditions]: 추가 조건
///   - 'within_days': 최근 N일 이내의 글만 조회 (인기글용)
///   - 'minimal_fields': 'y' 설정 시 최소 필드만 조회 (성능 최적화)
///   - 'short_content': 짧은 내용만 조회
///   - 'exclude_post_id': 특정 게시판 제외
///
/// - [debug]: 디버그 모드 (기본값: false)
///   - true: API 요청/응답 로깅
///
/// ## 사용 예시
///
/// ```dart
/// // 전체 최신 게시글 20개 조회
/// final posts = await getPosts();
///
/// // 특정 게시판에서 조회
/// final freeTalkPosts = await getPosts(postId: 'freetalk');
///
/// // 특정 사용자의 글만 조회 (Firebase UID 사용)
/// final userPosts = await getPosts(firebaseUid: 'user-firebase-uid');
///
/// // 최신 댓글 조회
/// final comments = await getPosts(type: 'comment', limit: 10);
///
/// // 인기글 조회 (최근 30일간 댓글 많은 순)
/// final popularPosts = await getPosts(
///   limit: 20,
///   orderBy: 'no_of_comment DESC, stamp DESC',
///   extraConditions: {'within_days': 30, 'minimal_fields': 'y'},
/// );
///
/// // 성능 최적화 (사용자 정보 제외, 최소 필드만)
/// final fastPosts = await getPosts(
///   postId: 'qna',
///   userInfo: false,
///   extraConditions: {'minimal_fields': 'y'},
/// );
/// ```
///
/// ## 응답 형식
///
/// `List<Post>` 객체를 반환합니다.
/// 각 Post 객체에는 idx, post_id, category, subject, stamp, no_of_comment,
/// no_of_view, has_image, files 등이 포함됩니다.
Future<List<Post>> getPosts({
  // 게시판 및 카테고리 필터
  String? postId,
  String? category,

  // 사용자 필터 (둘 중 하나만 사용)
  String? firebaseUid,
  int? idxMember,

  // 페이지네이션
  int page = 1,
  int limit = 20,

  // 조회 유형: 'post' (게시글), 'comment' (댓글), 그 외 (모두)
  String type = 'post',

  // 조회할 필드 목록 (쉼표 구분, null이면 기본값 사용)
  String? fields,

  // 사용자 정보 포함 여부 (기본: false - 성능 최적화)
  bool userInfo = false,

  // HTML 태그 제거 여부 (기본: true - 보안 강화)
  bool stripTags = true,

  // 정렬 기준 (기본: 'stamp DESC' - 최신순)
  String? orderBy,

  // 추가 조건 (within_days, minimal_fields, short_content, exclude_post_id 등)
  Map<String, dynamic>? extraConditions,

  // 디버그 모드
  bool debug = false,
}) async {
  // PhilGo v6 API의 'get_posts' 엔드포인트 호출 (핵심 API)
  final res = await func<List<dynamic>>(
    'get_posts',
    data: {
      // 게시판 및 카테고리 필터
      if (postId != null) 'post_id': postId,
      if (category != null) 'category': category,

      // 사용자 필터 - Firebase UID 또는 회원 번호
      if (firebaseUid != null) 'firebase_uid': firebaseUid,
      if (idxMember != null) 'idx_member': idxMember,

      // 페이지네이션
      'page': page,
      'limit': limit,

      // 조회 유형 (post, comment, 또는 all)
      'type': type,

      // 조회할 필드 목록
      if (fields != null) 'fields': fields,

      // 사용자 정보 포함 여부
      'user_info': userInfo,

      // HTML 태그 제거 여부
      'strip_tags': stripTags,

      // 정렬 기준
      if (orderBy != null) 'order_by': orderBy,

      // 추가 조건 (within_days, minimal_fields, short_content, exclude_post_id 등)
      if (extraConditions != null) 'extra_conditions': extraConditions,
    },
    debug: debug,
  );

  // 디버그 로깅
  if (debug) {
    debugLog('getPosts 응답: ${res.length}개 항목');
  }

  // API 응답을 List<Post>로 변환하여 반환
  return res.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
}

Future<Post> getPost(int id) async {
  final res = await func('post_view', data: {'idx': id});
  // debugLog('getPost: $res');

  final post = Post.fromJson(res);

  log('=== GET POST API RESPONSE ===');
  log('$post');
  log('============================');

  return post;
}

Future<List<Post>> getLatestByUser({
  int? idx_member,
  String? firebase_uid,
  int limit = 10,
  int page = 1,
}) async {
  if (idx_member == null && firebase_uid == null) {
    throw ('idx_member or firebase_uid must exist');
  }
  final res = await func<List<dynamic>>(
    'get_posts',
    data: {
      'firebase_uid': firebase_uid,
      'idx_member': idx_member,
      'limit': limit,
      'page': page,
    },
    // debug: true,
  );
  debugLog('postList: $res');
  return (res).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
}

/// Create a post with PhilGo v6 API
/// It validates and display error dialog if validation fails.
/// Returns [Post] object.
Future<Post> createPost(RecordType data) async {
  // ========== 1. 유효성 검증 (깊이 있는 검증) ==========

  // post_id 유효성 검사 - 필수 항목 (게시판 ID)
  if (data['post_id'] == null || data['post_id'].toString().trim().isEmpty) {
    // 사용자에게 명확한 에러 메시지 표시
    showSafeErrorDialog('게시판 ID(post_id)가 필요합니다.');
    throw Exception('post_id가 지정되지 않았습니다');
  }

  // 제목 유효성 검사 - 필수 항목 (subject 필드 사용)
  if (data['subject'] == null || data['subject'].toString().trim().isEmpty) {
    // 사용자에게 명확한 에러 메시지 표시
    showSafeErrorDialog('게시글 제목을 입력해주세요.');
    throw Exception('제목이 비어있습니다');
  }

  // 내용 유효성 검사 - 필수 항목
  if (data['content'] == null || data['content'].toString().trim().isEmpty) {
    // 사용자에게 명확한 에러 메시지 표시
    showSafeErrorDialog('게시글 내용을 입력해주세요.');
    throw Exception('내용이 비어있습니다');
  }

  // 제목 길이 검증 (선택적 - 서버에서도 체크하지만 클라이언트에서 미리 체크)
  final subject = data['subject'].toString().trim();
  if (subject.length > 255) {
    showSafeErrorDialog('제목이 너무 깁니다. 255자 이내로 입력해주세요.');
    throw Exception('제목 길이 초과');
  }

  // 데이터 정제 - trim 처리된 값으로 업데이트
  final cleanedData = Map<String, dynamic>.from(data);
  cleanedData['post_id'] = data['post_id'].toString().trim(); // post_id 필수
  cleanedData['subject'] = subject; // subject 필드 사용
  cleanedData['content'] = data['content'].toString().trim();

  // category는 옵션 - 값이 있을 경우에만 포함
  if (data['category'] != null &&
      data['category'].toString().trim().isNotEmpty) {
    cleanedData['category'] = data['category'].toString().trim();
  }

  // files는 옵션 - 업로드된 파일 URL 목록
  if (data['files'] != null && data['files'] is List) {
    cleanedData['files'] = data['files'];
  }

  // ========== 2. 디버깅 정보 로깅 (개발 시 유용) ==========
  debugLog('게시글 작성 시작:');
  debugLog('  - post_id: ${cleanedData['post_id']}'); // post_id 로깅
  debugLog('  - 제목: ${cleanedData['subject']}'); // subject 필드 사용
  debugLog('  - 카테고리: ${cleanedData['category'] ?? '(미지정)'}'); // 카테고리는 옵션
  debugLog('  - 내용 길이: ${cleanedData['content'].toString().length}자');
  debugLog(
    '  - 파일 개수: ${data['files'] is List ? (data['files'] as List).length : 0}개',
  );

  // ========== 3. API 호출 ==========
  try {
    // post.create 엔드포인트 호출
    // auth: true로 Firebase ID Token 자동 포함
    final response = await func<Map<String, dynamic>>(
      'create_post',
      data: cleanedData,
      alertOnError: true, // 에러 시 자동으로 다이얼로그 표시
    );

    // ========== 4. 응답 처리 ==========

    // API가 에러를 반환한 경우 처리
    if (response['error'] != null) {
      final userMessage = response['message'] ?? '게시글 작성에 실패했습니다.';
      debugLog('게시글 작성 실패: ${response['error']} - $userMessage');

      showSafeErrorDialog(userMessage);
      throw Exception('게시글 작성 실패: ${response['error']}');
    }

    // ========== 5. 성공 처리 ==========

    // 응답에서 게시글 데이터 추출
    // API는 생성된 게시글의 전체 정보를 반환
    final postData = response;

    // Post 객체 생성 및 반환
    final post = Post.fromJson(postData);

    debugLog('게시글 작성 성공:');
    debugLog('  - idx: ${post.idx}');
    debugLog('  - 제목: ${post.subject}');
    debugLog('  - 작성시간: ${post.timeString}');

    // 성공적으로 생성된 Post 객체 반환
    return post;
  } catch (e) {
    // ========== 6. 예외 처리 ==========

    // philgoApi에서 이미 에러 다이얼로그를 표시하지만,
    // 추가적인 로깅이나 처리가 필요한 경우
    debugLog('게시글 작성 중 예외 발생: $e');

    // 에러를 상위로 다시 전파
    // 호출하는 쪽에서 추가 처리 가능
    rethrow;
  }
}

/// Update a post with PhilGo v6 API
///
/// It validates and display error dialog if validation fails.
///
/// Returns [Post] object.
Future<Post> updatePost(RecordType data) async {
  // ========== 1. 유효성 검증 (깊이 있는 검증) ==========

  // idx 유효성 검사 - 필수 항목 (수정할 게시글 고유 번호)
  if (data['idx'] == null || data['idx'].toString().trim().isEmpty) {
    // 사용자에게 명확한 에러 메시지 표시
    showSafeErrorDialog('수정할 게시글 번호(idx)가 필요합니다.');
    throw Exception('idx가 지정되지 않았습니다');
  }

  // idx가 유효한 숫자인지 확인
  int? idx;
  try {
    idx = int.parse(data['idx'].toString());
  } catch (e) {
    showSafeErrorDialog('유효하지 않은 게시글 번호입니다.');
    throw Exception('idx가 유효한 숫자가 아닙니다');
  }

  // 수정 내용이 하나라도 있는지 확인
  // subject, content, category, files 중 하나라도 있어야 함
  final hasSubject =
      data['subject'] != null && data['subject'].toString().trim().isNotEmpty;
  final hasContent =
      data['content'] != null && data['content'].toString().trim().isNotEmpty;
  final hasCategory = data['category'] != null;
  final hasFiles = data['files'] != null && data['files'] is List;

  if (!hasSubject && !hasContent && !hasCategory && !hasFiles) {
    showSafeErrorDialog('수정할 내용이 없습니다. 제목이나 내용을 입력해주세요.');
    throw Exception('수정할 내용이 없습니다');
  }

  // 데이터 정제 - 수정할 필드만 포함
  final cleanedData = <String, dynamic>{
    'idx': idx, // idx는 필수
  };

  // 제목이 있을 경우 추가 및 길이 검증
  if (hasSubject) {
    final subject = data['subject'].toString().trim();
    if (subject.length > 255) {
      showSafeErrorDialog('제목이 너무 깁니다. 255자 이내로 입력해주세요.');
      throw Exception('제목 길이 초과');
    }
    cleanedData['subject'] = subject;
  }

  // 내용이 있을 경우 추가
  if (hasContent) {
    cleanedData['content'] = data['content'].toString().trim();
  }

  // 카테고리가 있을 경우 추가
  if (hasCategory) {
    cleanedData['category'] = data['category']?.toString().trim();
  }

  // 파일이 있을 경우 추가
  if (hasFiles) {
    cleanedData['files'] = data['files'];
  }

  if (data['point_advertisement_days'] != null) {
    cleanedData['point_advertisement_days'] = data['point_advertisement_days'];
  }

  // ========== 2. 디버깅 정보 로깅 (개발 시 유용) ==========
  debugLog('게시글 수정 시작:');
  debugLog('  - idx: $idx');
  if (hasSubject) debugLog('  - 제목: ${cleanedData['subject']}');
  if (hasContent) {
    debugLog('  - 내용 길이: ${cleanedData['content'].toString().length}자');
  }
  if (hasCategory) debugLog('  - 카테고리: ${cleanedData['category'] ?? '(제거)'}');
  if (hasFiles) {
    debugLog('  - 파일 개수: ${(cleanedData['files'] as List).length}개');
  }

  // ========== 3. API 호출 ==========
  try {
    // post.update 엔드포인트 호출
    // auth: true로 Firebase ID Token 자동 포함
    final response = await func<Map<String, dynamic>>(
      'update_post',
      data: cleanedData,
      alertOnError: true, // 에러 시 자동으로 다이얼로그 표시
    );

    // ========== 4. 응답 처리 ==========

    // API가 에러를 반환한 경우 처리
    if (response['error'] != null) {
      final userMessage = response['message'] ?? '게시글 수정에 실패했습니다.';
      debugLog('게시글 수정 실패: ${response['error']} - $userMessage');

      showSafeErrorDialog(userMessage);
      throw Exception('게시글 수정 실패: ${response['error']}');
    }

    // ========== 5. 성공 처리 ==========

    // 응답에서 게시글 데이터 추출
    // API는 수정된 게시글의 전체 정보를 반환
    final postData = response;

    // Post 객체 생성 및 반환
    final post = Post.fromJson(postData);

    debugLog('게시글 수정 성공:');
    debugLog('  - idx: ${post.idx}');
    debugLog('  - 제목: ${post.subject}');
    debugLog('  - 수정시간: ${post.timeString}');

    // 성공적으로 수정된 Post 객체 반환
    return post;
  } catch (e) {
    // ========== 6. 예외 처리 ==========

    // philgoApi에서 이미 에러 다이얼로그를 표시하지만,
    // 추가적인 로깅이나 처리가 필요한 경우
    debugLog('게시글 수정 중 예외 발생: $e');

    // 에러를 상위로 다시 전파
    // 호출하는 쪽에서 추가 처리 가능
    rethrow;
  }
}

/// Delete a post with PhilGo v6 API
///
/// It validates and display error dialog if validation fails.
Future<Post> deletePost(int idx) async {
  debugLog('게시글 삭제 시작:');
  debugLog('  - idx: $idx');

  try {
    final response = await func<Map<String, dynamic>>(
      'delete_post',
      data: {'idx': idx},
      alertOnError: true,
    );

    // API가 에러를 반환한 경우 처리
    if (response['error'] != null) {
      final userMessage = response['message'] ?? '게시글 삭제에 실패했습니다.';
      debugLog('게시글 삭제 실패: ${response['error']} - $userMessage');

      showSafeErrorDialog(userMessage);
      throw Exception('게시글 삭제 실패: ${response['error']}');
    }

    return Post.fromJson(response);
  } catch (e) {
    debugLog('게시글 삭제 중 예외 발생: $e');
    rethrow;
  }
}

/// Create a comment
Future<Comment> createComment(RecordType data) async {
  /// check if data['idx_root'] exists. if not, show an error.
  final response = await func<Map<String, dynamic>>(
    'create_comment',
    data: data,
  );

  return Comment.fromJson(response);
}

Future<Comment> updateComment(RecordType data) async {
  final response = await func<Map<String, dynamic>>(
    'update_comment',
    data: data,
  );

  return Comment.fromJson(response);
}

Future<int> likePost(int idx) async {
  final response = await func<Map<String, dynamic>>(
    'like',
    data: {'idx': idx},
    alertOnError: false,
  );

  debugLog("response from like_func: $response");

  // Return the updated good count from the response
  return response['good'] ?? 0;
}

Future reportPost({
  required String type,
  required int idx,
  required String reason,
  bool debug = false,
  bool alertOnError = true,
}) async {
  final response = await func<Map<String, dynamic>>(
    'report',
    data: {'type': type, 'idx': idx, 'reason': reason},
    alertOnError: alertOnError,
    debug: debug,
  );
  return response;
}
