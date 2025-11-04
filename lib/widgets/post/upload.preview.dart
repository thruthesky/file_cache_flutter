import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// A widget that displays a **preview thumbnail** for an uploaded file or image.
///
/// `UploadPreview` renders a rectangular thumbnail image using the provided [url].
/// It automatically applies rounded corners and supports configurable width and height.
///
/// This widget is typically used to show file or image previews
/// before uploading, or when displaying uploaded media in a list or grid.
///
/// ### Parameters:
/// - [width] → The width of the preview box. Defaults to `120`.
/// - [height] → The height of the preview box. Defaults to `120`.
/// - [borderRadius] → The roundness of the box corners. Defaults to `8`.
/// - [url] → The URL of the uploaded file or image.
///   It is passed through the `thumbnail_image_url()` function from the `philgo_v6_flutter` package
///   to get an optimized thumbnail version.
///
/// ### Example:
/// ```dart
/// UploadPreview(
///   url: 'https://example.com/uploads/image.jpg',
///   width: 100,
///   height: 100,
///   borderRadius: 12,
/// )
/// ```
////// ### Notes:
/// - Not supported for videos **yet**
/// - If you want to add placeholders, error handling, or shimmer effects,
///   you can wrap `UploadPreview` with a parent widget like `LoadingBox`
class UploadPreview extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final String url;

  const UploadPreview({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 8.0,
    required this.url,
  });

  @override
  State<UploadPreview> createState() => _UploadPreviewState();
}

class _UploadPreviewState extends State<UploadPreview> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image.network(
        thumbnail_image_url(widget.url),
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
