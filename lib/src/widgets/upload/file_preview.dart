import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// Reusable file preview widget for displaying file attachments
///
/// This widget provides a consistent compact design for file previews.
/// It automatically detects file type and shows appropriate icons and labels.
///
/// ### Parameters:
/// - [fileUrl] → URL of the file to preview
///
/// ### Example:
/// ```dart
/// FilePreview(fileUrl: 'https://example.com/document.pdf')
/// ```
class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.fileUrl});

  /// URL of the file to preview
  final String fileUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extension = getFileExtension(fileUrl).toUpperCase();
    final displayExtension = extension.isNotEmpty ? extension : 'FILE';
    final fileName = fileUrl.split('/').last;

    return Stack(
      children: [
        // Main file preview card
        GestureDetector(
          onTap: () => openFile(fileUrl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.surfaceContainerHighest,
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // File icon with extension badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FaIcon(
                          FilePreviewHelper.getFileIcon(extension),
                          size: 20,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: scheme.surfaceContainerHighest,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          displayExtension,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // File name
                Expanded(
                  child: Text(
                    fileName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Open indicator
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),

        // Extension badge positioned overlay
      ],
    );
  }
}
