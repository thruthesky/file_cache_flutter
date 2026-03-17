import 'package:easy_localization/easy_localization.dart';
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

  const CompanyReviewForm({
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
    final hasContact = [
      location,
      address,
      phone,
      mobile,
      kakao,
      telegram,
    ].any((s) => s.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewCard(
            icon: FontAwesomeIcons.buildingColumns,
            title: '기본 정보'.tr(),
            rows: [
              _Row(
                '업소명'.tr(),
                name.isNotEmpty ? name : '(미입력)'.tr(),
                missing: name.isEmpty,
              ),
              _Row(
                '카테고리'.tr(),
                category.isNotEmpty ? category : '(미선택)'.tr(),
                missing: category.isEmpty,
              ),
              if (title.isNotEmpty) _Row('한줄 소개'.tr(), title),
              if (description.isNotEmpty)
                _Row(
                  '상세 설명'.tr(),
                  description.length > 80
                      ? '${description.substring(0, 80)}…'
                      : description,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ReviewCard(
            icon: FontAwesomeIcons.locationDot,
            title: '위치 및 연락처'.tr(),
            rows: hasContact
                ? [
                    if (location.isNotEmpty) _Row('지역'.tr(), location),
                    if (address.isNotEmpty) _Row('주소'.tr(), address),
                    if (phone.isNotEmpty) _Row('전화번호'.tr(), phone),
                    if (mobile.isNotEmpty) _Row('휴대폰'.tr(), mobile),
                    if (kakao.isNotEmpty) _Row('카카오톡'.tr(), kakao),
                    if (telegram.isNotEmpty) _Row('텔레그램'.tr(), telegram),
                  ]
                : [_Row('', '연락처 정보가 없습니다'.tr(), missing: true)],
          ),
          const SizedBox(height: 12),
          _ImageReviewCard(
            logoUrl: logoUrl,
            titleImageUrl: titleImageUrl,
            photoUrl: photoUrl,
          ),
          const SizedBox(height: 20),
          _InfoBanner(
            icon: FontAwesomeIcons.circleInfo,
            color: Theme.of(context).colorScheme.primary,
            text: '저장하면 관리자 검토 후 승인됩니다.\n업소명·카테고리·설명·이미지 변경 시 재심사가 필요합니다.'.tr(),
          ),
        ],
      ),
    );
  }
}

/// 이미지 섹션 카드 — 등록된 이미지는 썸네일로, 미등록은 텍스트로 표시
class _ImageReviewCard extends StatelessWidget {
  final String? logoUrl;
  final String? titleImageUrl;
  final String? photoUrl;

  const _ImageReviewCard({this.logoUrl, this.titleImageUrl, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      ('로고'.tr(), logoUrl, 1.0),
      ('대표 이미지'.tr(), titleImageUrl, 16 / 9),
      ('추가 사진'.tr(), photoUrl, 4 / 3),
    ];

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
                FaIcon(FontAwesomeIcons.image, size: 13, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '이미지'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final label = item.$1;
              final url = item.$2;
              final ratio = item.$3;
              final hasImage = url != null && url.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 56 * ratio,
                          height: 56,
                          child: Image.network(
                            url,
                            width: 56 * ratio,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, e, st) => Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 20,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        '미등록'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
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

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.rows,
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
            child: Text(text, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }
}
