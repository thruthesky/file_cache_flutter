import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file_upload/file_upload.model.dart';

/// 업로드된 파일 미리보기 위젯
///
/// 이미지/비디오/파일을 미리보기로 표시하며, 우상단 X 버튼으로 삭제 가능.
class UploadedFilePreview extends StatelessWidget {
  final FileUploadModel file;
  final VoidCallback onDelete;

  const UploadedFilePreview({
    super.key,
    required this.file,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
            color: scheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildPreview(scheme),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: scheme.error,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                FontAwesomeIcons.xmark,
                size: 10,
                color: scheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(ColorScheme scheme) {
    if (file.isImage) {
      return Image.network(
        file.thumbnail400x400Url.isNotEmpty
            ? file.thumbnail400x400Url
            : file.url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fileIcon(scheme),
      );
    }

    if (file.isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          if (file.thumbnail400x400Url.isNotEmpty)
            Image.network(
              file.thumbnail400x400Url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fileIcon(scheme),
            )
          else
            _fileIcon(scheme),
          Container(color: Colors.black38),
          FaIcon(
            FontAwesomeIcons.solidCirclePlay,
            size: 28,
            color: Colors.white,
          ),
        ],
      );
    }

    return _fileIcon(scheme);
  }

  Widget _fileIcon(ColorScheme scheme) {
    final IconData icon;
    if (file.isVideo) {
      icon = FontAwesomeIcons.lightFileVideo;
    } else if (file.isAudio) {
      icon = FontAwesomeIcons.lightFileAudio;
    } else if (file.type.contains('pdf')) {
      icon = FontAwesomeIcons.lightFilePdf;
    } else {
      icon = FontAwesomeIcons.lightFile;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 24, color: scheme.primary),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
