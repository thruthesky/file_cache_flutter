import 'dart:developer';

import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
/// final posts = await getPosts();
///
/// // 특정 게시판에서 조회
/// final freeTalkPosts = await getPosts(postId: 'freetalk');
///
/// // 이미지가 있는 글만 조회 (갤러리용)
/// final galleryPosts = await getPosts(postId: 'gallery', has_image: true);
///
/// // 페이지네이션 (두 번째 페이지, 한 페이지에 30개)
/// final nextPage = await getPosts(postId: 'notice', page: 2, limit: 30);
///
/// // 카테고리 필터링
/// final filteredPosts = await getPosts(postId: 'qna', category: 'flutter');
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
///
/// ## 주의사항
///
/// - 개발 환경([PhilgoConfig.isDevelopment])에서는 [getEnvironmentalPostId]를
///   통해 테스트용 게시판 ID로 대체될 수 있음 (현재 주석 처리됨)
/// - 네트워크 오류 시 예외가 발생할 수 있으므로 try-catch로 감싸서 사용 권장
Future<PostList> getPosts({
  String? postId,
  String? category,
  bool has_image = false,
  int page = 1,
  int limit = 20,
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
      // 페이지네이션 파라미터
      'page': page,
      'limit': limit,
    },
    // debug: true, // 디버그 모드 활성화 시 요청/응답 로깅
  );

  // API 응답을 PostList 객체로 변환하여 반환
  // debugLog('getPosts: $res');
  return PostList.fromJson(res);
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
  debugLog('getPosts: $res');
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
      'create_post_func',
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
      'update_post_func',
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
      'delete_post_func',
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
    'create_comment_func',
    data: data,
  );

  return Comment.fromJson(response);
}

Future<Comment> updateComment(RecordType data) async {
  final response = await func<Map<String, dynamic>>(
    'update_comment_func',
    data: data,
  );

  return Comment.fromJson(response);
}

/// Get latest comments from all users
/// Returns a list of Comment objects
Future<List<Comment>> getLatestComments({int page = 1, int limit = 20}) async {
  final res = await func(
    'get_latest_comments',
    data: {'page': page, 'limit': limit},
    // debug: true,
  );

  debugLog("GET LATEST COMMENTS ----------------> $res");

  final comments = res
      .map((item) => Comment.fromJson(item as Map<String, dynamic>))
      .toList();
  debugLog('getLatestComments: Parsed ${comments.length} comments');
  return comments;
}

/// Get comments by user
/// Returns a list of Comment objects
Future<List<Comment>> getMyComments({int page = 1, int limit = 20}) async {
  final res = await func<List<dynamic>>(
    'get_my_comments',
    data: {'page': page, 'limit': limit},
    // debug: true,
  );

  debugLog("GET MY COMMENTS ----------------> $res");

  final comments = res
      .map((item) => Comment.fromJson(item as Map<String, dynamic>))
      .toList();
  debugLog('getMyComments: Parsed ${comments.length} comments');
  return comments;
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
