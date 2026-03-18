import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';

class PostMasonryCard extends StatelessWidget {
  final Post post;
  final ThemeData theme;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final double? cachedHeight;
  final void Function(int idx, double height)? onHeightResolved;

  static const double _placeholderHeight = 200;

  const PostMasonryCard({
    super.key,
    required this.post,
    required this.theme,
    required this.scheme,
    required this.onTap,
    this.cachedHeight,
    this.onHeightResolved,
  });

  String? get _imageUrl {
    if (post.thumbnail800x800 != null && post.thumbnail800x800!.isNotEmpty) {
      return post.thumbnail800x800;
    }
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return post.imageUrl;
    }
    if (post.thumbnail400x400 != null && post.thumbnail400x400!.isNotEmpty) {
      return post.thumbnail400x400;
    }
    if (post.files.isNotEmpty) {
      final first = post.files
          .split(',')
          .map((e) => e.trim())
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
      if (first.isNotEmpty) return first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 차단된 사용자의 글이면 차단 안내 표시
    if (post.blocked) {
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightBan,
                    size: 20,
                    color: scheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '차단된 사용자의 글입니다'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final url = _imageUrl;
    final height = cachedHeight ?? _placeholderHeight;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) {
                        // Resolve height from image's intrinsic size
                        if (cachedHeight == null) {
                          imageProvider
                              .resolve(ImageConfiguration.empty)
                              .addListener(
                                ImageStreamListener((info, _) {
                                  final imgWidth = info.image.width.toDouble();
                                  final imgHeight = info.image.height
                                      .toDouble();
                                  final cardWidth = constraints.maxWidth;
                                  final resolved =
                                      (imgHeight / imgWidth) * cardWidth;
                                  final clamped = resolved.clamp(120.0, 350.0);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    onHeightResolved?.call(post.idx, clamped);
                                  });
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
                )
              else
                Container(
                  color: scheme.surfaceContainerHigh,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: scheme.outline,
                      size: 40,
                    ),
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
                      colors: [Color(0xCC000000), Color(0x00000000)],
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
      ),
    );
  }
}
