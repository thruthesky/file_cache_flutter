import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:philgo_api/philgo_api.dart';
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
class PostViewContent extends StatefulWidget {
  const PostViewContent({
    super.key,
    required this.isLoading,
    required this.post,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  /// 로딩 중인지 여부
  final bool isLoading;

  /// 게시글 본문 내용
  final Post post;

  /// 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
  final EdgeInsets padding;

  @override
  State<PostViewContent> createState() => _PostViewContentState();
}

class _PostViewContentState extends State<PostViewContent> {
  Post get post => widget.post;
  String get content => post.content;
  bool get isHtml => post.isHtml ?? false;
  bool get isMarkdown => post.isMarkdown ?? false;
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Padding(
        padding: widget.padding,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    Widget child;
    if (isHtml) {
      // HTML 콘텐츠를 flutter_html 패키지를 사용하여 렌더링
      // 링크 클릭 시 외부 브라우저에서 열림
      child = Html(
        data: content,
        style: {
          // 기본 body 스타일 설정
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          // 링크 스타일 설정
          "a": Style(
            color: Theme.of(context).colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          // 중요: 이미지 스타일 설정 (너비 100%)
          // 반드시 아래와 같이 MediaQuery를 사용해야 100% 이미지 너비가 적용된다!!
          "img": Style(
            width: Width(MediaQuery.of(context).size.width, Unit.auto),
          ),
          // 단락 스타일 설정
          "p": Style(margin: Margins.only(bottom: 8)),
        },
        onLinkTap: (url, attributes, element) async {
          // 링크 클릭 시 외부 브라우저에서 열기
          if (url != null) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
      );
    } else if (isMarkdown) {
      // 마크다운 콘텐츠를 markdown_widget 패키지를 사용하여 렌더링
      // Light mode만 지원
      child = MarkdownBlock(
        data: content,
        // Light mode 설정 사용 (Dark mode 미지원)
        config: MarkdownConfig(
          configs: [
            // 링크 클릭 시 외부 브라우저에서 열기
            LinkConfig(
              onTap: (url) async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            // 기본 텍스트 스타일 설정
            PConfig(
              textStyle: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    } else {
      child = Linkify(
        text: content,
        onOpen: (link) async {
          final url = Uri.parse(link.url);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        },
        options: const LinkifyOptions(humanize: false),
        linkStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      );
    }
    return Padding(padding: widget.padding, child: child);
  }
}
