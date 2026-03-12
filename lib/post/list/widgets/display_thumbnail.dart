import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file/file.functions.dart';

/// URL 기반 미디어 썸네일 위젯 (post list tile 용)
class DisplayThumbnail extends StatelessWidget {
  final String url;
  final double size;

  const DisplayThumbnail({super.key, required this.url, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final absoluteUrl = toAbsoluteUrl(url);
    final type = getMediaType(absoluteUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: _build(type, absoluteUrl, scheme),
      ),
    );
  }

  Widget _build(MediaType type, String absoluteUrl, ColorScheme scheme) {
    switch (type) {
      case MediaType.image:
        return CachedNetworkImage(
          imageUrl: absoluteUrl,
          fit: BoxFit.cover,
          placeholder: (_, _) => _placeholder(scheme),
          errorWidget: (_, _, _) => _placeholder(scheme),
        );

      case MediaType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            _placeholder(scheme),
            FaIcon(FontAwesomeIcons.circlePlay, size: size * 0.4, color: scheme.onSurfaceVariant),
          ],
        );

      case MediaType.file:
        return Stack(
          alignment: Alignment.center,
          children: [
            _placeholder(scheme),
            FaIcon(FontAwesomeIcons.lightFile, size: size * 0.4, color: scheme.onSurfaceVariant),
          ],
        );

    }
  }

  Widget _placeholder(ColorScheme scheme) =>
      Container(color: scheme.surfaceContainerHigh);
}
