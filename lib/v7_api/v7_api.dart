/// v7 API 핵심 함수
///
/// v7 서버(api.php)와 통신하는 핵심 함수들을 제공한다.
/// 웹과 동일하게 백엔드 서버에 업로드한다 (Firebase Storage 사용 금지).
///
/// - `v7api()`: JSON POST 일반 API 호출
/// - `v7apiFileUpload()`: multipart/form-data 파일 업로드 (백엔드 서버)
///
/// 모든 파일 업로드는 반드시 이 함수를 통해 백엔드 api.php에 업로드해야 한다.
/// Firebase Storage 직접 업로드는 절대로 사용하지 않는다.
library;

export 'package:philgo/api/api.service.dart' show ApiService, ApiException;

import 'package:philgo/api/api.service.dart';
import 'package:philgo/file/upload/file_upload.model.dart';

/// v7 일반 API 호출
///
/// v7 서버(api.php)에 JSON POST 요청을 보낸다.
/// Firebase ID Token을 자동으로 추가한다.
///
/// 사용 예시:
/// ```dart
/// final result = await v7api('user.me');
/// final posts = await v7api('post.list', data: {'post_id': 'freetalk', 'limit': 10});
/// ```
Future<Map<String, dynamic>> v7api(
  String method, {
  Map<String, dynamic>? data,
  bool debug = false,
}) async {
  return ApiService.instance.v7api(method, data: data, debug: debug);
}

/// v7 파일 업로드 — 백엔드 서버(api.php) 전용
///
/// 웹과 동일하게 백엔드 서버의 `upload.upload` API에 multipart/form-data로 업로드한다.
/// **Firebase Storage는 절대로 사용하지 않는다.**
///
/// [filePath] 업로드할 로컬 파일 경로 (필수)
/// [module]   모듈명 분류 (예: 'receipt', 'profile', 'post', 'company')
/// [code]     코드 분류 (모듈 내 세부 분류, 예: 'main_photo', 'gallery')
/// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
///
/// 반환값: [FileUploadModel] (서버의 uploads 테이블 데이터)
///
/// 사용 예시:
/// ```dart
/// final model = await v7apiFileUpload(
///   filePath: '/path/to/photo.jpg',
///   module: 'company',
///   code: 'main_photo',
///   onProgress: (p) => setState(() => progress = p),
/// );
/// print(model.url); // https://philgo.com/uploads/123/abc.webp
/// ```
Future<FileUploadModel> v7apiFileUpload({
  required String filePath,
  String? module,
  String? code,
  Map<String, dynamic>? extraData,
  void Function(double progress)? onProgress,
}) async {
  final json = await ApiService.instance.fileUpload(
    filePath: filePath,
    module: module,
    code: code,
    extraData: extraData,
    onProgress: onProgress,
  );
  return FileUploadModel.fromJson(json);
}
