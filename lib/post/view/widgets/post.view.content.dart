import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:philgo/post/post.model.dart';
import 'package:url_launcher/url_launcher.dart';

/// 게시글 본문 콘텐츠 위젯
///
/// HTML, Markdown, 일반 텍스트를 자동으로 판별하여 렌더링한다.
class PostViewContent extends StatelessWidget {
  const PostViewContent({
    super.key,
    required this.post,
    this.isLoading = false,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  final Post post;
  final bool isLoading;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: padding,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = post.content;

    Widget child;
    if (post.isHtml) {
      child = Html(
        data: content,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            color: scheme.onSurface,
          ),
          "a": Style(
            color: scheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          "img": Style(
            width: Width(MediaQuery.of(context).size.width, Unit.auto),
          ),
          "p": Style(margin: Margins.only(bottom: 8)),
        },
        onLinkTap: (url, attributes, element) async {
          if (url != null) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
      );
    } else if (post.isMarkdown) {
      child = MarkdownBlock(
        data: content,
        config: MarkdownConfig(
          configs: [
            LinkConfig(
              onTap: (url) async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: TextStyle(
                color: scheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            PConfig(
              textStyle: TextStyle(
                fontSize: 16,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      );
    } else {
      child = Linkify(
        text: content,
        onOpen: (link) async {
          final uri = Uri.parse(link.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        options: const LinkifyOptions(humanize: false),
        linkStyle: TextStyle(color: scheme.primary),
        style: TextStyle(
          fontSize: 16,
          color: scheme.onSurface,
          height: 1.6,
        ),
      );
    }

    return Padding(padding: padding, child: child);
  }
}
