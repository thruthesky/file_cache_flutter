import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 이 함수는 PhilGo PHP API 서버에 사용자의 Firebase ID Token 을 함께 실어서, POST 요청을 보낸다.
///
/// PhilGo API 로 데이터 송/수신을 할 때에 이 함수를 쓰면 된다.
///
/// This must be used on Client Side only.
/// This is not a hook. so, it can be used in any function.
///
/// @param url url to fetch
/// @param options options for the request
/// @returns API response
Future<T> philgoApi<T>(
  String action, {
  RecordType? data,
  bool debug = false,
  bool alertOnError = true,
  bool auth = false,
  Map<String, String>? headers,
}) async {
  // 기본 옵션 설정
  data = data ?? <String, dynamic>{};
  data['action'] = action;

  final url = Config.phpApiUrl;

  try {
    // 사용자 Firebase ID Token 을 전달
    if (auth) {
      await patchToken(data);
    }

    if (debug) {
      // queryParameters는 모든 값이 String이어야 하므로 변환
      final stringParams = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      log('GET URL: $url?${Uri(queryParameters: stringParams).query}');
    }

    // Create Dio instance
    final dio = Dio();

    // Override headers if provided
    if (headers != null) {
      dio.options.headers.addAll(headers);
    }

    // HTTP 요청
    final response = await dio.post(url, data: data);

    final responseData = response.data;
    Map<String, dynamic> json;

    if (responseData is Map<String, dynamic>) {
      json = responseData;
    } else if (responseData is List) {
      // If the response is a list, wrap it in a map with a key 'data'
      return responseData as T;
    } else if (responseData is String) {
      json = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Unexpected response data type: ${responseData.runtimeType}',
      );
    }

    // API 가 소프트 에러를 응답한 경우, Exception 을 throw 하지 않고, 데이터를 리턴한다.
    if (json['error'] != null) {
      return json as T;
    }

    // 에러 없음! 정상 응답! 성공!
    return json as T;
  } on DioException catch (dioError) {
    // ================================================================
    // 에러 발생 : Handle Dio-specific errors
    // ================================================================
    final data = dioError.response?.data;
    log('philgoApi() DioException: $data, $dioError');

    // ===============================================================
    // DioException의 error가 FormatException인 경우 source 출력
    // FormatException는 주로 JSON 파싱 에러 등에서 발생하며, 특히, 서버에서
    // PHP 에러가 발생 했을 가능성이 매우 높다.
    // ===============================================================
    if (dioError.error is FormatException) {
      final formatError = dioError.error as FormatException;

      // source를 텍스트로 변환하여 출력
      String sourceText = '';
      if (formatError.source != null) {
        if (formatError.source is List<int>) {
          // List<int>인 경우 UTF-8로 디코딩 시도
          try {
            sourceText = utf8.decode(formatError.source as List<int>);
          } catch (e) {
            // 디코딩 실패 시 원본 데이터 출력
            sourceText = 'Raw bytes: ${formatError.source}';
          }
        } else if (formatError.source is String) {
          // 이미 String인 경우
          sourceText = formatError.source as String;
        } else {
          // 기타 타입인 경우
          sourceText = formatError.source.toString();
        }
      }

      log('FormatException source (as text): $sourceText');
      log('FormatException message: ${formatError.message}');
      log('FormatException offset: ${formatError.offset}');

      // 에러 다이얼로그 표시
      if (alertOnError) {
        showSafeErrorDialog('서버 응답을 처리하는 중에 오류가 발생했습니다.\n\n$sourceText');
      }
      rethrow;
    }
    // ================================================================
    // 여기까지 도달했다면, DioException이지만 FormatException은 아니다.
    // 즉, JSON 파싱 에러는 아닐 가능성이 높고, PHP 에러가 아닐 가능성이 높다.
    // 즉, PHP 가 {'error': '...', 'message': '...'} 형태로 응답했을 가능성이 높다.
    // ================================================================
    // DioException 자체의 상세 정보 출력
    log('DioException type: ${dioError.type}');
    log('DioException message: ${dioError.message}');
    log('DioException response: ${dioError.response?.data}');
    log('DioException requestOptions: ${dioError.requestOptions.uri}');

    final errorPrefix = '에러: ';
    String serverMessage = '';

    try {
      // 서버 에러 메시지 파싱 시도
      final responseData = dioError.response?.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) {
          serverMessage =
              '${responseData['message']} (코드: ${responseData['error'] ?? 'UNKNOWN'})';
        } else if (responseData['error'] != null) {
          serverMessage = '(코드: ${responseData['error']}) No specific message.';
        } else {
          serverMessage = responseData.toString();
        }
      } else if (responseData is String) {
        try {
          final errorJson = jsonDecode(responseData) as Map<String, dynamic>;
          if (errorJson['message'] != null) {
            serverMessage =
                '${errorJson['message']} (코드: ${errorJson['error'] ?? 'UNKNOWN'})';
          } else if (errorJson['error'] != null) {
            serverMessage = '(코드: ${errorJson['error']}) No specific message.';
          } else {
            serverMessage = responseData;
          }
        } catch (e) {
          // JSON 파싱 실패 시 원본 텍스트 사용
          serverMessage = responseData;
        }
      } else {
        serverMessage = responseData.toString();
      }
    } catch (e) {
      serverMessage = 'Failed to read error response body.';
    }

    final errorMessage =
        '$errorPrefix ${httpStatusCode(dioError.response?.statusCode ?? 0)} ${dioError.response?.statusMessage ?? ''} $serverMessage';
    if (alertOnError) {
      showSafeErrorDialog('서버와 통신하는 중에 오류가 발생했습니다.\n\n$errorMessage');
    }
    throw Exception(errorMessage);
  } catch (e) {
    debugLog('philgoApi() 에러: catch(e) $e');
    // 요청에서 에러가 발생한 경우
    if (alertOnError) {
      debugLog('ALERT: url: $url');
      debugLog('ALERT: data: $data');
      debugLog('ALERT: error message: ${e.toString()}');
      showSafeErrorDialog('서버와 통신하는 중에 오류가 발생했습니다.\n\n${e.toString()}');
    }
    rethrow; // re-throw the error to be handled by the caller
  }
}

