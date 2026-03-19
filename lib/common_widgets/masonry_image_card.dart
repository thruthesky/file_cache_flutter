import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 범용 Masonry 이미지 카드 위젯
///
/// 이미지 위에 하단 그라디언트 오버레이와 제목을 표시하는 카드.
/// 이미지의 실제 비율에 따라 높이를 동적으로 조절한다.
///
/// ```dart
/// MasonryImageCard(
///   imageUrl: 'https://example.com/photo.jpg',
///   title: '카드 제목',
///   subtitle: '부가 정보',
///   onTap: () => print('tap'),
/// )
/// ```
class MasonryImageCard extends StatefulWidget {
  /// 이미지 URL (null이면 placeholder 표시)
  final String? imageUrl;

  /// 카드 하단에 표시할 제목
  final String title;

  /// 제목 아래 부가 텍스트 (선택)
  final String? subtitle;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 이미지 없을 때 표시할 커스텀 플레이스홀더
  final Widget? placeholder;

  /// 카드 좌측 상단에 표시할 배지 위젯 (선택)
  final Widget? badge;

  /// 이미지 비율 기반 높이의 최솟값
  final double minHeight;

  /// 이미지 비율 기반 높이의 최댓값
  final double maxHeight;

  /// 이미지 로드 전 기본 높이
  final double defaultHeight;

  /// 카드 모서리 둥글기
  final BorderRadius borderRadius;

  const MasonryImageCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.placeholder,
    this.badge,
    this.minHeight = 120,
    this.maxHeight = 350,
    this.defaultHeight = 200,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<MasonryImageCard> createState() => _MasonryImageCardState();
}

class _MasonryImageCardState extends State<MasonryImageCard> {
  double? _resolvedHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final height = _resolvedHeight ?? widget.defaultHeight;
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

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
              // 배경: 이미지 또는 플레이스홀더
              if (hasImage)
                _buildImage(scheme)
              else
                widget.placeholder ?? _buildDefaultPlaceholder(scheme),

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

  Widget _buildImage(ColorScheme scheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) {
            // 이미지가 로드되면 실제 비율에 맞춰 높이를 조절
            if (_resolvedHeight == null) {
              imageProvider.resolve(ImageConfiguration.empty).addListener(
                    ImageStreamListener((info, _) {
                      final imgW = info.image.width.toDouble();
                      final imgH = info.image.height.toDouble();
                      final cardW = constraints.maxWidth;
                      final resolved = (imgH / imgW) * cardW;
                      final clamped =
                          resolved.clamp(widget.minHeight, widget.maxHeight);
                      if (mounted) {
                        setState(() => _resolvedHeight = clamped);
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
}
