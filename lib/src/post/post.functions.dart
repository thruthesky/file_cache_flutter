import 'dart:developer';

import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

List<String?> getEnvironmentalPostId(String? postId, String? category) {
  if (Config.isDevelopment) {
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

Future<PostList> getPosts({
  String? postId,
  String? category,
  bool has_image = false,
  int page = 1,
  int limit = 20,
}) async {
  // [postId, category] = getEnvironmentalPostId(postId, category);
  final res = await func(
    'post_list',
    data: {
      if (postId != null) 'post_id': postId,
      if (category != null) 'category': category,
      if (has_image) 'has_image': 'y',
      'page': page,
      'limit': limit,
    },
    debug: true,
  );
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

Future<List<Post>> getLatestByUser(String uid, {int limit = 10}) async {
  final res = await func<List<dynamic>>(
    'post.latest-by-user',
    data: {'uid': uid, 'limit': limit},
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

Future<PostList> getMyPosts({
  required int myId,
  int page = 1,
  int limit = 20,
}) async {
  final res = await func(
    'post_list',
    data: {'idx_member': myId, 'page': page, 'limit': limit},
    debug: true,
  );
  debugLog('getMyPosts: $res');
  return PostList.fromJson(res);
}

/// Get latest comments from all users
/// Returns a list of Comment objects
Future<List<Comment>> getLatestComments({int page = 1, int limit = 20}) async {
  final res = await func(
    'get_latest_comments',
    data: {'page': page, 'limit': limit},
    debug: true,
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
  final res = await func(
    'get_my_comments',
    data: {'page': page, 'limit': limit},
    debug: true,
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
