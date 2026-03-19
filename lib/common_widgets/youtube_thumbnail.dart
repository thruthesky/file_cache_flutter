import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../youtube/youtube.service.dart';

/// YouTube 썸네일을 표시하는 범용 위젯
///
/// YouTube URL에서 썸네일 이미지를 추출하여 표시하고,
/// 재생 아이콘 오버레이를 함께 렌더링.
/// 게시글 목록 타일, 메이슨리 카드 등에서 범용적으로 사용.
class YoutubeThumbnail extends StatelessWidget {
  /// YouTube URL (varchar_19 등)
  final String youtubeUrl;

  /// 위젯 크기 (정사각형)
  final double size;

  /// 둥근 모서리 반지름
  final double borderRadius;

  const YoutubeThumbnail({
    super.key,
    required this.youtubeUrl,
    this.size = 72,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final videoId = getYoutubeVideoId(youtubeUrl);
    if (videoId == null) return SizedBox(width: size, height: size);

    final thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    final fallbackUrl =
        'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 썸네일 이미지
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                // hqdefault 실패 시 mqdefault로 폴백
                return CachedNetworkImage(
                  imageUrl: fallbackUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Icon(
                        Icons.error_outline,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                );
              },
            ),
            // 재생 아이콘 오버레이
            Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.play,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// YouTube URL에서 썸네일 URL을 생성하는 유틸리티 함수
///
/// 메이슨리 카드 등에서 이미지 URL 폴백으로 사용
String? getYoutubeThumbnailUrl(String? youtubeUrl, {String quality = 'mqdefault'}) {
  if (youtubeUrl == null || youtubeUrl.isEmpty) return null;
  final videoId = getYoutubeVideoId(youtubeUrl);
  if (videoId == null) return null;
  return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
}
