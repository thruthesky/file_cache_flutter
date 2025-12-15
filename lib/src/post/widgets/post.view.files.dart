import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:philgo_api/philgo_api.dart';

/// Displays uploaded files (images, videos, and other files) in a post
///
/// This widget automatically detects the file type and renders:
/// - **Images**: Full-width images with caching and loading states
/// - **Videos**: Interactive video player with controls
/// - **Files**: File preview with icon and extension badge
///
/// Supports Hero transitions for the first image when transitioning from PostListTile.
///
/// ### Parameters:
/// - [files] → List of file URLs to display
/// - [postIdx] → Post index for Hero transition tags
/// - [enableHeroTransition] → Whether to enable Hero transition for first image. Defaults to `false`
/// - [padding] → Padding around file-type items only (not applied to images/videos). Defaults to `EdgeInsets.all(16)`
///
/// ### Example:
/// ```dart
/// PostViewFiles(
///   files: [
///     'https://example.com/image.jpg',
///     'https://example.com/video.mp4',
///     'https://example.com/document.pdf',
///   ],
///   postIdx: 123,
///   enableHeroTransition: true,
/// )
/// ```
class PostViewFiles extends StatelessWidget {
  const PostViewFiles({
    super.key,
    required this.files,
    required this.postIdx,
    this.enableHeroTransition = false,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
  });

  /// 파일 URL 목록
  final List<String> files;

  /// 게시글 인덱스 (Hero 전환 태그용)
  final int postIdx;

  /// 첫 번째 이미지에 Hero 전환 활성화 여부
  final bool enableHeroTransition;

  /// 패딩 - 파일 타입에만 적용 (이미지/비디오 제외, 기본값: EdgeInsets.all(16))
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Return empty widget if no files
    if (files.isEmpty) return const SizedBox.shrink();

    // Track if we've already created a video widget
    bool firstVideoEncountered = false;

    return Column(
      spacing: 16,
      children: files.asMap().entries.map((entry) {
        final index = entry.key;
        final fileUrl = entry.value;
        final isFirstImage = index == 0;
        final fileType = detectFileType(fileUrl);

        Widget fileWidget;

        switch (fileType) {
          case UploadFileType.image:
            // Image preview with caching and loading states (no padding)
            fileWidget = _buildImagePreview(context, fileUrl, scheme);
            break;

          case UploadFileType.video:
            // Video player widget (no padding)
            // Only autoplay the first video encountered
            final shouldAutoPlay = !firstVideoEncountered;
            firstVideoEncountered = true;
            fileWidget = _buildVideoPreview(context, fileUrl, shouldAutoPlay);
            break;

          case UploadFileType.file:
            // Generic file preview (with padding)
            fileWidget = Padding(
              padding: padding,
              child: FilePreview(fileUrl: fileUrl),
            );
            break;
        }

        /// Wrap first image with Hero for transition from PostListTile (conditional)
        /// Only apply Hero to images, not videos or files
        return isFirstImage &&
                enableHeroTransition &&
                fileType == UploadFileType.image
            ? Hero(tag: 'post-image-$postIdx', child: fileWidget)
            : fileWidget;
      }).toList(),
    );
  }

  /// Builds image preview with caching and loading states
  Widget _buildImagePreview(
    BuildContext context,
    String imageUrl,
    ColorScheme scheme,
  ) {
    return CachedNetworkImage(
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
    );
  }

  /// Builds video preview with player controls
  /// Only autoplays if [shouldAutoPlay] is true (i.e., first video only)
  Widget _buildVideoPreview(
    BuildContext context,
    String videoUrl,
    bool shouldAutoPlay,
  ) {
    return UploadedVideoPlayer(url: videoUrl, autoPlay: shouldAutoPlay);
  }
}
