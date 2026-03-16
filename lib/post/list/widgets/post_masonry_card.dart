import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo/post/post.model.dart';

class PostMasonryCard extends StatelessWidget {
  final Post post;
  final ThemeData theme;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const PostMasonryCard({
    super.key,
    required this.post,
    required this.theme,
    required this.scheme,
    required this.onTap,
  });

  String? get _imageUrl {
    if (post.thumbnail800x800 != null && post.thumbnail800x800!.isNotEmpty) {
      return post.thumbnail800x800;
    }
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) return post.imageUrl;
    if (post.thumbnail400x400 != null && post.thumbnail400x400!.isNotEmpty) {
      return post.thumbnail400x400;
    }
    if (post.files.isNotEmpty) {
      final first = post.files.split(',').map((e) => e.trim()).firstWhere(
            (e) => e.isNotEmpty,
            orElse: () => '',
          );
      if (first.isNotEmpty) return first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Full image or placeholder
            if (url != null)
              CachedNetworkImage(
                imageUrl: url,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 180,
                  color: scheme.surfaceContainerHigh,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 180,
                  color: scheme.surfaceContainerHigh,
                  child: Icon(Icons.broken_image, color: scheme.outline),
                ),
              )
            else
              Container(
                height: 180,
                color: scheme.surfaceContainerHigh,
                child: Center(
                  child: Icon(Icons.image_outlined, color: scheme.outline, size: 40),
                ),
              ),
            // Gradient overlay + title at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCC000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                child: Text(
                  post.subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
