import 'package:philgo/app.config.dart';

// ---------------------------------------------------------------------------
// 파일 확장자 상수
// ---------------------------------------------------------------------------

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
  'avif',
];

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

const List<String> kAudioExtensions = [
  'mp3',
  'wav',
  'aac',
  'ogg',
  'flac',
  'm4a',
];

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

const List<String> kArchiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];

const List<String> kWebDataExtensions = [
  'xml',
  'json',
  'csv',
  'html',
  'css',
  'js',
];

const List<String> kAllKnownExtensions = [
  ...kImageExtensions,
  ...kVideoExtensions,
  ...kAudioExtensions,
  ...kDocumentExtensions,
  ...kArchiveExtensions,
  ...kWebDataExtensions,
];

// ---------------------------------------------------------------------------
// 미디어 타입 판별 유틸리티
// ---------------------------------------------------------------------------

enum MediaType { image, video, file }

/// URL에서 미디어 타입을 판별한다.
///
/// 이미지 확장자 → [MediaType.image]
/// 비디오 확장자 → [MediaType.video]
/// 기타 → [MediaType.file]
MediaType getMediaType(String? url) {
  if (url == null || url.isEmpty) return MediaType.file;

  final ext = getFileExtension(url);

  if (kImageExtensions.contains(ext)) return MediaType.image;
  if (kVideoExtensions.contains(ext)) return MediaType.video;

  return MediaType.file;
}

/// URL 또는 경로에서 파일 확장자 추출
///
/// kAllKnownExtensions 목록에서 매칭되는 확장자를 찾아 반환한다.
/// 없으면 빈 문자열을 반환한다.
///
/// Example:
/// ```dart
/// getFileExtension('https://example.com/image.jpg?size=large') // 'jpg'
/// getFileExtension('https://example.com/video.mp4#t=10')        // 'mp4'
/// getFileExtension('/path/to/document.pdf')                      // 'pdf'
/// getFileExtension('https://example.com/file')                   // ''
/// ```
String getFileExtension(String url) {
  final lower = url.toLowerCase();
  for (final ext in kAllKnownExtensions) {
    if (lower.contains('.$ext')) return ext;
  }
  return '';
}

/// URL 또는 경로에서 파일명 추출
///
/// Example:
/// ```dart
/// getFileName('https://example.com/uploads/photo.webp') // 'photo.webp'
/// ```
String getFileName(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  return path.split('/').last;
}

/// YouTube URL 에서 비디오 ID 추출
///
/// @deprecated 대신 `lib/youtube/youtube.service.dart`의 `getYoutubeVideoId()`를 사용하세요.
/// 이 함수는 watch?v=, youtu.be 형식만 지원합니다. 새 함수는 shorts, embed 등 6가지 형식을 모두 지원합니다.
@Deprecated('lib/youtube/youtube.service.dart의 getYoutubeVideoId()를 사용하세요')
String? getYouTubeVideoId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  return uri.queryParameters['v'];
}

/// 상대 URL → 절대 URL 변환
String toAbsoluteUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '${Config.v7BaseUrl}$url';
}
