import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 재사용 가능한 이미지 업로드 필드 위젯
/// Reusable image upload widget with progress indicator and delete button
class ImageUploadField extends StatefulWidget {
  const ImageUploadField({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.onImageSelected,
    this.onDelete,
    this.isDecodeQr = false,
    this.onQrCodeDecoded,
  });

  final String label;
  final String imageUrl;
  final void Function(String) onImageSelected;
  final VoidCallback? onDelete;
  final bool isDecodeQr;
  final void Function(String?)? onQrCodeDecoded;

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return FileUpload(
      isDecodeQr: widget.isDecodeQr,
      onQrCodeDetected: widget.onQrCodeDecoded,
      onBeforeUpload: () {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });
      },
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
      onUploaded: (url) {
        setState(() {
          _isUploading = false;
        });
        widget.onImageSelected(url);
      },
      onCancelled: () {
        setState(() {
          _isUploading = false;
        });
      },
      image: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: sp.s8),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: scheme.outline),
              ),
              child: Stack(
                children: [
                  /// 이미지 표시
                  if (widget.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const _ImagePlaceholder();
                        },
                      ),
                    )
                  else
                    const _ImagePlaceholder(),

                  /// 삭제 버튼
                  if (widget.imageUrl.isNotEmpty && !_isUploading)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onDelete != null) {
                            widget.onDelete!();
                          } else {
                            widget.onImageSelected('');
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(sp.s8),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.solidTrash,
                            size: 16,
                            color: scheme.error,
                          ),
                        ),
                      ),
                    ),

                  /// 업로드 진행률 표시
                  if (_isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _uploadProgress,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: sp.s16),
                            Text(
                              '${(_uploadProgress * 100).toInt()}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                            SizedBox(height: sp.s4),
                            Text(
                              'Uploading...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 이미지 플레이스홀더 위젯
/// Placeholder shown when no image is uploaded
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.lightImage,
            size: 32,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(height: sp.s8),
          Text(
            T.tapToUploadImage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
