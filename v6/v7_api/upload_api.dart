import 'models/v7_upload_model.dart';
import 'v7_api.dart';

/// v7 업로드(Upload) API 래퍼 클래스
///
/// 파일 업로드/조회/삭제 관련 모든 v7 API 호출을 일관된 인터페이스로 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// /// 파일 업로드
/// final result = await UploadApi.upload(
///   filePath: '/path/to/receipt.jpg',
///   idxMember: '123',
///   module: 'receipt',
/// );
/// print(result['url']); // /uploads/123/unique_file.jpg
///
/// /// 내 전체 파일 목록 조회
/// final files = await UploadApi.myFiles();
/// for (final file in files) {
///   print('${file['name']} - ${file['url']}');
/// }
///
/// /// 파일 삭제
/// await UploadApi.delete(42);
/// ```
class UploadApi {
  UploadApi._();

  /// 파일 업로드
  ///
  /// API 엔드포인트: upload.upload (기본) 또는 method로 지정
  /// 인증: 필수
  /// v7apiFileUpload() 래퍼 — multipart/form-data로 파일 전송
  ///
  /// [filePath] 업로드할 로컬 파일 경로
  /// [idxMember] 회원번호
  /// [method] API method (기본: 'upload.upload', 영수증 분석: 'ai.analyzeReceipt')
  /// [module] 모듈명 (예: 'receipt', 'profile')
  /// [code] 코드 분류
  /// [extraData] FormData에 추가할 필드
  /// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
  /// [debug] 디버그 로깅
  ///
  /// 반환: 업로드 응답 Map (idx, name, size, type, url 등)
  static Future<V7UploadModel> upload({
    required String filePath,
    required String idxMember,
    String method = 'upload.upload',
    String? module,
    String? code,
    Map<String, dynamic>? extraData,
    void Function(double progress)? onProgress,
    bool debug = false,
  }) async {
    return await v7apiFileUpload(
      filePath: filePath,
      idxMember: idxMember,
      method: method,
      module: module,
      code: code,
      extraData: extraData,
      onProgress: onProgress,
      debug: debug,
    );
  }

  /// 파일 정보 단건 조회
  ///
  /// API 엔드포인트: upload.get
  /// 인증: 불필요 (공개 조회)
  ///
  /// [idx] 업로드 파일 고유번호
  /// 반환: 파일 정보 Map (idx, name, size, type, url, module, code, attached 등)
  static Future<Map<String, dynamic>> get(int idx) async {
    return await v7api('upload.get', data: {'idx': idx});
  }

  /// 내 파일 목록 조회 (페이지네이션)
  ///
  /// API 엔드포인트: upload.list
  /// 인증: 필수 (본인 파일만 조회)
  ///
  /// [limit] 최대 조회 수 (기본 100)
  /// [offset] 오프셋 (기본 0)
  /// 반환: 파일 정보 Map 리스트
  static Future<List<Map<String, dynamic>>> list({
    int? limit,
    int? offset,
  }) async {
    final result = await v7api('upload.list', data: {
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    final items = result['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// 내 전체 파일 목록 조회 (최대 2,000개)
  ///
  /// API 엔드포인트: upload.myFiles
  /// 인증: 필수 (본인 파일만 조회)
  /// 페이지네이션 없이 최신순으로 전체 반환
  ///
  /// 반환: 파일 정보 Map 리스트 (최대 2,000개)
  static Future<List<Map<String, dynamic>>> myFiles() async {
    final result = await v7api('upload.myFiles');
    final items = result['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  /// 파일 삭제
  ///
  /// API 엔드포인트: upload.delete
  /// 인증: 필수 (소유자 검증)
  ///
  /// [idx] 삭제할 파일 고유번호
  /// 반환: 삭제 성공 여부
  static Future<bool> delete(int idx) async {
    final result = await v7api('upload.delete', data: {'idx': idx});
    return result['data'] == true;
  }

  /// attached 상태 변경
  ///
  /// API 엔드포인트: upload.updateAttached
  /// 인증: 필수 (소유자 검증)
  ///
  /// [idx] 파일 고유번호
  /// [attached] 사용 여부 (0=미사용, 1=사용중)
  /// 반환: 변경 성공 여부
  static Future<bool> updateAttached(int idx, {required int attached}) async {
    final result = await v7api('upload.updateAttached', data: {
      'idx': idx,
      'attached': attached,
    });
    return result['data'] == true;
  }
}
