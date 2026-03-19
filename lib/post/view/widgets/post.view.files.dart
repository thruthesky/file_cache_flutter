import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file/file.functions.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/widgets/uploaded_video_player.dart';
<<<<<<< HEAD
import 'package:philgo/common_widgets/full_screen_images.dart';
=======
import 'package:philgo/util/widgets/full_screen_image_viewer.dart';
>>>>>>> 9c24fc6e956affc9748e8c6b5823883f96e58051
import 'package:url_launcher/url_launcher.dart';

class PostViewFiles extends StatelessWidget {
  final Post post;

  const PostViewFiles({super.key, required this.post});

  List<String> get _urls {
    if (post.files.isNotEmpty) {
      return post.files
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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

    final mediaUrls = urls
        .map((u) => toAbsoluteUrl(u))
        .where((u) {
          final type = getMediaType(u);
          return type == MediaType.image || type == MediaType.video;
        })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final url in urls)
          _buildMediaItem(context, toAbsoluteUrl(url), mediaUrls),
      ],
    );
  }

  Widget _buildMediaItem(
    BuildContext context,
    String absoluteUrl,
    List<String> mediaUrls,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final type = getMediaType(absoluteUrl);

    switch (type) {
      case MediaType.image:
        final mediaIndex = mediaUrls.indexOf(absoluteUrl);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showFullScreenMedia(
              context,
              mediaUrls,
              mediaIndex >= 0 ? mediaIndex : 0,
            ),
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
          ),
        );

      case MediaType.video:
        final mediaIndex = mediaUrls.indexOf(absoluteUrl);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showFullScreenMedia(
              context,
              mediaUrls,
              mediaIndex >= 0 ? mediaIndex : 0,
            ),
            child: UploadedVideoPlayer(url: absoluteUrl),
          ),
        );

      case MediaType.file:
        final fileName = getFileName(absoluteUrl);
        final ext = getFileExtension(absoluteUrl).toUpperCase();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => launchUrl(
              Uri.parse(absoluteUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
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
                        color: scheme.primary,
                      ),
                      if (ext.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary,
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
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  void _showFullScreenMedia(
    BuildContext context,
    List<String> mediaUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImageViewer(
          mediaUrls: mediaUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
