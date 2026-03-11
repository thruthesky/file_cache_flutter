import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Step 4: 검토 화면 — 입력한 정보를 요약하여 표시
class CompanyReviewForm extends StatelessWidget {
  final String name;
  final String category;
  final String title;
  final String description;
  final String location;
  final String address;
  final String phone;
  final String mobile;
  final String kakao;
  final String telegram;
  final String? logoUrl;
  final String? titleImageUrl;
  final String? photoUrl;

  const CompanyEditForm4({
    super.key,
    required this.name,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.phone,
    required this.mobile,
    required this.kakao,
    required this.telegram,
    this.logoUrl,
    this.titleImageUrl,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasContact =
        [location, address, phone, mobile, kakao, telegram].any((s) => s.isNotEmpty);
    final hasImages = [logoUrl, titleImageUrl, photoUrl]
        .any((s) => s != null && s.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewCard(
            icon: FontAwesomeIcons.buildingColumns,
            title: '기본 정보',
            rows: [
              _Row('업소명', name.isNotEmpty ? name : '(미입력)', missing: name.isEmpty),
              _Row('카테고리', category.isNotEmpty ? category : '(미선택)',
                  missing: category.isEmpty),
              if (title.isNotEmpty) _Row('한줄 소개', title),
              if (description.isNotEmpty)
                _Row(
                  '상세 설명',
                  description.length > 80
                      ? '${description.substring(0, 80)}…'
                      : description,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ReviewCard(
            icon: FontAwesomeIcons.locationDot,
            title: '위치 및 연락처',
            rows: hasContact
                ? [
                    if (location.isNotEmpty) _Row('지역', location),
                    if (address.isNotEmpty) _Row('주소', address),
                    if (phone.isNotEmpty) _Row('전화번호', phone),
                    if (mobile.isNotEmpty) _Row('휴대폰', mobile),
                    if (kakao.isNotEmpty) _Row('카카오톡', kakao),
                    if (telegram.isNotEmpty) _Row('텔레그램', telegram),
                  ]
                : [_Row('', '연락처 정보가 없습니다', missing: true)],
          ),
          const SizedBox(height: 12),
          _ReviewCard(
            icon: FontAwesomeIcons.image,
            title: '이미지',
            rows: [
              _Row('로고', _imgStatus(logoUrl)),
              _Row('대표 이미지', _imgStatus(titleImageUrl)),
              _Row('추가 사진', _imgStatus(photoUrl)),
            ],
            trailing: hasImages
                ? null
                : Text(
                    '이미지 없음',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
          ),
          const SizedBox(height: 20),
          _InfoBanner(
            icon: FontAwesomeIcons.circleInfo,
            color: Theme.of(context).colorScheme.primary,
            text:
                '저장하면 관리자 검토 후 승인됩니다.\n업소명·카테고리·설명·이미지 변경 시 재심사가 필요합니다.',
          ),
        ],
      ),
    );
  }

  String _imgStatus(String? url) =>
      (url != null && url.isNotEmpty) ? '등록됨 ✓' : '미등록';
}

class _Row {
  final String key;
  final String value;
  final bool missing;
  const _Row(this.key, this.value, {this.missing = false});
}

class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_Row> rows;
  final Widget? trailing;

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.rows,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon, size: 13, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.key.isNotEmpty)
                      SizedBox(
                        width: 72,
                        child: Text(
                          row.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: row.missing ? Colors.grey[400] : null,
                          fontStyle: row.missing ? FontStyle.italic : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 15, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
