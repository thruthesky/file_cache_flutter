import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:philgo/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// 공용 마크다운 위젯
///
/// Info 상세 화면, 게시글 읽기 등 앱 전체에서 마크다운을 렌더링할 때 사용한다.
/// 테이블 동적 너비, 링크 클릭(tel/mailto 지원), 깔끔한 디자인을 통일 적용한다.
class AppMarkdown extends StatelessWidget {
  const AppMarkdown({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return MarkdownBlock(
      data: data,
      config: MarkdownConfig(
        configs: [
          PConfig(
            textStyle: text.bodyMedium?.copyWith(height: 1.6) ??
                const TextStyle(fontSize: 16, height: 1.6),
          ),
          H1Config(
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold) ??
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          H2Config(
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          H3Config(
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600) ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const HrConfig(height: 1),
          TableConfig(
            columnWidths: const {0: IntrinsicColumnWidth()},
            defaultColumnWidth: const FlexColumnWidth(),
            headerStyle: text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600, color: color.onSurface) ??
                const TextStyle(fontWeight: FontWeight.w600),
            bodyStyle: text.bodySmall
                    ?.copyWith(color: color.onSurfaceVariant, height: 1.4) ??
                const TextStyle(height: 1.4),
            border: TableBorder.all(
              color: color.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            headerRowDecoration: BoxDecoration(
              color: color.surfaceContainerLow,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            headPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            bodyPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          LinkConfig(
            style:
                TextStyle(color: color.primary, decoration: TextDecoration.none),
            onTap: (url) {
              final uri = Uri.tryParse(url);
              if (uri != null) {
                if (uri.scheme == 'tel' || uri.scheme == 'mailto') {
                  launchUrl(uri);
                } else {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
          const BlockquoteConfig(padding: EdgeInsets.all(12)),
          ListConfig(
            marker: (isOrdered, depth, index) {
              if (isOrdered) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6, top: 2),
                  child: Text(
                    '${index + 1}.',
                    style:
                        text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 6, top: 6),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
