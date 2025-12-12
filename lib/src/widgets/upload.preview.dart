import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// A widget that displays a **preview thumbnail** for an uploaded file, image, or video.
///
/// `UploadPreview` renders a rectangular thumbnail using the provided [url].
/// It automatically applies rounded corners and supports configurable width and height.
/// It detects the file type from the URL extension and displays appropriate content:
/// - **Images**: Displays the image with thumbnail optimization
/// - **Videos**: Displays an interactive video player using [PhilgoVideoPlayer] with play/pause controls and progress indicator
/// - **Files**: Displays a file icon with the file extension badge
///
/// ### Video Player Features (via PhilgoVideoPlayer):
/// - Tap on video to show/hide controls
/// - Play/Pause button with visual feedback
/// - Auto-hide controls after 3 seconds during playback
/// - Progress indicator at the bottom
/// - Automatic video initialization and cleanup
/// - Reusable video player component
///
/// This widget is typically used to show file or image previews
/// before uploading, or when displaying uploaded media in a list or grid.
///
/// ### Parameters:
/// - [width] → The width of the preview box. Defaults to `120`.
/// - [height] → The height of the preview box. Defaults to `120`.
/// - [borderRadius] → The roundness of the box corners. Defaults to `8`.
/// - [url] → The URL of the uploaded file, image, or video.
///   For images, it is passed through the `thumbnail_image_url()` function from the `philgo_v6_flutter` package
///   to get an optimized thumbnail version.
/// - [onDelete] → An asynchronous callback triggered when the delete button
///   (X icon) is tapped. It allows you to handle removal logic such as
///   deleting from a list or performing API calls.
///
/// ### Example:
/// ```dart
/// // Image preview
/// UploadPreview(
///   url: 'https://example.com/uploads/image.jpg',
///   width: 100,
///   height: 100,
///   borderRadius: 12,
///   onDelete: () async {
///     debugLog('Deleted image');
///   },
/// )
///
/// // Video preview
/// UploadPreview(
///   url: 'https://example.com/uploads/video.mp4',
///   onDelete: () async {
///     debugLog('Deleted video');
///   },
/// )
///
/// // File preview
/// UploadPreview(
///   url: 'https://example.com/uploads/document.pdf',
///   onDelete: () async {
///     debugLog('Deleted file');
///   },
/// )
/// ```
/// ### Notes:
/// - Supports images (jpg, jpeg, png, gif, webp, bmp)
/// - Supports videos (mp4, mov, avi, mkv, webm, flv)
/// - Supports all other file types with a generic file icon
/// - If you want to add placeholders, error handling, or shimmer effects,
///   you can wrap `UploadPreview` with a parent widget like `LoadingBox`
class UploadPreview extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final String url;
  final Future<void> Function() onDelete;

  const UploadPreview({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 8.0,
    required this.url,
    required this.onDelete,
  });

  @override
  State<UploadPreview> createState() => _UploadPreviewState();
}

/// File preview type enumeration
/// Used to determine how to render the preview based on file type
enum _FileType {
  /// Image files (jpg, jpeg, png, gif, webp, bmp)
  image,

  /// Video files (mp4, mov, avi, mkv, webm, flv)
  video,

  /// Other files (pdf, doc, txt, etc.)
  file,
}

class _UploadPreviewState extends State<UploadPreview> {
  /// Detects the file type based on the URL extension
  /// Returns [_FileType] to determine the appropriate preview rendering
  _FileType _detectFileType() {
    final extension = getFileExtension(widget.url);

    // Image extensions
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    if (imageExtensions.contains(extension)) {
      return _FileType.image;
    }

    // Video extensions
    const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv'];
    if (videoExtensions.contains(extension)) {
      return _FileType.video;
    }

    // Default to file for everything else
    return _FileType.file;
  }

  /// Extracts file extension from URL for display on file preview
  /// Returns the extension in uppercase without the dot (e.g., "PDF", "DOC")
  String _getFileExtension() {
    final extension = getFileExtension(widget.url);
    return extension.isNotEmpty ? extension.toUpperCase() : 'FILE';
  }

  /// Builds the preview content based on file type
  /// - Images: Network image with thumbnail optimization
  /// - Videos: Network image with play icon overlay
  /// - Files: Generic file icon with extension badge
  Widget _buildPreviewContent() {
    final fileType = _detectFileType();

    switch (fileType) {
      case _FileType.image:
        // Image preview with thumbnail optimization
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius - 2),
          child: Image.network(
            thumbnail_image_url(widget.url),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            // Error handling for failed image loads
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPlaceholder();
            },
          ),
        );

      case _FileType.video:
        // Video preview using the reusable PhilgoVideoPlayer
        return PhilgoVideoPlayer(
          url: widget.url,
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius - 2,
        );

      case _FileType.file:
        // Generic file preview with file type icon and extension badge
        return _buildFilePlaceholder();
    }
  }

  /// Builds error placeholder for failed image loads
  Widget _buildErrorPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.imageSlash,
          size: 32,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Builds placeholder for generic file types
  Widget _buildFilePlaceholder() {
    final extension = _getFileExtension();

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius - 2),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.fileLines,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                extension,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Preview container with Comic Design 2.0px border
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            // Comic Design: 2.0px border
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 2.0,
            ),
          ),
          child: _buildPreviewContent(),
        ),
        // Delete button (top-right corner)
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.solidXmark,
                  size: 14,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
