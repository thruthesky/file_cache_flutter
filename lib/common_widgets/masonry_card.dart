import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 범용 Masonry 카드 위젯
///
/// 미디어 우선순위: YouTube > 동영상 > 이미지
/// 아무 미디어도 없으면 작은 카드에 제목만 표시.
///
/// ```dart
/// MasonryCard(
///   title: '카드 제목',
///   youtubeUrl: post.youtubeUrl,    // 1순위
///   videoUrl: post.videoUrl,         // 2순위
///   imageUrl: post.thumbnailUrl,     // 3순위
///   onTap: () => openPost(post),
/// )
/// ```
class MasonryCard extends StatefulWidget {
  /// 카드 하단에 표시할 제목
  final String title;

  /// 제목 아래 부가 텍스트 (선택)
  final String? subtitle;

  /// 이미지 URL — 3순위 (YouTube, 동영상이 없을 때 표시)
  final String? imageUrl;

  /// YouTube URL — 1순위 (썸네일 + 재생 아이콘)
  final String? youtubeUrl;

  /// 동영상 URL — 2순위 (썸네일 or 비디오 아이콘 + 재생 아이콘)
  final String? videoUrl;

  /// 동영상 썸네일 URL (videoUrl과 함께 사용, 없으면 비디오 아이콘 표시)
  final String? videoThumbnailUrl;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 미디어 없을 때 표시할 커스텀 플레이스홀더
  final Widget? placeholder;

  /// 카드 좌측 상단에 표시할 배지 위젯 (선택)
  final Widget? badge;

  /// 이미지 비율 기반 높이의 최솟값
  final double minHeight;

  /// 이미지 비율 기반 높이의 최댓값
  final double maxHeight;

  /// 미디어가 있을 때 기본 높이
  final double defaultHeight;

  /// 카드 모서리 둥글기
  final BorderRadius borderRadius;

  const MasonryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.youtubeUrl,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.onTap,
    this.placeholder,
    this.badge,
    this.minHeight = 120,
    this.maxHeight = 350,
    this.defaultHeight = 200,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<MasonryCard> createState() => _MasonryCardState();
}

class _MasonryCardState extends State<MasonryCard> {
  double? _resolvedHeight;

  /// 미디어 타입을 우선순위에 따라 판별
  _MediaType get _mediaType {
    if (_isNotEmpty(widget.youtubeUrl)) return _MediaType.youtube;
    if (_isNotEmpty(widget.videoUrl)) return _MediaType.video;
    if (_isNotEmpty(widget.imageUrl)) return _MediaType.image;
    return _MediaType.none;
  }

  static bool _isNotEmpty(String? s) => s != null && s.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final media = _mediaType;

    // 미디어 없으면 제목만 표시하는 컴팩트 카드
    if (media == _MediaType.none && widget.placeholder == null) {
      return _buildTextOnlyCard(scheme, textTheme);
    }