/// Add firebase id token to data
Future<String?> patchToken(RecordType data) async {
  final auth = fb_auth.FirebaseAuth.instance;
  if (auth.currentUser == null) {
    return null;
  }

  try {
    final token = await auth.currentUser!.getIdToken();
    data['token'] = token;
    return token;
  } catch (e) {
    debugLog('Error getting Firebase ID token: $e');
    return null;
  }
}

/// HTTP status code messages
String httpStatusCode(int statusCode) {
  switch (statusCode) {
    case 200:
      return 'OK';
    case 201:
      return 'Created';
    case 400:
      return 'Bad Request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'Not Found';
    case 500:
      return 'Internal Server Error';
    default:
      return 'HTTP $statusCode';
  }
}

/// 현재 로그인한 사용자 정보 가져오기
///
/// API 엔드포인트: user.my
/// 인증 필요: 예 (Firebase ID Token 필수)
///
/// 이 함수는 현재 로그인한 사용자의 정보를 가져옵니다.
/// Firebase Authentication으로 로그인된 상태여야 하며,
/// 자동으로 Firebase ID Token을 포함하여 서버에 요청합니다.
///
/// ```
Future<User> philgoApiUserMy() async {
  // user.my 엔드포인트 호출 - 인증 필수
  final response = await philgoApi('user.my', auth: true);

  // 성공적으로 사용자 정보 반환
  return User.fromJson(response);
}

Future<User> philgoApiUserVerify() async {
  // user.verify 엔드포인트 호출 - 인증 필수
  final response = await philgoApi('user.verify', auth: true);

  // 성공적으로 사용자 정보 반환
  return User.fromJson(response);
}

Future<User> philgoApiUserUpdate(Map<String, dynamic> userData) async {
  // user.update 엔드포인트 호출 - 인증 필수
  final response = await philgoApi('user.update', data: userData, auth: true);
  return User.fromJson(response);
}

