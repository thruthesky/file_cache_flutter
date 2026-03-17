import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'form_shared.dart';

/// Step 1: 기본 정보 (업소명, 카테고리, 한줄 소개, 상세 설명)
class CompanyBasicInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  static const _categories = [
    ('public-office', 'Public\nOffice', FontAwesomeIcons.building),
    ('education', 'Education', FontAwesomeIcons.graduationCap),
    ('food', 'Food', FontAwesomeIcons.utensils),
    ('transport', 'Transport', FontAwesomeIcons.bus),
    ('hospital', 'Health', FontAwesomeIcons.hospital),
    ('mart', 'Shopping', FontAwesomeIcons.cartShopping),
    ('bank', 'Banking', FontAwesomeIcons.buildingColumns),
    ('gadget', 'Gadgets', FontAwesomeIcons.mobileScreen),
    ('travel-agency', 'Travel', FontAwesomeIcons.planeDeparture),
    ('hotel', 'Hotels', FontAwesomeIcons.hotel),
    ('rentcar', 'Car Rent', FontAwesomeIcons.car),
    ('beauty', 'Beauty', FontAwesomeIcons.scissors),
    ('real-estate', 'Real\nEstate', FontAwesomeIcons.houseChimney),
    ('ktv', 'Entertain', FontAwesomeIcons.microphone),
    ('spa', 'Spa', FontAwesomeIcons.spa),
    ('etc', 'Other', FontAwesomeIcons.ellipsis),
  ];

  const CompanyBasicInfoForm({
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
          FormFieldLabel(
            label: '업소명'.tr(),
            required: true,
            child: TextFormField(
              controller: nameController,
              decoration: _inputDecoration('예: 필고 카페'.tr()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '업소명을 입력하세요'.tr() : null,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '카테고리'.tr(),
            required: true,
            child: _CategoryGrid(
              selected: selectedCategory,
              onSelected: onCategoryChanged,
              categories: _categories,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '한줄 소개'.tr(),
            child: TextFormField(
              controller: titleController,
              decoration: _inputDecoration('예: 필리핀 최고의 한인 카페'.tr()),
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '상세 설명'.tr(),
            child: TextFormField(
              controller: descriptionController,
              decoration: _inputDecoration(
                '업소에 대한 자세한 설명을 입력하세요'.tr(),
              ).copyWith(alignLabelWithHint: true),
              maxLines: 5,
              maxLength: 2000,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

/// Category grid widget — icon + label tiles, 4 per row
class _CategoryGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  final List<(String, String, IconData)> categories;

  const _CategoryGrid({
    required this.selected,
    required this.onSelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = scheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 4;
        const spacing = 8.0;
        final tileSize =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categories.map((cat) {
            final (id, label, icon) = cat;
            final isSelected = selected == id;

            return GestureDetector(
              onTap: () => onSelected(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.12)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? activeColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      size: 20,
                      color: isSelected
                          ? activeColor
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.2,
                        color: isSelected ? activeColor : scheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

