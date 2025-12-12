import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// 게시글 본문 콘텐츠 위젯
///
/// 게시글 상세 화면에서 본문 내용을 표시합니다.
/// URL 링크는 자동으로 클릭 가능한 링크로 변환됩니다.
///
/// ### 매개변수:
/// - [isLoading] → 로딩 중인지 여부
/// - [content] → 게시글 본문 내용
/// - [padding] → 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
///
/// ### 예시:
/// ```dart
/// PostViewContent(
///   isLoading: false,
///   content: '게시글 본문 내용입니다.',
/// )
/// ```
class PostViewContent extends StatelessWidget {
  const PostViewContent({
    super.key,
    required this.isLoading,
    required this.content,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  /// 로딩 중인지 여부
  final bool isLoading;

  /// 게시글 본문 내용
  final String content;

  /// 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator.adaptive())
          else
            Linkify(
              onOpen: (link) async {
                final uri = Uri.parse(link.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              text: content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              linkStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
        ],
      ),
    );
  }
}
