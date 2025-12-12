import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// @deprecated
/// Use the PostViewFiles instead
class PostViewImages extends StatelessWidget {
  const PostViewImages({
    super.key,
    required this.files,
    required this.postIdx,
    this.enableHeroTransition = false,
  });

  final List<String> files;
  final int postIdx; // Kept for potential future use
  final bool enableHeroTransition;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      spacing: 16,
      children: files.asMap().entries.map((entry) {
        final index = entry.key;
        final imageUrl = entry.value;
        final isFirstImage = index == 0;

        /// Hero transition for first image only to match PostListTile
        final imageWidget = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 200,
                color: scheme.surfaceContainerHighest,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) {
                return Container(
                  height: 200,
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.lightImage,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        );

        /// Wrap first image with Hero for transition from PostListTile (conditional)
        return isFirstImage && enableHeroTransition
            ? Hero(tag: 'post-image-$postIdx', child: imageWidget)
            : imageWidget;
      }).toList(),
    );
  }
}
