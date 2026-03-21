import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (widget.isLoading) {
      return Padding(
        padding: widget.padding,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // 블라인드 처리된 글인 경우
    // Handle blinded posts differently based on ownership
    if (post.isBlinded) {
      final isMine = post.isMine(context);

      // 블라인드 경고 박스 위젯
      // Blinded warning box widget
      final warningBox = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: scheme.error.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 블라인드 경고 아이콘 및 제목
            /// Blind warning icon and title
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  color: scheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  PhilgoTr.of(context)?.blindedPost ?? '블라인드 처리된 글입니다',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            /// 본인 글인 경우에만 사유 표시
            /// Show reason only for owner's post
            if (isMine) ...[
              const SizedBox(height: 12),

              /// 블라인드 사유 표시
              /// Display blinding reason
              Text(
                '${PhilgoTr.of(context)?.blindReason ?? '사유'}: ${post.moderationReason ?? (PhilgoTr.of(context)?.blindedPostDescription ?? '커뮤니티 가이드라인 위반')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ],
        ),
      );

      /// 본인 글이 아닌 경우: 경고 박스만 표시
      /// For other's post: show only warning box
      if (!isMine) {
        return Padding(
          padding: widget.padding,
          child: warningBox,
        );
      }

      /// 본인 글인 경우: 경고 박스 + 글 내용 전체 표시
      /// For owner's post: show warning box + full content
      return Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            warningBox,
            const SizedBox(height: 16),

            /// 원본 글 내용 표시 (contentPrivate가 있으면 사용, 없으면 content 사용)
            /// Show original content (use contentPrivate if available, otherwise use content)
            _buildContentWidget(context, post.contentPrivate ?? content),
          ],
        ),
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
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
    return Padding(padding: widget.padding, child: child);
  }

  /// 콘텐츠 위젯 빌드 (HTML, Markdown, 일반 텍스트 지원)
  /// Build content widget (supports HTML, Markdown, plain text)
  Widget _buildContentWidget(BuildContext context, String contentText) {
    if (isHtml) {
      return Html(
        data: contentText,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          "a": Style(
            color: Theme.of(context).colorScheme.primary,
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
    } else if (isMarkdown) {
      return MarkdownBlock(
        data: contentText,
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
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
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
      return Linkify(
        text: contentText,
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
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
  }
}
