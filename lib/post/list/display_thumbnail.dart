import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.service.dart';

export 'package:philgo/post/post.service.dart'
    show MediaType, getMediaType, getYouTubeVideoId, toAbsoluteUrl;

Widget thumbnailPlaceholder(double size, ColorScheme scheme) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: scheme.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(8),
  ),
);

Widget thumbnailErrorWidget(double size, ColorScheme scheme) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: scheme.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant, size: 24),
);

/// Displays a preview thumbnail based on media type
class DisplayThumbnail extends StatelessWidget {
  final String url;
  final double size;
  final ColorScheme scheme;

  const DisplayThumbnail({
    super.key,
    required this.url,
    required this.scheme,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final absoluteUrl = toAbsoluteUrl(url);
    final type = getMediaType(absoluteUrl);

    switch (type) {
      case MediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: absoluteUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (_, _) => thumbnailPlaceholder(size, scheme),
            errorWidget: (_, _, _) => thumbnailErrorWidget(size, scheme),
          ),
        );

      case MediaType.youtube:
        final videoId = getYouTubeVideoId(absoluteUrl);
        final thumbUrl = videoId != null
            ? 'https://img.youtube.com/vi/$videoId/mqdefault.jpg'
            : null;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (thumbUrl != null)
                CachedNetworkImage(
                  imageUrl: thumbUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => thumbnailPlaceholder(size, scheme),
                  errorWidget: (_, _, _) => thumbnailPlaceholder(size, scheme),
                )
              else
                thumbnailPlaceholder(size, scheme),
              Container(width: size, height: size, color: Colors.black38),
              FaIcon(
                FontAwesomeIcons.youtube,
                size: size * 0.35,
                color: Colors.red,
              ),
            ],
          ),
        );

      case MediaType.video:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              thumbnailPlaceholder(size, scheme),
              FaIcon(
                FontAwesomeIcons.circlePlay,
                size: size * 0.4,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        );

      case MediaType.unknown:
        return thumbnailErrorWidget(size, scheme);
    }
  }
}
