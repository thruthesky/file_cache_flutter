// YouTube URL 추출/파싱 유틸리티 함수 모음
//
// 지원하는 YouTube URL 형식:
// - https://www.youtube.com/watch?v=VIDEO_ID
// - https://youtu.be/VIDEO_ID
// - https://www.youtube.com/shorts/VIDEO_ID
// - https://m.youtube.com/watch?v=VIDEO_ID
// - https://www.youtube.com/embed/VIDEO_ID
// - //www.youtube.com/embed/VIDEO_ID (프로토콜 상대 URL)

import 'youtube.model.dart';

/// 텍스트에서 모든 형태의 YouTube URL을 추출
///
/// [text] - 입력 문자열
/// [strict] - true이면 video ID가 정확히 11자리인지 검증 (기본값: false)
List<String> extractYoutubeUrls(String text, {bool strict = false}) {
  if (text.isEmpty) return [];

  final RegExp pattern;

  if (strict) {
    // 엄격 모드: video ID가 정확히 11자리
    pattern = RegExp(
      r'(?:https?:)?//(?:www\.|m\.)?(?:youtube\.com/(?:watch\?(?:[^&\s]*&)*v=[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-])(?:&[^&\s]*)*|embed/[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-])|shorts/[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-]))|youtu\.be/[a-zA-Z0-9_-]{11}(?![a-zA-Z0-9_-])(?:\?[^\s]*)?)',
      caseSensitive: false,
    );
  } else {
    // 유연 모드: video ID가 1자리 이상
    pattern = RegExp(
      r'(?:https?:)?//(?:www\.|m\.)?(?:youtube\.com/(?:watch\?(?:[^&\s]*&)*v=[a-zA-Z0-9_-]+(?:&[^&\s]*)*|embed/[a-zA-Z0-9_-]+|shorts/[a-zA-Z0-9_-]+)|youtu\.be/[a-zA-Z0-9_-]+(?:\?[^\s]*)?)',
      caseSensitive: false,
    );
  }

  final matches = pattern.allMatches(text);
  final urls = <String>[];

  for (final match in matches) {
    String url = match.group(0) ?? '';

    // URL 끝에서 불필요한 문자 제거
    url = url.replaceAll(RegExp(r'[\r\n\t\f\v\)\]">\}\\]+$'), '');
    url = url.replaceAll(RegExp("[']+\$"), '');
    url = url.trim();

    if (url.isNotEmpty && !urls.contains(url)) {
      urls.add(url);
    }
  }

  return urls;
}

/// YouTube URL에서 Video ID 추출
String? getYoutubeVideoId(String url) {
  if (url.isEmpty) return null;

  // 프로토콜 상대 URL 처리
  String normalizedUrl = url;
  if (url.startsWith('//')) {
    normalizedUrl = 'https:$url';
  }

  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  final path = uri.path;

  // youtu.be 단축 URL
  if (host == 'youtu.be' || host == 'www.youtu.be') {
    final videoId = path.replaceFirst('/', '');
    return videoId.isNotEmpty ? videoId : null;
  }

  // youtube.com 도메인
  if (host.contains('youtube.com')) {
    // embed URL
    if (path.startsWith('/embed/')) {
      final videoId = path.substring(7);
      return videoId.isNotEmpty ? videoId : null;
    }

    // shorts URL
    if (path.startsWith('/shorts/')) {
      String videoId = path.substring(8);
      videoId = videoId.replaceAll(RegExp(r'^/|/$'), '');
      return videoId.isNotEmpty ? videoId : null;
    }

    // watch URL
    final queryParams = uri.queryParameters;
    if (queryParams.containsKey('v')) {
      return queryParams['v'];
    }
  }

  return null;
}

/// YouTube Shorts URL인지 확인
bool isYoutubeShorts(String url) {
  if (url.isEmpty) return false;

  final pattern = RegExp(
    r'youtube\.[a-z]{2,}(?:\.[a-z]{2,})?(?::\d+)?/shorts/',
    caseSensitive: false,
  );

  return pattern.hasMatch(url);
}

/// YouTube URL인지 확인
bool isYoutubeUrl(String url) {
  if (url.isEmpty) return false;

  final pattern = RegExp(
    r'(?:youtube\.[a-z]{2,}(?:\.[a-z]{2,})?(?::\d+)?/(watch\?v=|embed/|shorts/)|youtu\.be(?::\d+)?/)',
    caseSensitive: false,
  );

  return pattern.hasMatch(url);
}

/// YouTube 시간 형식을 초 단위로 변환
///
/// 지원 형식: 123, 1m30s, 1h2m3s
int parseYoutubeTime(String time) {
  final numericValue = int.tryParse(time);
  if (numericValue != null) return numericValue;

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

/// 텍스트에서 YouTube URL을 추출하고 상세 정보 반환
List<YoutubeUrlInfo> extractYoutubeUrlInfos(
  String text, {
  bool strict = false,
}) {
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
