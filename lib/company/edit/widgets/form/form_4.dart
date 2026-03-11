import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Step 4: 검토 화면 — 입력한 정보를 요약하여 표시
class CompanyEditForm4 extends StatelessWidget {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewSection(
            icon: FontAwesomeIcons.buildingColumns,
            title: '기본 정보',
            items: [
              ('업소명', name.isNotEmpty ? name : '(미입력)'),
              ('카테고리', category.isNotEmpty ? category : '(미선택)'),
              ('한줄 소개', title.isNotEmpty ? title : '(미입력)'),
              if (description.isNotEmpty)
                (
                  '상세 설명',
                  description.length > 60
                      ? '${description.substring(0, 60)}…'
                      : description
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            icon: FontAwesomeIcons.locationDot,
            title: '위치 및 연락처',
            items: [
              if (location.isNotEmpty) ('지역', location),
              if (address.isNotEmpty) ('주소', address),
              if (phone.isNotEmpty) ('전화번호', phone),
              if (mobile.isNotEmpty) ('휴대폰', mobile),
              if (kakao.isNotEmpty) ('카카오톡', kakao),
              if (telegram.isNotEmpty) ('텔레그램', telegram),
              if ([location, address, phone, mobile, kakao, telegram]
                  .every((s) => s.isEmpty))
                ('', '연락처 정보가 없습니다'),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            icon: FontAwesomeIcons.image,
            title: '이미지',
            items: [
              (
                '로고',
                logoUrl != null && logoUrl!.isNotEmpty ? '등록됨' : '미등록'
              ),
              (
                '대표 이미지',
                titleImageUrl != null && titleImageUrl!.isNotEmpty
                    ? '등록됨'
                    : '미등록'
              ),
              (
                '추가 사진',
                photoUrl != null && photoUrl!.isNotEmpty ? '등록됨' : '미등록'
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.circleInfo,
                  size: 16,
                  color: Color(0xFFFF6D00),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '저장하면 관리자 검토 후 승인됩니다.\n업소명·카테고리·설명·이미지 변경 시 재심사가 필요합니다.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<(String, String)> items;

  const _ReviewSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
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
                FaIcon(icon, size: 14, color: scheme.primary),
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
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.$1.isNotEmpty) ...[
                      SizedBox(
                        width: 72,
                        child: Text(
                          item.$1,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item.$2,
                        style: const TextStyle(fontSize: 13),
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
