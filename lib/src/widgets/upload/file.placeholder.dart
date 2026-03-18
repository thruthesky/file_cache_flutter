import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 일반 파일 타입에 대한 플레이스홀더를 표시하는 위젯입니다.
///
/// `FilePlaceholder`는 이미지나 비디오가 아닌 일반 파일(PDF, DOC, ZIP 등)에 대한
/// 미리보기 플레이스홀더를 렌더링합니다. 파일 타입에 맞는 아이콘과 확장자 배지를 함께 표시합니다.
///
/// ### 매개변수:
/// - [width] → 플레이스홀더의 너비. 기본값은 `120`.
/// - [height] → 플레이스홀더의 높이. 기본값은 `120`.
/// - [borderRadius] → 모서리 둥글기. 기본값은 `6`.
/// - [extension] → 표시할 파일 확장자 (예: "PDF", "DOC"). 기본값은 `FILE`.
/// - [fileName] → 표시할 파일 이름 (선택사항). 제공되면 확장자 아래에 표시됩니다.
///
/// ### 예시:
/// ```dart
/// FilePlaceholder(
///   width: 100,
///   height: 100,
///   borderRadius: 8,
///   extension: 'PDF',
///   fileName: 'document.pdf',
/// )
/// ```
class FilePlaceholder extends StatelessWidget {
  /// 플레이스홀더의 너비
  final double width;

  /// 플레이스홀더의 높이
  final double height;

  /// 모서리 둥글기
  final double borderRadius;

  /// 표시할 파일 확장자 (대문자 권장, 예: "PDF", "DOC")
  final String extension;

  /// 표시할 파일 이름 (선택사항)
  final String? fileName;

  final bool showFileName;

  const FilePlaceholder({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 6.0,
    this.extension = 'FILE',
    this.showFileName = false,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Theme 기반 배경색 - surfaceContainerHighest 사용
        color: scheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 파일 타입에 맞는 아이콘 사용 (FilePreviewHelper 활용)
            FaIcon(
              FilePreviewHelper.getFileIcon(extension),
              size: 18,
              color: scheme.primary,
            ),
            const SizedBox(height: 2),
            // 확장자 배지 - primaryContainer 배경에 확장자 텍스트 표시
            Text(
              extension,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 파일 이름 표시 (크기가 충분히 큰 경우에만)
            if (showFileName) ...[
              const SizedBox(height: 2),
              Text(
                cut(fileName!, 8),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
