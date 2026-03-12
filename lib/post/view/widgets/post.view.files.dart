import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/uploaded_video_player.dart';

class PostViewFiles extends StatelessWidget {
  final Post post;

  const PostViewFiles({super.key, required this.post});

  List<String> get _urls {
    if (post.files.isNotEmpty) {
      return post.files.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    final urls = <String>[];
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      urls.add(post.imageUrl!);
    }
    if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
      urls.add(post.videoUrl!);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final url in urls) _buildMediaItem(context, toAbsoluteUrl(url)),
      ],
    );
  }

  Widget _buildMediaItem(BuildContext context, String absoluteUrl) {
    final scheme = Theme.of(context).colorScheme;
    final type = getMediaType(absoluteUrl);

    switch (type) {
      case MediaType.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl: absoluteUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              placeholder: (_, _) => Container(
                height: 200,
                color: scheme.surfaceContainerHigh,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        );

      case MediaType.youtube:
        final videoId = getYouTubeVideoId(absoluteUrl);
        final thumbUrl = videoId != null
            ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
            : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (thumbUrl != null)
                  CachedNetworkImage(
                    imageUrl: thumbUrl,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    placeholder: (_, _) => Container(
                      height: 200,
                      color: scheme.surfaceContainerHigh,
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 200,
                      color: scheme.surfaceContainerHigh,
                    ),
                  )
                else
                  Container(height: 200, color: scheme.surfaceContainerHigh),
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.black38,
                ),
                const FaIcon(
                  FontAwesomeIcons.youtube,
                  size: 56,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );

      case MediaType.video:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UploadedVideoPlayer(url: absoluteUrl),
        );

      case MediaType.file:
        final fileName = Uri.tryParse(absoluteUrl)?.pathSegments.lastOrNull ?? absoluteUrl;
        final ext = fileName.contains('.')
            ? fileName.split('.').last.toUpperCase()
            : '';
        final isPdf = ext == 'PDF';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightFile,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      if (ext.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: isPdf ? Colors.red : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            ext,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FaIcon(
                    FontAwesomeIcons.lightArrowDownToLine,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );

      case MediaType.unknown:
        return const SizedBox.shrink();
    }
  }
}
