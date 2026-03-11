import 'package:philgo/api/api.service.dart';
import 'package:philgo/file_upload/file_upload.model.dart';

/// 파일 업로드 서비스
///
/// ApiService.fileUpload()를 래핑하여 FileUploadModel을 반환한다.
class FileUploadService {
  FileUploadService._();

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
}
