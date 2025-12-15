import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable file preview widget for displaying file attachments
///
/// This widget provides a consistent design for file previews across the app.
/// It automatically detects file type and shows appropriate icons and labels.
///
/// ### Parameters:
/// - [fileUrl] → URL of the file to preview
/// - [compact] → Use compact layout (for list tiles). Defaults to `false`
///
/// ### Example:
/// ```dart
/// // Full size preview
/// FilePreview(fileUrl: 'https://example.com/document.pdf')
///
/// // Compact preview for list tiles
/// FilePreview(fileUrl: 'https://example.com/document.pdf', compact: true)
/// ```
class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.fileUrl, this.compact = false});

  /// URL of the file to preview
  final String fileUrl;

  /// Use compact layout for list tiles
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extension = getFileExtension(fileUrl).toUpperCase();
    final displayExtension = extension.isNotEmpty ? extension : 'FILE';
    final fileName = fileUrl.split('/').last;

    return GestureDetector(
      onTap: () => openFile(fileUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          color: scheme.surfaceContainerHighest,
        ),
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          children: [
            // File icon with extension badge
            _buildFileIcon(context, scheme, extension, displayExtension),
            SizedBox(width: compact ? 8 : 12),
            // File info
            Expanded(
              child: _buildFileInfo(context, scheme, fileName, extension),
            ),
            // Download/Open indicator
            _buildActionIcon(context, scheme),
          ],
        ),
      ),
    );
  }

  /// Builds file icon with extension badge overlay
  Widget _buildFileIcon(
    BuildContext context,
    ColorScheme scheme,
    String extension,
    String displayExtension,
  ) {
    final iconSize = compact ? 40.0 : 48.0;
    final iconContentSize = compact ? 20.0 : 24.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main file icon
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
          child: Center(
            child: FaIcon(
              FilePreviewHelper.getFileIcon(extension),
              size: iconContentSize,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        // Extension badge overlay
        if (!compact)
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayExtension,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds file information (name and type)
  Widget _buildFileInfo(
    BuildContext context,
    ColorScheme scheme,
    String fileName,
    String extension,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // File name
        Text(
          fileName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: compact ? FontWeight.normal : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          // File type label
          Text(
            '${FilePreviewHelper.getFileTypeLabel(extension)} File',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  /// Builds action icon (download/open indicator)
  Widget _buildActionIcon(BuildContext context, ColorScheme scheme) {
    if (compact) {
      return FaIcon(
        FontAwesomeIcons.lightChevronRight,
        size: 14,
        color: scheme.onSurfaceVariant,
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FaIcon(
        FontAwesomeIcons.lightArrowDown,
        size: 16,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}

/// Helper class for file preview utilities
class FilePreviewHelper {
  /// Returns appropriate icon based on file extension
  static IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'zip':
      case 'rar':
      case '7z':
        return FontAwesomeIcons.fileZipper;
      case 'txt':
        return FontAwesomeIcons.fileLines;
      default:
        return FontAwesomeIcons.file;
    }
  }

  /// Returns human-readable file type label
  static String getFileTypeLabel(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Word';
      case 'xls':
      case 'xlsx':
        return 'Excel';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      case 'zip':
      case 'rar':
      case '7z':
        return 'Archive';
      case 'txt':
        return 'Text';
      default:
        return 'Document';
    }
  }
}
