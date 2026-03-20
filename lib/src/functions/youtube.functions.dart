// YouTube 관련 유틸리티 함수
//
// 이 파일은 텍스트에서 YouTube URL을 추출하고, Video ID를 파싱하며,
// Shorts와 일반 비디오를 구분하는 함수들을 제공합니다.
//
// PHP의 youtube.functions.php를 Dart로 변환한 구현입니다.
// 참조: .claude/skills/philgo-skill/references/philgo-youtube.md

// 지원하는 YouTube URL 형식:
// - https://www.youtube.com/watch?v=VIDEO_ID
// - https://youtu.be/VIDEO_ID
// - https://www.youtube.com/shorts/VIDEO_ID
// - https://m.youtube.com/watch?v=VIDEO_ID
// - https://www.youtube.com/embed/VIDEO_ID
// - //www.youtube.com/embed/VIDEO_ID (프로토콜 상대 URL - HTML iframe에서 사용)

/// YouTube URL 정보를 담는 모델 클래스
class YoutubeUrlInfo {
  /// 원본 URL
  final String originalUrl;

  /// 추출된 Video ID
  final String videoId;

  /// Shorts 여부 (Shorts는 세로 비율 9:16 사용)
  final bool isShorts;

  /// 시작 시간 (초 단위, 없으면 null)
  final int? startTime;

  const YoutubeUrlInfo({
    required this.originalUrl,
    required this.videoId,
    required this.isShorts,
    this.startTime,
  });

  /// embed URL로 변환 (iframe에서 사용)
  String get embedUrl {
    String url = 'https://www.youtube.com/embed/$videoId';
    if (startTime != null && startTime! > 0) {
      url += '?start=$startTime';
    }
    return url;
  }

