import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/info/info_post.model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Info 상세 화면
///
/// access_code를 받아 `info.getByAccessCode` API로 데이터를 조회하여 표시한다.
/// - 메타 정보(주소, 전화, 이메일 등)를 카드로 표시
/// - texts(text_1 JSON)의 각 항목을 기관/장소 정보 카드로 표시
/// - content(게시판/SEO용 마크다운)는 표시하지 않음
class InfoViewScreen extends StatefulWidget {
  static const String routeName = '/info/view';

  static void push(BuildContext ctx, {required String accessCode, String? title}) {
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
            FaIcon(FontAwesomeIcons.lightCircleExclamation, size: 48, color: color.error),
            const SizedBox(height: 16),
            Text('정보를 불러올 수 없습니다'.tr(), style: text.titleMedium),
            const SizedBox(height: 8),
            Text(_error!, style: text.bodySmall?.copyWith(color: color.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
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
            Text(info.name, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (info.englishName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(info.englishName, style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant)),
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
              child: Text(
                info.description,
                style: text.bodyMedium?.copyWith(height: 1.5, color: color.onSurface),
              ),
            ),
          ],

          // 상위 메타 정보 카드 (info 자체의 메타)
          if (_hasMetaInfo(info)) ...[
            const SizedBox(height: 16),
            _buildMetaCard(info),
          ],

          // texts 섹션 (text_1 JSON) — 각 항목을 카드로 표시
          if (info.texts.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...info.texts.map((item) => _buildTextItemCard(item)),
          ],
        ],
      ),
    );
  }

  /// texts 배열의 각 항목을 카드로 표시
  /// - Map이면 기관/장소 정보 카드
  /// - String이면 마크다운 섹션 카드
  Widget _buildTextItemCard(dynamic item) {
    if (item is Map<String, dynamic>) {
      return _buildInfoCard(InfoTextItem.fromMap(item));
    }
    if (item is String && item.trim().isNotEmpty) {
      return _buildMarkdownSectionCard(item);
    }
    return const SizedBox.shrink();
  }

  /// 기관/장소 정보 카드 (texts 항목이 Map인 경우)
  Widget _buildInfoCard(InfoTextItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 이름 + 아이콘/뱃지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                if (item.icon.isNotEmpty) ...[
                  Text(item.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (item.englishName.isNotEmpty)
                        Text(
                          item.englishName,
                          style: text.bodySmall?.copyWith(color: color.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                if (item.badge.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.badge,
                      style: text.labelSmall?.copyWith(color: color.onPrimaryContainer),
                    ),
                  ),
              ],
            ),
          ),

          // 본문: 메타 정보 행들
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description.isNotEmpty) ...[
                  Text(item.description, style: text.bodyMedium?.copyWith(height: 1.5)),
                  const SizedBox(height: 10),
                ],
                if (item.address.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightLocationDot, item.address),
                if (item.phone.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightPhone, item.phone, onTap: () {
                    launchUrl(Uri.parse('tel:${item.phone}'));
                  }),
                if (item.phone2.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightPhone, item.phone2, onTap: () {
                    launchUrl(Uri.parse('tel:${item.phone2}'));
                  }),
                if (item.fax.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightFax, item.fax),
                if (item.email.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightEnvelope, item.email, onTap: () {
                    launchUrl(Uri.parse('mailto:${item.email}'));
                  }),
                if (item.hours.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightClock, item.hours),
                if (item.detail.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightCircleInfo, item.detail),
                if (item.websiteUrl.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightGlobe, item.websiteUrl, onTap: () {
                    final uri = Uri.tryParse(item.websiteUrl);
                    if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
                  }),
                if (item.services.isNotEmpty)
                  _metaRow(FontAwesomeIcons.lightListCheck, item.services),
                if (item.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.tags.split(',').map((tag) {
                        final t = tag.trim();
                        if (t.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(t, style: text.labelSmall),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 마크다운 섹션 카드 (texts 항목이 String인 경우)
  Widget _buildMarkdownSectionCard(String section) {
    final lines = section.split('\n');
    String? heading;
    final bodyLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (heading == null && trimmed.startsWith('#')) {
        heading = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
      } else {
        bodyLines.add(line);
      }
    }
    while (bodyLines.isNotEmpty && bodyLines.first.trim().isEmpty) {
      bodyLines.removeAt(0);
    }
    while (bodyLines.isNotEmpty && bodyLines.last.trim().isEmpty) {
      bodyLines.removeLast();
    }
    final body = bodyLines.join('\n').trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null && heading.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Text(heading, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ),
          if (body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(body, style: text.bodyMedium?.copyWith(height: 1.6)),
            ),
        ],
      ),
    );
  }

  bool _hasMetaInfo(InfoPost info) {
    return info.address.isNotEmpty ||
        info.phone.isNotEmpty ||
        info.email.isNotEmpty ||
        info.hours.isNotEmpty ||
        info.websiteUrl.isNotEmpty;
  }

  /// 상위 메타 정보 카드
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
            _metaRow(FontAwesomeIcons.lightPhone, info.phone, onTap: () {
              launchUrl(Uri.parse('tel:${info.phone}'));
            }),
          if (info.phone2.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightPhone, info.phone2, onTap: () {
              launchUrl(Uri.parse('tel:${info.phone2}'));
            }),
          if (info.email.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightEnvelope, info.email, onTap: () {
              launchUrl(Uri.parse('mailto:${info.email}'));
            }),
          if (info.hours.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightClock, info.hours),
          if (info.websiteUrl.isNotEmpty)
            _metaRow(FontAwesomeIcons.lightGlobe, info.websiteUrl, onTap: () {
              final uri = Uri.tryParse(info.websiteUrl);
              if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
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
            child: FaIcon(icon, size: 14, color: color.onSurfaceVariant),
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
