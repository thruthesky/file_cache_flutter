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
/// - [padding] → Padding around the widget. Defaults to `EdgeInsets.fromLTRB(16, 16, 16, 0)`
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
    this.padding = const EdgeInsets.fromLTRB(0, 16, 0, 0),
  });

  /// 파일 URL 목록
  final List<String> files;

  /// 게시글 인덱스 (Hero 전환 태그용)
  final int postIdx;

  /// 첫 번째 이미지에 Hero 전환 활성화 여부
  final bool enableHeroTransition;

  /// 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        spacing: 16,
        children: files.asMap().entries.map((entry) {
          final index = entry.key;
          final fileUrl = entry.value;
          final isFirstImage = index == 0;
          final fileType = detectUploadFileType(fileUrl);

          Widget fileWidget;

          switch (fileType) {
            case UploadFileType.image:
              // Image preview with caching and loading states
              fileWidget = _buildImagePreview(context, fileUrl, scheme);
              break;

            case UploadFileType.video:
              // Video player widget
              fileWidget = _buildVideoPreview(context, fileUrl);
              break;

            case UploadFileType.file:
              // Generic file preview
              fileWidget = _buildFilePreview(context, fileUrl, scheme);
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
      ),
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
  Widget _buildVideoPreview(BuildContext context, String videoUrl) {
    return UploadedVideoPlayer(url: videoUrl);
  }

  /// Builds generic file preview with icon and extension
  Widget _buildFilePreview(
    BuildContext context,
    String fileUrl,
    ColorScheme scheme,
  ) {
    final extension = getFileExtension(fileUrl).toUpperCase();
    final displayExtension = extension.isNotEmpty ? extension : 'FILE';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outline, width: 2.0),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // File icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.fileLines,
                size: 28,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Extension badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    displayExtension,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // File URL (truncated)
                Text(
                  fileUrl.split('/').last,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
