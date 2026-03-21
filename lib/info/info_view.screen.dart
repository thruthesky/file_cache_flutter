import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/info/info_post.model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Info 상세 화면
///
/// access_code를 받아 `info.getByAccessCode` API로 데이터를 조회하여 표시한다.
/// content(마크다운 본문) + 메타 정보(주소/전화/이메일/웹사이트 등)를 표시한다.
class InfoViewScreen extends StatefulWidget {
  static const String routeName = '/info/view';

  static void push(BuildContext ctx,
      {required String accessCode, String? title}) {
    ctx.push('$routeName?access_code=$accessCode', extra: title);
  }

  final String accessCode;
  final String? title;

  const InfoViewScreen({super.key, required this.accessCode, this.title});

  @override
  State<InfoViewScreen> createState() => _InfoViewScreenState();
}

class _InfoViewScreenState extends State<InfoViewScreen> {
  InfoPost? _info;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final res = await ApiService.instance.v7api<Map<String, dynamic>>(
        'info.getByAccessCode',
        data: {'access_code': widget.accessCode},
      );
      if (!mounted) return;
      setState(() {
        _info = InfoPost.fromJson(res);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? _info?.name ?? '정보'.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _info != null
                  ? _buildContent()
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.lightCircleExclamation,
                size: 48, color: color.error),
            const SizedBox(height: 16),
            Text('정보를 불러올 수 없습니다'.tr(), style: text.titleMedium),
            const SizedBox(height: 8),
            Text(_error!,
                style:
                    text.bodySmall?.copyWith(color: color.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadInfo();
              },
              child: Text('다시 시도'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final info = _info!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 + 영문명
          if (info.name.isNotEmpty)
            Text(info.name,
                style: text.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          if (info.englishName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(info.englishName,
                style: text.bodyMedium
                    ?.copyWith(color: color.onSurfaceVariant)),
          ],
          // 한줄 소개
          if (info.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(info.title, style: text.bodyLarge),
          ],
          // 요약 설명
          if (info.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(info.description,
                  style: text.bodyMedium?.copyWith(height: 1.5)),
            ),
          ],
          // 메타 정보 카드 (주소, 전화, 이메일, 웹사이트 등)
          if (_hasMetaInfo(info)) ...[
            const SizedBox(height: 16),
            _buildMetaCard(info),
          ],
          // content 마크다운 본문
          if (info.content.isNotEmpty) ...[
            const SizedBox(height: 16),
            MarkdownBlock(
              data: info.content,
              config: MarkdownConfig(
                configs: [
                  PConfig(
                      textStyle: text.bodyMedium?.copyWith(height: 1.6) ??
                          const TextStyle()),
                  H1Config(
                      style: text.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold) ??
                          const TextStyle()),
                  H2Config(
                      style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold) ??
                          const TextStyle()),
                  H3Config(
                      style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600) ??
                          const TextStyle()),
                  const HrConfig(height: 1),
                  TableConfig(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                    },
                    defaultColumnWidth: const FlexColumnWidth(),
                    headerStyle: text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color.onSurface) ??
                        const TextStyle(),
                    bodyStyle: text.bodySmall?.copyWith(
                            color: color.onSurfaceVariant, height: 1.4) ??
                        const TextStyle(),
                    border: TableBorder.all(
                      color: color.outlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    headerRowDecoration: BoxDecoration(
                      color: color.surfaceContainerLow,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8)),
                    ),
                    headPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    bodyPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  LinkConfig(
                    style: TextStyle(
                        color: color.primary, decoration: TextDecoration.none),
                    onTap: (url) {
                      final uri = Uri.tryParse(url);
                      if (uri != null) {
                        if (uri.scheme == 'tel' || uri.scheme == 'mailto') {
                          launchUrl(uri);
                        } else {
                          launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                  ),
                  const BlockquoteConfig(
                    padding: EdgeInsets.all(12),
                  ),
                  ListConfig(
                    marker: (isOrdered, depth, index) {
                      if (isOrdered) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6, top: 2),
                          child: Text('${index + 1}.',
                              style: text.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
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
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 메타 정보 카드
  // ═══════════════════════════════════════════════

  bool _hasMetaInfo(InfoPost info) =>
      info.address.isNotEmpty ||
      info.phone.isNotEmpty ||
      info.email.isNotEmpty ||
      info.hours.isNotEmpty ||
      info.websiteUrl.isNotEmpty;

  Widget _buildMetaCard(InfoPost info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (info.address.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightLocationDot, info.address),
          if (info.phone.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightPhone, info.phone,
                onTap: () => launchUrl(Uri.parse('tel:${info.phone}'))),
          if (info.phone2.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightPhone, info.phone2,
                onTap: () => launchUrl(Uri.parse('tel:${info.phone2}'))),
          if (info.email.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightEnvelope, info.email,
                onTap: () => launchUrl(Uri.parse('mailto:${info.email}'))),
          if (info.hours.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightClock, info.hours),
          if (info.websiteUrl.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightGlobe, info.websiteUrl,
                onTap: () {
              final uri = Uri.tryParse(info.websiteUrl);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String value, {VoidCallback? onTap}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child:
                FaIcon(icon, size: 14, color: color.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: text.bodySmall?.copyWith(
                color: onTap != null ? color.primary : color.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: row);
    }
    return row;
  }
}
