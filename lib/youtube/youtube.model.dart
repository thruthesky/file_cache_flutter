// YouTube URL 정보를 담는 데이터 클래스

/// YouTube URL 정보 모델
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

  /// embed URL로 변환
  String get embedUrl {
    String url = 'https://www.youtube.com/embed/$videoId';
    if (startTime != null && startTime! > 0) {
      url += '?start=$startTime';
    }
    return url;
  }

  /// YouTube 썸네일 이미지 URL 반환
  ///
  /// 품질 옵션: maxresdefault, sddefault, hqdefault, mqdefault, default
  String getThumbnailUrl({String quality = 'hqdefault'}) {
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  @override
  String toString() =>
      'YoutubeUrlInfo(videoId: $videoId, isShorts: $isShorts, startTime: $startTime)';
}
