import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 재사용 가능한 이미지 업로드 필드 위젯 - Comic Design
/// Comic 스타일 borderRadius 12, surfaceContainerLow 배경,
/// 클라우드 업로드 아이콘 플레이스홀더, 진행률 표시
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
            /// 라벨 텍스트 - titleSmall, bold, primary 색상
            Text(
              widget.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: sp.s8),

            /// 이미지 컨테이너 - Comic Design: borderRadius 12, outline 테두리
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Stack(
                children: [
                  /// 이미지 표시
                  if (widget.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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

                  /// 삭제 버튼 - Light 아이콘, 원형 errorContainer 배경
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
                            FontAwesomeIcons.lightTrash,
                            size: 14,
                            color: scheme.error,
                          ),
                        ),
                      ),
                    ),

                  /// 업로드 진행률 표시 - 반투명 오버레이 + 퍼센트 + 프로그레스바
                  if (_isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sp.s24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// 업로드 아이콘
                              FaIcon(
                                FontAwesomeIcons.lightCloudArrowUp,
                                size: 32,
                                color: scheme.primary,
                              ),
                              SizedBox(height: sp.s16),

                              /// 진행률 퍼센트
                              Text(
                                '${(_uploadProgress * 100).toInt()}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              ),
                              SizedBox(height: sp.s8),

                              /// 선형 프로그레스바 - surfaceContainerHighest 트랙
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _uploadProgress,
                                  minHeight: 6,
                                  backgroundColor:
                                      scheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    scheme.primary,
                                  ),
                                ),
                              ),
                              SizedBox(height: sp.s4),

                              /// 업로드 중 텍스트 - i18n
                              Text(
                                T.uploading,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
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

/// 이미지 플레이스홀더 위젯 - Comic Design
/// 클라우드 업로드 아이콘과 안내 텍스트 표시
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
          /// 클라우드 업로드 아이콘 - 원형 primaryContainer 배경
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer.withValues(alpha: 0.3),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightCloudArrowUp,
                size: 24,
                color: scheme.primary,
              ),
            ),
          ),
          SizedBox(height: sp.s8),

          /// 업로드 안내 텍스트
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
