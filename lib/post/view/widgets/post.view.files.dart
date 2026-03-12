import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file/file.functions.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/widgets/uploaded_video_player.dart';

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

      case MediaType.video:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UploadedVideoPlayer(url: absoluteUrl),
        );

      case MediaType.file:
        final fileName = getFileName(absoluteUrl);
        final ext = getFileExtension(absoluteUrl).toUpperCase();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {},
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
}
