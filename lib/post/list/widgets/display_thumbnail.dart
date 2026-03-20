import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file/file.functions.dart';
import 'package:philgo/file/widgets/video_thumbnail.dart';

/// URL 기반 미디어 썸네일 위젯 (post list tile 용)
///
/// [onDelete]가 제공되면 우상단에 X 버튼이 표시되며,
/// 탭 시 `upload.deleteByUrl` API를 호출한 뒤 [onDelete]를 호출한다.
class DisplayThumbnail extends StatelessWidget {
  final String url;
  final double size;
  final VoidCallback? onDelete;

  const DisplayThumbnail({
    super.key,
    required this.url,
    this.size = 72,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final absoluteUrl = toAbsoluteUrl(url);
    final type = getMediaType(absoluteUrl);

    Widget preview = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: _build(type, absoluteUrl, scheme),
      ),
    );

    if (onDelete == null) return preview;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        preview,
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: scheme.error,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                FontAwesomeIcons.xmark,
                size: 10,
                color: scheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build(MediaType type, String absoluteUrl, ColorScheme scheme) {
    switch (type) {
      case MediaType.image:
        return Image.network(
          absoluteUrl,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _placeholder(scheme);
          },
          errorBuilder: (_, _, _) => _placeholder(scheme),
        );

      case MediaType.video:
        return VideoThumbnail(url: absoluteUrl, size: size, borderRadius: 0);

      case MediaType.file:
        final ext = getFileExtension(absoluteUrl).toUpperCase();
        return Stack(
          alignment: Alignment.center,
          children: [
            _placeholder(scheme),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightFile,
                  size: size * 0.4,
                  color: scheme.primary,
                ),
                if (ext.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      ext,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
    }
  }

  Widget _placeholder(ColorScheme scheme) =>
      Container(color: scheme.surfaceContainerHigh);
}
