import 'package:philgo/api/api.service.dart';
import 'file_upload.model.dart';

/// 파일 업로드 서비스
///
/// ApiService.fileUpload() / ApiService.fileDelete()를 래핑하여
/// FileUploadModel로 변환해 반환한다.
class FileUploadService {
  FileUploadService._();

  /// 파일 업로드
  ///
  /// [filePath] 업로드할 로컬 파일 경로 (필수)
  /// [module] 모듈명 (선택, 예: 'company', 'post', 'user')
  /// [code] 세부 분류 (선택, 예: 'main_photo', 'gallery', 'profile_photo')
  /// [extraData] FormData에 추가할 임의 필드 (선택)
  /// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
  static Future<FileUploadModel> upload({
    required String filePath,
    String? module,
    String? code,
    Map<String, dynamic>? extraData,
    void Function(double progress)? onProgress,
  }) async {
    final json = await ApiService.fileUpload(
      filePath: filePath,
      module: module,
      code: code,
      extraData: extraData,
      onProgress: onProgress,
    );
    return FileUploadModel.fromJson(json);
  }

  /// 파일 삭제
  ///
  /// [idx] 삭제할 파일의 idx
  static Future<void> delete(int idx) async {
    await ApiService.fileDelete(idx);
  }
}
