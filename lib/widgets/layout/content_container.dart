import 'package:flutter/material.dart';

/// 컨텐츠 컨테이너 위젯 (Content Container Widget)
///
/// 화면 중앙에 컨텐츠를 배치하고 최대 너비를 제한합니다.
/// Centers content and constrains maximum width.
///
/// 반응형 레이아웃 동작:
/// - 모바일 (< maxWidth): 전체 너비 사용
/// - 태블릿/데스크톱 (> maxWidth): 최대 너비로 제한 + 중앙 정렬
///
/// Responsive layout behavior:
/// - Mobile (< maxWidth): Uses full width
/// - Tablet/Desktop (> maxWidth): Constrained to maxWidth + centered
///
/// 사용 예시 (Usage example):
/// ```dart
/// ContentContainer(
///   child: CustomScrollView(...),
/// )
/// ```
class ContentContainer extends StatelessWidget {
  /// 자식 위젯 (Child widget)
  final Widget child;

  /// 최대 너비 (Maximum width)
  /// 기본값: 800
  /// Default: 800
  final double maxWidth;

  const ContentContainer({super.key, required this.child, this.maxWidth = 800});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
