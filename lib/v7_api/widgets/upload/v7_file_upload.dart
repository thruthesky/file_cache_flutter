/// V7FileUpload 위젯
///
/// v7 시스템용 파일 업로드 위젯. 웹과 동일하게 백엔드 서버(api.php)에 업로드한다.
/// Firebase Storage는 사용하지 않는다.
///
/// 내부적으로 `lib/file/upload/widgets/file_upload.dart`의 `FileUpload` 위젯을 사용하며,
/// v7_api 경로에서 동일한 인터페이스로 접근할 수 있도록 타입 별칭을 제공한다.
///
/// 사용 예시:
/// ```dart
/// import 'package:philgo/v7_api/widgets/upload/v7_file_upload.dart';
///
/// V7FileUpload(
///   module: 'company',
///   code: 'main_photo',
///   camera: true,
///   gallery: true,
///   onUploaded: (model) {
///     setState(() => photoUrl = model.url);
///   },
///   child: Icon(Icons.camera_alt),
/// )
/// ```
library;

export 'package:philgo/file/upload/widgets/file_upload.dart';
export 'package:philgo/file/upload/file_upload.model.dart';

// V7FileUpload는 FileUpload의 타입 별칭이다.
// 웹의 v7apiUpload()와 동일하게 백엔드 서버(api.php)에 업로드한다.
import 'package:philgo/file/upload/widgets/file_upload.dart';
typedef V7FileUpload = FileUpload;
