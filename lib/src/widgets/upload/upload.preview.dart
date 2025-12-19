import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'display.upload.dart';

/// A widget that displays a **preview thumbnail** for an uploaded file, image, or video.
///
/// `UploadPreview` renders a rectangular thumbnail using the provided [url].
/// It automatically applies rounded corners and supports configurable width and height.
/// It detects the file type from the URL extension and displays appropriate content:
/// - **Images**: Displays the image with thumbnail optimization
/// - **Videos**: Displays an interactive video player using [UploadedVideoPlayer] with play/pause controls
/// - **Files**: Displays a file icon with the file extension badge
///
/// ### Video Player Features (via UploadedVideoPlayer):
/// - Tap on video to show/hide controls
/// - Play/Pause button with visual feedback
/// - Auto-hide controls during playback
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
  final bool isDeleting;

  const UploadPreview({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 8.0,
    required this.url,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  State<UploadPreview> createState() => _UploadPreviewState();
}

class _UploadPreviewState extends State<UploadPreview> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 미리보기 박스 - DisplayUpload 위젯 사용
        DisplayUpload(
          url: widget.url,
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          showFileName: true, // Show filename in comment upload previews
        ),
        // Loading overlay when deleting
        if (widget.isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        // Delete button (top-right corner) - hide when deleting
        if (!widget.isDeleting)
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
