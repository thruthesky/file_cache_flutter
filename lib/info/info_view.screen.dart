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
/// - texts(text_1 JSON)의 각 항목을 범용 키-값 렌더러로 자동 표시
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

  /// 잘 알려진 키 → 아이콘 매핑
  static const _knownKeyIcons = <String, IconData>{
    'phone': FontAwesomeIcons.lightPhone,
    'phone2': FontAwesomeIcons.lightPhone,
    'fax': FontAwesomeIcons.lightFax,
    'email': FontAwesomeIcons.lightEnvelope,
    'address': FontAwesomeIcons.lightLocationDot,
    'hours': FontAwesomeIcons.lightClock,
    'website': FontAwesomeIcons.lightGlobe,
    'website_url': FontAwesomeIcons.lightGlobe,
    'city': FontAwesomeIcons.lightCity,
    'detail': FontAwesomeIcons.lightCircleInfo,
    'services': FontAwesomeIcons.lightListCheck,
    'description': FontAwesomeIcons.lightAlignLeft,
  };

  /// 본문에서 숨길 키
  static const _hiddenKeys = {'name', 'english_name', 'icon', 'badge', 'tags'};

  /// 잘 알려진 키의 한글 라벨
  static const _knownKeyLabels = <String, String>{
    'phone': '전화',
    'phone2': '전화2',
    'fax': '팩스',
    'email': '이메일',
    'address': '주소',
    'hours': '운영시간',
    'website': '웹사이트',
    'website_url': '웹사이트',
    'city': '도시',
    'detail': '상세',
    'services': '서비스',
    'description': '설명',
  };

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

          // 상위 메타 정보 카드
          if (_hasMetaInfo(info)) ...[
            const SizedBox(height: 16),
            _buildTopMetaCard(info),
          ],

          // texts 섹션 — 각 항목을 범용 카드로 표시
          if (info.texts.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...info.texts.map((item) => _buildTextItemCard(item)),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // texts 항목 렌더링
  // ─────────────────────────────────────────────

  Widget _buildTextItemCard(dynamic item) {
    if (item is Map<String, dynamic>) {
      return _buildGenericMapCard(item);
    }
    if (item is String && item.trim().isNotEmpty) {
      return _buildMarkdownSectionCard(item);
    }
    return const SizedBox.shrink();
  }

  /// 범용 Map 카드 — 어떤 JSON 구조든 자동 렌더링
  Widget _buildGenericMapCard(Map<String, dynamic> map) {
    final name = _str(map['name']);
    final englishName = _str(map['english_name']);
    final icon = _str(map['icon']);
    final badge = _str(map['badge']);
    final tags = _str(map['tags']);

    // 잘 알려진 키를 먼저, 나머지를 뒤에 표시
    final knownOrder = _knownKeyIcons.keys.toList();
    final bodyEntries = map.entries
        .where((e) => !_hiddenKeys.contains(e.key) && _str(e.value).isNotEmpty)
        .toList();

    bodyEntries.sort((a, b) {
      final ai = knownOrder.indexOf(a.key);
      final bi = knownOrder.indexOf(b.key);
      final aIdx = ai >= 0 ? ai : knownOrder.length;
      final bIdx = bi >= 0 ? bi : knownOrder.length;
      return aIdx.compareTo(bIdx);
    });

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
          if (name.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  if (icon.isNotEmpty) ...[
                    Text(icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (englishName.isNotEmpty)
                          Text(englishName, style: text.bodySmall?.copyWith(color: color.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(badge, style: text.labelSmall?.copyWith(color: color.onPrimaryContainer)),
                    ),
                ],
              ),
            ),

          // 본문: 키-값 행들
          if (bodyEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in bodyEntries)
                    _buildKeyValueRow(entry.key, _str(entry.value)),
                ],
              ),
            ),

          // 태그
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).map((t) {
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
    );
  }

  /// 키-값 행 렌더링 — 잘 알려진 키는 아이콘+액션, 나머지는 라벨+값
  Widget _buildKeyValueRow(String key, String value) {
    final knownIcon = _knownKeyIcons[key];
    final isLink = _isLinkKey(key);

    VoidCallback? onTap;
    if (key == 'phone' || key == 'phone2') {
      onTap = () => launchUrl(Uri.parse('tel:$value'));
    } else if (key == 'email') {
      onTap = () => launchUrl(Uri.parse('mailto:$value'));
    } else if (key == 'website' || key == 'website_url') {
      onTap = () {
        final uri = Uri.tryParse(value);
        if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
      };
    }

    if (knownIcon != null) {
      return _iconRow(knownIcon, value, onTap: onTap);
    }

    // 알려지지 않은 키 → 라벨: 값 형태
    final label = _humanizeKey(key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: text.bodySmall?.copyWith(
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () {
                      final uri = Uri.tryParse(value);
                      if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Text(value, style: text.bodySmall?.copyWith(color: color.primary, height: 1.4)),
                  )
                : Text(value, style: text.bodySmall?.copyWith(color: color.onSurface, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 마크다운 섹션 카드 (texts 항목이 String인 경우)
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // 상위 메타 카드 + 헬퍼
  // ─────────────────────────────────────────────

  bool _hasMetaInfo(InfoPost info) {
    return info.address.isNotEmpty ||
        info.phone.isNotEmpty ||
        info.email.isNotEmpty ||
        info.hours.isNotEmpty ||
        info.websiteUrl.isNotEmpty;
  }

  Widget _buildTopMetaCard(InfoPost info) {
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
            _iconRow(FontAwesomeIcons.lightLocationDot, info.address),
          if (info.phone.isNotEmpty)
            _iconRow(FontAwesomeIcons.lightPhone, info.phone,
                onTap: () => launchUrl(Uri.parse('tel:${info.phone}'))),
          if (info.phone2.isNotEmpty)
            _iconRow(FontAwesomeIcons.lightPhone, info.phone2,
                onTap: () => launchUrl(Uri.parse('tel:${info.phone2}'))),
          if (info.email.isNotEmpty)
            _iconRow(FontAwesomeIcons.lightEnvelope, info.email,
                onTap: () => launchUrl(Uri.parse('mailto:${info.email}'))),
          if (info.hours.isNotEmpty)
            _iconRow(FontAwesomeIcons.lightClock, info.hours),
          if (info.websiteUrl.isNotEmpty)
            _iconRow(FontAwesomeIcons.lightGlobe, info.websiteUrl, onTap: () {
              final uri = Uri.tryParse(info.websiteUrl);
              if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
            }),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String value, {VoidCallback? onTap}) {
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
    if (onTap != null) return GestureDetector(onTap: onTap, child: row);
    return row;
  }

  // ─────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────

  static String _str(dynamic value) => value?.toString() ?? '';

  bool _isLinkKey(String key) =>
      key.contains('url') || key.contains('website') || key.contains('link');

  /// snake_case 키를 사람이 읽을 수 있는 라벨로 변환
  String _humanizeKey(String key) {
    final label = _knownKeyLabels[key];
    if (label != null) return label;
    return key.replaceAll('_', ' ').replaceFirstMapped(
      RegExp(r'^.'),
      (m) => m.group(0)!.toUpperCase(),
    );
  }
}