  /// YouTube 썸네일 이미지 URL을 반환
  ///
  /// 썸네일 품질 우선순위:
  /// 1. maxresdefault (1920x1080) - 최고 품질
  /// 2. sddefault (640x480) - 표준 품질
  /// 3. hqdefault (480x360) - 고품질
  /// 4. mqdefault (320x180) - 중간 품질
  /// 5. default (120x90) - 기본 품질
  ///
  /// 대부분의 비디오는 maxresdefault를 지원하지만, 없는 경우 hqdefault 사용 권장
  String getThumbnailUrl({String quality = 'hqdefault'}) {
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  @override
  String toString() =>
      'YoutubeUrlInfo(videoId: $videoId, isShorts: $isShorts, startTime: $startTime)';
}

/// 텍스트에서 모든 형태의 YouTube URL을 추출하는 함수
///
/// [text] - 입력 문자열
/// [strict] - true인 경우 video ID가 정확히 11자리인지 검증 (기본값: false)
///
/// 반환값: 추출된 YouTube URL 배열. URL이 없으면 빈 리스트 반환.
///
/// 예시:
/// ```dart
/// final urls = extractYoutubeUrls("영상 보세요: https://youtu.be/abc123def45 그리고 https://youtube.com/shorts/xyz789abc12");
/// // 결과: ['https://youtu.be/abc123def45', 'https://youtube.com/shorts/xyz789abc12']
/// ```
List<String> extractYoutubeUrls(String text, {bool strict = false}) {
  if (text.isEmpty) return [];

  // YouTube URL 패턴 정규표현식
  // 지원 형식:
  // - youtube.com/watch?v=VIDEO_ID
  // - youtu.be/VIDEO_ID
  // - youtube.com/shorts/VIDEO_ID
  // - youtube.com/embed/VIDEO_ID
  // - m.youtube.com/watch?v=VIDEO_ID
  // - //www.youtube.com/embed/VIDEO_ID (프로토콜 상대 URL)
  final RegExp pattern;

  if (strict) {
    // 엄격 모드: video ID가 정확히 11자리여야 함
    // (?:https?:)?// 패턴으로 http://, https://, // 모두 매칭
    pattern = RegExp(
      r'(?:https?:)?//(?:www\.|m\.)?(?:youtube\.com/(?:watch\?(?:[^&\s]*&)*v=[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-])(?:&[^&\s]*)*|embed/[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-])|shorts/[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-]))|youtu\.be/[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-])(?:\?[^\s]*)?)',
      caseSensitive: false,
    );
  } else {
    // 유연 모드: video ID가 1자리 이상이면 됨
    // (?:https?:)?// 패턴으로 http://, https://, // 모두 매칭
    pattern = RegExp(
      r'(?:https?:)?//(?:www\.|m\.)?(?:youtube\.com/(?:watch\?(?:[^&\s]*&)*v=[a-zA-Z0-9_-]+(?:&[^&\s]*)*|embed/[a-zA-Z0-9_-]+|shorts/[a-zA-Z0-9_-]+)|youtu\.be/[a-zA-Z0-9_-]+(?:\?[^\s]*)?)',
      caseSensitive: false,
    );
  }

  // 모든 매칭 찾기
  final matches = pattern.allMatches(text);
  final urls = <String>[];

  for (final match in matches) {
    String url = match.group(0) ?? '';

    // URL 끝에서 불필요한 문자들 제거 (줄바꿈, 특수문자 등)
    // 정규표현식: 줄바꿈, 탭, 괄호, 따옴표, 백슬래시, 중괄호 등 제거
    url = url.replaceAll(RegExp(r'[\r\n\t\f\v\)\]">\}\\]+$'), '');
    url = url.replaceAll(RegExp("[']+\$"), '');
    url = url.trim();

    if (url.isNotEmpty && !urls.contains(url)) {
      urls.add(url);
    }
  }

  return urls;
}

/// YouTube URL에서 Video ID를 추출하는 함수
///
/// [url] - YouTube URL
///
/// 반환값: Video ID 또는 null (추출 실패 시)
///
/// 예시:
/// ```dart
/// getYoutubeVideoId("https://youtu.be/dQw4w9WgXcQ"); // "dQw4w9WgXcQ"
/// getYoutubeVideoId("https://www.youtube.com/watch?v=dQw4w9WgXcQ"); // "dQw4w9WgXcQ"
/// getYoutubeVideoId("https://www.youtube.com/shorts/abc123def45"); // "abc123def45"
/// getYoutubeVideoId("//www.youtube.com/embed/VIDEO_ID"); // "VIDEO_ID"
/// ```
String? getYoutubeVideoId(String url) {
  if (url.isEmpty) return null;

  // 프로토콜 상대 URL 처리 (//www.youtube.com/... -> https://www.youtube.com/...)
  String normalizedUrl = url;
  if (url.startsWith('//')) {
    normalizedUrl = 'https:$url';
  }

  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  final path = uri.path;

  // youtu.be 단축 URL 처리
  // 형식: https://youtu.be/VIDEO_ID
  if (host == 'youtu.be' || host == 'www.youtu.be') {
    final videoId = path.replaceFirst('/', '');
    return videoId.isNotEmpty ? videoId : null;
  }

  // youtube.com 도메인 처리
  if (host.contains('youtube.com')) {
    // embed URL 처리
    // 형식: https://www.youtube.com/embed/VIDEO_ID
    if (path.startsWith('/embed/')) {
      final videoId = path.substring(7); // '/embed/' 제거
      return videoId.isNotEmpty ? videoId : null;
    }

    // shorts URL 처리
    // 형식: https://www.youtube.com/shorts/VIDEO_ID
    if (path.startsWith('/shorts/')) {
      String videoId = path.substring(8); // '/shorts/' 제거
      videoId = videoId.replaceAll(RegExp(r'^/|/$'), ''); // 앞뒤 슬래시 제거
      return videoId.isNotEmpty ? videoId : null;
    }

    // 일반 watch URL 처리
    // 형식: https://www.youtube.com/watch?v=VIDEO_ID
    final queryParams = uri.queryParameters;
    if (queryParams.containsKey('v')) {
      return queryParams['v'];
    }
  }

  return null;
}

/// YouTube Shorts URL인지 확인하는 함수
///
/// [url] - YouTube URL
///
/// 반환값: Shorts이면 true, 아니면 false
///
/// 예시:
/// ```dart
/// isYoutubeShorts("https://youtube.com/shorts/abc123"); // true
/// isYoutubeShorts("https://youtube.com/watch?v=abc123"); // false
/// ```
bool isYoutubeShorts(String url) {
  if (url.isEmpty) return false;

  // YouTube Shorts URL 패턴
  // - https://www.youtube.com/shorts/VIDEO_ID
  // - https://youtube.com/shorts/VIDEO_ID
  // - https://m.youtube.com/shorts/VIDEO_ID
  final pattern = RegExp(
    r'youtube\.[a-z]{2,}(?:\.[a-z]{2,})?(?::\d+)?/shorts/',
    caseSensitive: false,
  );

  return pattern.hasMatch(url);
}

/// YouTube URL인지 확인하는 함수
///
/// [url] - 확인할 URL
///
/// 반환값: YouTube URL이면 true, 아니면 false
bool isYoutubeUrl(String url) {
  if (url.isEmpty) return false;

  final pattern = RegExp(
    r'(?:youtube\.[a-z]{2,}(?:\.[a-z]{2,})?(?::\d+)?/(watch\?v=|embed/|shorts/)|youtu\.be(?::\d+)?/)',
    caseSensitive: false,
  );

  return pattern.hasMatch(url);
}

/// YouTube 시간 형식을 초 단위로 변환하는 함수
///
/// 지원 형식:
/// - 123 -> 123 (이미 초 단위)
/// - 1m30s -> 90
/// - 1h2m3s -> 3723
///
/// [time] - 시간 문자열
///
/// 반환값: 초 단위 정수
int parseYoutubeTime(String time) {
  // 이미 숫자인 경우
  final numericValue = int.tryParse(time);
  if (numericValue != null) {
    return numericValue;
  }

  int seconds = 0;
  final pattern = RegExp(r'(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?');
  final match = pattern.firstMatch(time);

  if (match != null) {
    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final secs = int.tryParse(match.group(3) ?? '') ?? 0;
    seconds = (hours * 3600) + (minutes * 60) + secs;
  }

  return seconds;
}

/// 텍스트에서 YouTube URL을 추출하고 상세 정보를 반환하는 함수
///
/// [text] - 입력 문자열
/// [strict] - true인 경우 video ID가 정확히 11자리인지 검증 (기본값: false)
///
/// 반환값: YoutubeUrlInfo 리스트
///
/// 예시:
/// ```dart
/// final infos = extractYoutubeUrlInfos("https://youtu.be/abc123?t=30");
/// // infos[0].videoId == "abc123"
/// // infos[0].startTime == 30
/// ```
List<YoutubeUrlInfo> extractYoutubeUrlInfos(String text, {bool strict = false}) {
  final urls = extractYoutubeUrls(text, strict: strict);
  final infos = <YoutubeUrlInfo>[];

  for (final url in urls) {
    final videoId = getYoutubeVideoId(url);
    if (videoId == null || videoId.isEmpty) continue;

    // 시작 시간 추출
    int? startTime;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final t = uri.queryParameters['t'] ?? uri.queryParameters['start'];
      if (t != null) {
        startTime = parseYoutubeTime(t);
      }
    }

    infos.add(YoutubeUrlInfo(
      originalUrl: url,
      videoId: videoId,
      isShorts: isYoutubeShorts(url),
      startTime: startTime,
    ));
  }

  return infos;
}
