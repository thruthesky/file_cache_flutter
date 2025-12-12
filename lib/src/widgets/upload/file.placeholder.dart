import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 일반 파일 타입에 대한 플레이스홀더를 표시하는 위젯입니다.
///
/// `FilePlaceholder`는 이미지나 비디오가 아닌 일반 파일(PDF, DOC, ZIP 등)에 대한
/// 미리보기 플레이스홀더를 렌더링합니다. 파일 아이콘과 확장자 배지를 함께 표시합니다.
///
/// ### 매개변수:
/// - [width] → 플레이스홀더의 너비. 기본값은 `120`.
/// - [height] → 플레이스홀더의 높이. 기본값은 `120`.
/// - [borderRadius] → 모서리 둥글기. 기본값은 `6`.
/// - [extension] → 표시할 파일 확장자 (예: "PDF", "DOC"). 기본값은 `FILE`.
///
/// ### 예시:
/// ```dart
/// FilePlaceholder(
///   width: 100,
///   height: 100,
///   borderRadius: 8,
///   extension: 'PDF',
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

  const FilePlaceholder({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 6.0,
    this.extension = 'FILE',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Theme 기반 배경색 - surfaceContainerHighest 사용
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 파일 아이콘 - Font Awesome fileLines 아이콘 사용
            FaIcon(
              FontAwesomeIcons.fileLines,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            // 확장자 배지 - primaryContainer 배경에 확장자 텍스트 표시
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
}
