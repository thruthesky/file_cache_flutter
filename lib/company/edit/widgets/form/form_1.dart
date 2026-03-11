import 'package:flutter/material.dart';

/// Step 1: 기본 정보 (업소명, 카테고리, 한줄 소개, 상세 설명)
class CompanyEditForm1 extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  static const _categories = [
    ('public-office', '공공기관'),
    ('education', '교육'),
    ('food', '음식/식당'),
    ('transport', '교통'),
    ('hospital', '병원/의료'),
    ('mart', '쇼핑/마트'),
    ('bank', '은행/금융'),
    ('gadget', '전자/IT'),
    ('travel-agency', '여행사'),
    ('hotel', '호텔/숙박'),
    ('rentcar', '렌터카'),
    ('beauty', '미용/뷰티'),
    ('real-estate', '부동산'),
    ('ktv', '유흥/엔터'),
    ('spa', '스파/마사지'),
    ('etc', '기타'),
  ];

  const CompanyEditForm1({
    super.key,
    required this.nameController,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('업소명 *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: _inputDecoration('예: 필고 카페'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '업소명을 입력하세요' : null,
          ),
          const SizedBox(height: 20),
          _sectionLabel('카테고리 *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: _inputDecoration('카테고리 선택'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                .toList(),
            onChanged: onCategoryChanged,
            validator: (v) => v == null ? '카테고리를 선택하세요' : null,
          ),
          const SizedBox(height: 20),
          _sectionLabel('한줄 소개'),
          const SizedBox(height: 8),
          TextFormField(
            controller: titleController,
            decoration: _inputDecoration('예: 필리핀 최고의 한인 카페'),
            maxLength: 100,
          ),
          const SizedBox(height: 20),
          _sectionLabel('상세 설명'),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            decoration: _inputDecoration('업소에 대한 자세한 설명을 입력하세요'),
            maxLines: 5,
            maxLength: 2000,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
