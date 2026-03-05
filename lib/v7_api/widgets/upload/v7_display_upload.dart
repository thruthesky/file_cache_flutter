import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/v7_upload_model.dart';

/// v7 업로드 파일 표시 위젯 (재활용 필수)
///
/// [V7UploadModel]을 기반으로 이미지, PDF, 영상, 압축 파일, 텍스트 등
/// 모든 파일 유형을 표시한다.
///
/// **이미지**: [CachedNetworkImage]로 캐싱하여 표시.
/// **비이미지**: 파일 타입별 아이콘 + 파일명을 표시.
///
/// [thumbnail]이 true이면 400x400 정사각형 썸네일을,
/// false이면 원본 이미지를 표시한다.
///
/// ```dart
/// // 썸네일 모드 (기본)
/// V7DisplayUpload(data: uploadModel, width: 110, height: 110)
///
/// // 원본 이미지 모드
/// V7DisplayUpload(data: uploadModel, thumbnail: false, width: 300)
///
/// // 삭제 버튼 포함
/// V7DisplayUpload(
///   data: uploadModel,
///   width: 110,
///   height: 110,
///   onDelete: () => setState(() => photos.remove(uploadModel)),
/// )
/// ```
class V7DisplayUpload extends StatelessWidget {
  const V7DisplayUpload({
    super.key,
    required this.data,
    this.thumbnail = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.onDelete,
    this.onTap,
  });

  /// v7 업로드 파일 모델
  final V7UploadModel data;

  /// true: 썸네일(400x400) 표시, false: 원본 이미지 표시
  final bool thumbnail;

  /// 위젯 가로 크기
  final double? width;

  /// 위젯 세로 크기
  final double? height;

  /// 이미지 fit 모드
  final BoxFit fit;

  /// 테두리 둥글기
  final double borderRadius;

  /// 삭제 버튼 탭 콜백 (null이면 삭제 버튼 미표시)
  final VoidCallback? onDelete;

  /// 위젯 탭 콜백
  final VoidCallback? onTap;

  /// 표시할 이미지 URL 결정
  /// thumbnail=true → thumbnail400x400Url > url
  /// thumbnail=false → url (원본)
  String _resolveImageUrl() {
    if (!thumbnail) return data.url;

    if (data.thumbnail400x400Url.isNotEmpty) return data.thumbnail400x400Url;
    return data.url;
  }

  /// 파일 타입에 맞는 아이콘 반환
  IconData _fileIcon() {
    final type = data.type;
    final name = data.name.toLowerCase();

    // PDF
    if (type == 'application/pdf' || name.endsWith('.pdf')) {
      return FontAwesomeIcons.lightFilePdf;
    }
    // 압축 파일
    if (type.contains('zip') ||
        type.contains('rar') ||
        type.contains('tar') ||
        type.contains('gzip') ||
        name.endsWith('.zip') ||
        name.endsWith('.rar') ||
        name.endsWith('.7z')) {
      return FontAwesomeIcons.lightFileZipper;
    }
    // 텍스트
    if (type.startsWith('text/') ||
        name.endsWith('.txt') ||
        name.endsWith('.csv') ||
        name.endsWith('.log')) {
      return FontAwesomeIcons.lightFileLines;
    }
    // 영상
    if (data.isVideo) {
      return FontAwesomeIcons.lightFileVideo;
    }
    // 오디오
    if (type.startsWith('audio/')) {
      return FontAwesomeIcons.lightFileAudio;
    }
    // 워드
    if (type.contains('word') ||
        name.endsWith('.doc') ||
        name.endsWith('.docx')) {
      return FontAwesomeIcons.lightFileWord;
    }
    // 엑셀
    if (type.contains('spreadsheet') ||
        type.contains('excel') ||
        name.endsWith('.xls') ||
        name.endsWith('.xlsx')) {
      return FontAwesomeIcons.lightFileExcel;
    }
    // 파워포인트
    if (type.contains('presentation') ||
        name.endsWith('.ppt') ||
        name.endsWith('.pptx')) {
      return FontAwesomeIcons.lightFilePowerpoint;
    }
    // 코드
    if (name.endsWith('.dart') ||
        name.endsWith('.php') ||
        name.endsWith('.js') ||
        name.endsWith('.json') ||
        name.endsWith('.html') ||
        name.endsWith('.css')) {
      return FontAwesomeIcons.lightFileCode;
    }
    // 기본 파일 아이콘
    return FontAwesomeIcons.lightFile;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget content;

    if (data.isImage) {
      content = _buildImageContent(scheme);
    } else {
      content = _buildFileContent(scheme);
    }

    // 삭제 버튼 포함 시 Stack 사용
    if (onDelete != null) {
      content = Stack(
        children: [
          content,
          _buildDeleteButton(scheme),
        ],
      );
    }

    // onTap 콜백 포함 시 GestureDetector 사용
    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return SizedBox(width: width, height: height, child: content);
  }

  /// 이미지 파일 표시
  Widget _buildImageContent(ColorScheme scheme) {
    final imageUrl = _resolveImageUrl();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => _buildPlaceholder(scheme),
        errorWidget: (_, url, error) {
          debugPrint('[V7DisplayUpload] 이미지 로드 실패: $url / $error');
          return _buildPlaceholder(scheme);
        },
      ),
    );
  }

  /// 비이미지 파일 표시 (아이콘 + 파일명)
  Widget _buildFileContent(ColorScheme scheme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            _fileIcon(),
            color: scheme.onSurfaceVariant,
            size: 28,
          ),
          if (data.name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 이미지 로딩/에러 시 대체 위젯
  Widget _buildPlaceholder(ColorScheme scheme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.lightImage,
          color: scheme.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }

  /// 삭제 버튼 (우상단)
  Widget _buildDeleteButton(ColorScheme scheme) {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: scheme.error.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.xmark,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