/// Create a post with PhilGo v6 API
///
/// It validates and display error dialog if validation fails.
///
/// Returns [Post] object.
Future<Post> philgoApiCreatePost(RecordType data) async {
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

  // ========== 2. 디버깅 정보 로깅 (개발 시 유용) ==========
  debugLog('게시글 작성 시작:');
  debugLog('  - post_id: ${cleanedData['post_id']}'); // post_id 로깅
  debugLog('  - 제목: ${cleanedData['subject']}'); // subject 필드 사용
  debugLog('  - 카테고리: ${cleanedData['category'] ?? '(미지정)'}'); // 카테고리는 옵션
  debugLog('  - 내용 길이: ${cleanedData['content'].toString().length}자');

  // ========== 3. API 호출 ==========
  try {
    // post.create 엔드포인트 호출
    // auth: true로 Firebase ID Token 자동 포함
    final response = await philgoApi<Map<String, dynamic>>(
      'post.create',
      data: cleanedData,
      auth: true, // 인증 필수 - 게시글 작성자 확인
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
Future<Post> philgoApiUpdatePost(RecordType data) async {
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
    final response = await philgoApi<Map<String, dynamic>>(
      'post.update',
      data: cleanedData,
      auth: true, // 인증 필수 - 게시글 소유자 확인
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

/// Create a comment
Future<Comment> philgoApiCreateComment(RecordType data) async {
  /// check if data['idx_root'] exists. if not, show an error.

  ///
  final response = await philgoApi<Map<String, dynamic>>(
    'comment.create',
    data: data,
    auth: true, // 인증 필수 - 게시글 작성자 확인
    alertOnError: true, // 에러 시 자동으로 다이얼로그 표시
  );

  return Comment.fromJson(response);
}

Future<Comment> philgoApiUpdateComment(RecordType data) async {
  final response = await philgoApi<Map<String, dynamic>>(
    'comment.update',
    data: data,
    auth: true, // 인증 필수 - 게시글 작성자 확인
    alertOnError: true, // 에러 시 자동으로 다이얼로그 표시
  );

  return Comment.fromJson(response);
}

/// 파일을 PhilGo 파일 서버에 업로드합니다.
///
/// [filePath] 업로드할 파일의 경로
/// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
/// [deleteFile] 기존 파일 삭제 URL (옵션)
/// [qrCode] QR 코드 스캔 여부 (기본값: false)
///
/// 반환값: 업로드된 파일 정보를 담은 FileUploadResponse 객체
///   - url: 업로드된 파일의 URL
///   - qr_code: QR 코드가 있는 경우 디코딩된 문자열
///   - deleted: 기존 파일 삭제 여부
Future<FileUploadResponse?> philgoApiFileUpload(
  String filePath, {
  void Function(double progress)? onProgress,
  String? deleteFile,
  bool qrCode = false,
}) async {
  try {
    // Dio 인스턴스 생성
    final dio = Dio();

    // 파일 객체 생성
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    // FormData 생성
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'uid': fb_auth.FirebaseAuth.instance.currentUser?.uid,
      if (deleteFile != null) 'deleteFile': deleteFile,
      if (qrCode) 'qrCode': 'true',
    });

    // 파일 서버 URL
    final uploadUrl = '${Config.fileServerUrl}upload.php';

    // 파일 업로드 요청
    final response = await dio.post(
      uploadUrl,
      data: formData,
      onSendProgress: (sent, total) {
        if (onProgress != null) {
          final progress = sent / total;
          onProgress(progress);
        }
      },
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );

    // 응답 처리
    if (response.statusCode == 200) {
      final responseData = response.data;
      Map<String, dynamic> json;

      // 응답이 문자열인 경우 JSON 파싱
      if (responseData is String) {
        try {
          json = jsonDecode(responseData) as Map<String, dynamic>;
        } catch (e) {
          // JSON 파싱 실패 시, URL 문자열로 간주
          json = {'url': responseData};
        }
      } else if (responseData is Map<String, dynamic>) {
        json = responseData;
      } else {
        // 예상치 못한 응답 형식
        debugLog('파일 업로드 - 예상치 못한 응답 형식: ${responseData.runtimeType}');
        return null;
      }

      // 에러 체크
      if (json['error'] != null) {
        debugLog('파일 업로드 오류: ${json['error']} - ${json['message']}');
        throw Exception('파일 업로드 실패: ${json['message'] ?? json['error']}');
      }

      // FileUploadResponse 객체 생성 및 반환
      final philgoFile = FileUploadResponse.fromJson(json);
      debugLog('philgo upload response: $philgoFile');
      return philgoFile;
    } else {
      debugLog('파일 업로드 실패 - HTTP ${response.statusCode}');
      return null;
    }
  } on DioException catch (e) {
    debugLog('파일 업로드 DioException: ${e.message}');
    if (e.response != null) {
      debugLog('응답 데이터: ${e.response?.data}');
    }
    rethrow;
  } catch (e) {
    debugLog('파일 업로드 오류: $e');
    rethrow;
  }
}

/// 파일을 PhilGo 파일 서버에서 삭제합니다.
///
/// [fileUrl] 삭제할 파일의 URL
Future<void> philgoApiFileDelete(String? fileUrl) async {
  // URL 유효성 검사
  if (fileUrl == null || fileUrl.isEmpty) {
    throw Exception('URL이 비어있습니다');
  }

  try {
    // Dio 인스턴스 생성
    final dio = Dio();

    // Firebase 토큰 가져오기
    final auth = fb_auth.FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    // 파일 삭제 URL
    final deleteUrl = '${Config.fileServerUrl}delete.php';

    // 디버깅용 요청 정보 로깅
    debugLog('파일 삭제 요청:');
    debugLog('  - URL: $deleteUrl');
    debugLog('  - 삭제할 파일: $fileUrl');
    debugLog('  - UID 포함: ${uid != null ? "예: $uid" : "아니오"}');

    // 요청 데이터 준비
    // PHP의 $_REQUEST/$_POST로 읽을 수 있도록 form-urlencoded 형식으로 전송
    final data = {'url': fileUrl, 'uid': uid};
    debugLog('  data: $data');

    // 삭제 요청
    // contentType을 명시하지 않으면 Dio가 자동으로 application/x-www-form-urlencoded 사용
    // 또는 명시적으로 설정 가능: Options(contentType: Headers.formUrlEncodedContentType)
    final response = await dio.post(
      deleteUrl,
      data: data,
      // PHP $_REQUEST/$_POST로 읽기 위해 json이 아닌 form-urlencoded 사용
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    // 응답 상태 확인
    if (response.statusCode != 200) {
      debugLog('파일 삭제 실패 - HTTP ${response.statusCode}');
      debugLog('응답 데이터: ${response.data}');
      throw Exception('파일 삭제 실패: HTTP ${response.statusCode}');
    }

    // 응답 데이터 검사 (서버가 에러 응답을 200 OK로 보낼 수도 있음)
    if (response.data != null) {
      debugLog('파일 삭제 응답: ${response.data}');

      // 응답이 JSON인 경우 에러 체크
      if (response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        if (json['error'] != null) {
          final errorMsg = '파일 삭제 실패: ${json['message'] ?? json['error']}';
          debugLog(errorMsg);
          throw Exception(errorMsg);
        }
      }
    }

    debugLog('파일 삭제 성공: $fileUrl');
  } on DioException catch (dioError) {
    // DioException 상세 로깅
    debugLog('=== DioException 발생 ===');
    debugLog('에러 타입: ${dioError.type}');
    debugLog('에러 메시지: ${dioError.message}');
    debugLog('요청 URL: ${dioError.requestOptions.uri}');
    debugLog('요청 메서드: ${dioError.requestOptions.method}');
    debugLog('요청 데이터: ${dioError.requestOptions.data}');

    // 응답 정보 로깅 (있는 경우)
    if (dioError.response != null) {
      debugLog('응답 상태 코드: ${dioError.response?.statusCode}');
      debugLog('응답 상태 메시지: ${dioError.response?.statusMessage}');
      debugLog('응답 헤더: ${dioError.response?.headers}');
      debugLog('응답 데이터: ${dioError.response?.data}');

      // 응답 데이터 파싱 시도
      try {
        final responseData = dioError.response?.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['error'] != null) {
            debugLog('서버 에러 코드: ${responseData['error']}');
            debugLog('서버 에러 메시지: ${responseData['message'] ?? "없음"}');
          }
        } else if (responseData is String) {
          debugLog('서버 응답 (문자열): $responseData');
        }
      } catch (e) {
        debugLog('응답 데이터 파싱 실패: $e');
      }
    } else {
      debugLog('응답 없음 (네트워크 오류 또는 타임아웃 가능성)');
    }

    // 상세 에러 메시지 생성
    String detailedError = '파일 삭제 실패: ';
    if (dioError.response != null) {
      detailedError +=
          'HTTP ${dioError.response?.statusCode} - ${dioError.response?.statusMessage ?? ""}';
      if (dioError.response?.data != null) {
        detailedError += '\n응답: ${dioError.response?.data}';
      }
    } else {
      detailedError += dioError.message ?? '알 수 없는 네트워크 오류';
    }

    debugLog('=== DioException 로깅 종료 ===');
    throw Exception(detailedError);
  } catch (e) {
    // 기타 예외 처리
    debugLog('파일 삭제 중 예기치 않은 오류: $e');
    debugLog('오류 타입: ${e.runtimeType}');
    rethrow;
  }
}

Future<String> philgoApiGetAdminUserUid() async {
  // app.admins
  final response = await philgoApi('app.admins');

  final chatAdmin = response['chat_admin'] as String?;
  log('Admin user uid: $chatAdmin', name: 'Got admin user uid from philgo API');

  // 성공적으로 사용자 정보 반환
  return chatAdmin ?? '';
}