    final height = _resolvedHeight ?? widget.defaultHeight;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
      elevation: 1,
      child: InkWell(
        onTap: widget.onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경: 미디어 타입에 따른 표시
              _buildMedia(scheme, media),

              // 하단 그라디언트 오버레이 + 제목
              _buildOverlay(textTheme),

              // 배지 (선택)
              if (widget.badge != null)
                Positioned(top: 8, left: 8, child: widget.badge!),
            ],
          ),
        ),
      ),
    );
  }

  /// 미디어 없을 때: 제목만 표시하는 컴팩트 카드
  Widget _buildTextOnlyCard(ColorScheme scheme, TextTheme textTheme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
      elevation: 1,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 미디어 타입에 따른 배경 위젯
  Widget _buildMedia(ColorScheme scheme, _MediaType media) {
    switch (media) {
      case _MediaType.youtube:
        return _buildYoutubeThumbnail(scheme);
      case _MediaType.video:
        return _buildVideoThumbnail(scheme);
      case _MediaType.image:
        return _buildImage(scheme);
      case _MediaType.none:
        return widget.placeholder ?? _buildDefaultPlaceholder(scheme);
    }
  }

  /// YouTube 썸네일 + 재생 아이콘 오버레이
  Widget _buildYoutubeThumbnail(ColorScheme scheme) {
    final videoId = _extractYoutubeVideoId(widget.youtubeUrl!);
    if (videoId == null) return _buildDefaultPlaceholder(scheme);

    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCachedImage(thumbnailUrl, scheme),
        _buildPlayOverlay(isYoutube: true),
      ],
    );
  }

  /// 동영상 썸네일 (있으면) + 재생 아이콘 오버레이
  Widget _buildVideoThumbnail(ColorScheme scheme) {
    final thumb = widget.videoThumbnailUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isNotEmpty(thumb))
          _buildCachedImage(thumb!, scheme)
        else
          Container(
            color: scheme.surfaceContainerHigh,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.film,
                size: 40,
                color: scheme.outline,
              ),
            ),
          ),
        _buildPlayOverlay(),
      ],
    );
  }

  /// 재생 아이콘 오버레이
  Widget _buildPlayOverlay({bool isYoutube = false}) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isYoutube
              ? const Color(0xCCFF0000)
              : Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  /// CachedNetworkImage로 이미지 표시 + 비율 기반 높이 자동 조절
  Widget _buildImage(ColorScheme scheme) {
    debugPrint('🖼️ MasonryCard 이미지 로드 시도: ${widget.imageUrl}');
    return LayoutBuilder(
      builder: (context, constraints) {
        return CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) {
            if (_resolvedHeight == null) {
              imageProvider
                  .resolve(ImageConfiguration.empty)
                  .addListener(
                    ImageStreamListener((info, _) {
                      final imgW = info.image.width.toDouble();
                      final imgH = info.image.height.toDouble();
                      final cardW = constraints.maxWidth;
                      final resolved = (imgH / imgW) * cardW;
                      final clamped = resolved.clamp(
                        widget.minHeight,
                        widget.maxHeight,
                      );
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _resolvedHeight = clamped);
                          }
                        });
                      }
                    }),
                  );
            }
            return Image(image: imageProvider, fit: BoxFit.cover);
          },
          placeholder: (_, _) => Container(
            color: scheme.surfaceContainerHigh,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, url, error) {
            debugPrint('❌ MasonryCard 이미지 로드 실패: $url');
            debugPrint('❌ 에러: $error');
            return Container(
              color: scheme.surfaceContainerHigh,
              child: Icon(Icons.broken_image, color: scheme.outline),
            );
          },
        );
      },
    );
  }

  /// YouTube URL도 CachedNetworkImage로 표시 + 비율 조절
  Widget _buildCachedImage(String url, ColorScheme scheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) {
            if (_resolvedHeight == null) {
              imageProvider
                  .resolve(ImageConfiguration.empty)
                  .addListener(
                    ImageStreamListener((info, _) {
                      final imgW = info.image.width.toDouble();
                      final imgH = info.image.height.toDouble();
                      final cardW = constraints.maxWidth;
                      final resolved = (imgH / imgW) * cardW;
                      final clamped = resolved.clamp(
                        widget.minHeight,
                        widget.maxHeight,
                      );
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _resolvedHeight = clamped);
                          }
                        });
                      }
                    }),
                  );
            }
            return Image(image: imageProvider, fit: BoxFit.cover);
          },
          placeholder: (_, _) => Container(
            color: scheme.surfaceContainerHigh,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, _, _) => Container(
            color: scheme.surfaceContainerHigh,
            child: Icon(Icons.broken_image, color: scheme.outline),
          ),
        );
      },
    );
  }

  Widget _buildDefaultPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_outlined, color: scheme.outline, size: 40),
      ),
    );
  }

  Widget _buildOverlay(TextTheme textTheme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xCC000000), Color(0x00000000)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// YouTube URL에서 video ID를 추출
  static String? _extractYoutubeVideoId(String url) {
    // youtu.be/VIDEO_ID
    final shortMatch = RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (shortMatch != null) return shortMatch.group(1);

    // youtube.com/watch?v=VIDEO_ID
    final longMatch = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (longMatch != null) return longMatch.group(1);

    // youtube.com/shorts/VIDEO_ID
    final shortsMatch = RegExp(r'/shorts/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (shortsMatch != null) return shortsMatch.group(1);

    // youtube.com/embed/VIDEO_ID
    final embedMatch = RegExp(r'/embed/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (embedMatch != null) return embedMatch.group(1);

    return null;
  }
}

/// 미디어 타입 우선순위
enum _MediaType { youtube, video, image, none }
