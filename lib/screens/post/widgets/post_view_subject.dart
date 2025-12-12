import 'package:flutter/material.dart';

/// 게시글 제목 위젯
///
/// 게시글 상세 화면에서 제목을 표시합니다.
/// headlineSmall 스타일에 bold 폰트가 적용됩니다.
///
/// ### 매개변수:
/// - [subject] → 게시글 제목
/// - [padding] → 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
///
/// ### 예시:
/// ```dart
/// PostViewSubject(
///   subject: '게시글 제목입니다',
/// )
/// ```
class PostViewSubject extends StatelessWidget {
  /// 게시글 제목
  final String subject;

  /// 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
  final EdgeInsets padding;

  const PostViewSubject({
    super.key,
    required this.subject,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Text(
        subject,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
