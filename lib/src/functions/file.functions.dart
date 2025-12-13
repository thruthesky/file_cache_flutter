/// File preview type enumeration
/// Used to determine how to render the preview based on file type
enum UploadFileType {
  /// Image files (jpg, jpeg, png, gif, webp, bmp)
  image,

  /// Video files (mp4, mov, avi, mkv, webm, flv)
  video,

  /// Other files (pdf, doc, txt, etc.)
  file,
}

// ============================================================================
// 파일 확장자 상수 (File Extension Constants)
// ============================================================================

/// 이미지 파일 확장자 목록 (Image file extensions)
/// jpeg를 jpg보다 먼저 배치하여 정확한 매칭 보장
const List<String> kImageExtensions = [
  'jpeg',
  'jpg',
  'gif',
  'png',
  'webp',
  'bmp',
  'svg',
  'ico',
  'heic',
  'heif',
];

/// 비디오 파일 확장자 목록 (Video file extensions)
const List<String> kVideoExtensions = [
  'mp4',
  'mov',
  'avi',
  'mkv',
  'webm',
  'flv',
  'wmv',
  'm4v',
];

/// 오디오 파일 확장자 목록 (Audio file extensions)
const List<String> kAudioExtensions = [
  'mp3',
  'wav',
  'aac',
  'ogg',
  'flac',
  'm4a',
];

/// 문서 파일 확장자 목록 (Document file extensions)
/// docx/xlsx/pptx를 doc/xls/ppt보다 먼저 배치
const List<String> kDocumentExtensions = [
  'pdf',
  'docx',
  'doc',
  'xlsx',
  'xls',
  'pptx',
  'ppt',
  'txt',
  'rtf',
];

/// 압축 파일 확장자 목록 (Archive file extensions)
const List<String> kArchiveExtensions = [
  'zip',
  'rar',
  '7z',
  'tar',
  'gz',
];

/// 웹/데이터 파일 확장자 목록 (Web/Data file extensions)
const List<String> kWebDataExtensions = [
  'xml',
  'json',
  'csv',
  'html',
  'css',
  'js',
];

/// 모든 알려진 파일 확장자 목록 (All known file extensions)
/// getFileExtension() 함수에서 사용
const List<String> kAllKnownExtensions = [
  ...kImageExtensions,
  ...kVideoExtensions,
  ...kAudioExtensions,
  ...kDocumentExtensions,
  ...kArchiveExtensions,
  ...kWebDataExtensions,
];

/// Gets the file extension from a path or URL
///
/// Searches for well-known file extensions in the given path string.
/// Returns the extension in lowercase without the dot.
/// Uses direct string matching for safety and reliability.
///
/// Example:
/// ```dart
/// getFileExtension('https://example.com/image.jpg?size=large') // Returns: 'jpg'
/// getFileExtension('https://example.com/video.mp4#t=10') // Returns: 'mp4'
/// getFileExtension('/path/to/document.pdf') // Returns: 'pdf'
/// getFileExtension('https://example.com/file') // Returns: ''
/// ```
String getFileExtension(String path) {
  // 경로를 소문자로 변환하여 대소문자 구분 없이 비교
  final lowerPath = path.toLowerCase();

  // 각 확장자가 path에 '.확장자' 형태로 존재하는지 확인
  // Check if the path contains each extension in '.ext' format
  for (final ext in kAllKnownExtensions) {
    if (lowerPath.contains('.$ext')) {
      return ext;
    }
  }

  return '';
}

/// Detects the file type based on the URL extension
///
/// Returns [FileType] to determine the appropriate file handling or rendering.
/// Supports common image, video, and file extensions.
///
/// Example:
/// ```dart
/// detectFileType('https://example.com/photo.jpg') // Returns: FileType.image
/// detectFileType('https://example.com/video.mp4') // Returns: FileType.video
/// detectFileType('https://example.com/document.pdf') // Returns: FileType.file
/// ```
UploadFileType detectFileType(String path) {
  final extension = getFileExtension(path);

  // 이미지 확장자 확인 (Check for image extensions)
  if (kImageExtensions.contains(extension)) {
    return UploadFileType.image;
  }

  // 비디오 확장자 확인 (Check for video extensions)
  if (kVideoExtensions.contains(extension)) {
    return UploadFileType.video;
  }

  // PhilGo v4 이미지 파일 확인 (Check for PhilGo v4 image files)
  if (isOldImageFile(path)) {
    return UploadFileType.image;
  }

  // 기타 파일 (Default to file for everything else)
  return UploadFileType.file;
}

/// PhilGo v4 업로드 파일인지 확인하는 함수
///
/// PhilGo v4에서 업로드된 파일은 7자리 숫자로 된 파일명을 가집니다.
/// 이 함수는 주어진 경로가 v4 업로드 파일인지 확인합니다.
///
/// [path] - 확인할 파일 경로 또는 URL
///
/// Returns `true` if the filename is a PhilGo v4 uploaded file (7-digit numeric name).
///
/// Example:
/// ```dart
/// isOldImageFile('https://file.philgo.com/data/upload/5/1234567?abc=def') // Returns: true
/// isOldImageFile('https://file.philgo.com/data/upload/5/1234567') // Returns: true
/// isOldImageFile('https://file.philgo.com/data/upload/3/283626') // Returns: false (6자리)
/// isOldImageFile('https://example.com/image.jpg') // Returns: false
/// ```
bool isOldImageFile(String path) {
  // URL 파라미터 제거 (? 또는 # 이후 부분 제거)
  // Remove URL parameters (everything after ? or #)
  final cleanPath = path.replaceAll(RegExp(r'[?#].*$'), '');

  // basename 추출 (경로의 마지막 부분)
  // Extract basename (last part of the path)
  final basename = cleanPath.split('/').last;

  // v4 이미지 파일: 정확히 7자리이고 숫자로만 구성된 경우
  // PhilGo v4 file: exactly 7 characters and all numeric
  if (basename.length == 7 && RegExp(r'^\d+$').hasMatch(basename)) {
    return true;
  }

  return false;
}
