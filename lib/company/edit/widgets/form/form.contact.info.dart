import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'form_shared.dart';

/// Step 2: 위치 및 연락처
class CompanyContactInfoForm extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController mobileController;
  final TextEditingController kakaoController;
  final TextEditingController telegramController;

  const CompanyContactInfoForm({
    super.key,
    required this.locationController,
    required this.addressController,
    required this.phoneController,
    required this.mobileController,
    required this.kakaoController,
    required this.telegramController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, FontAwesomeIcons.locationDot, '위치'.tr()),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '지역'.tr(),
            child: TextFormField(
              controller: locationController,
              decoration: formInputDecoration('예: 마닐라, 세부, 다바오'.tr()),
            ),
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '주소'.tr(),
            child: TextFormField(
              controller: addressController,
              decoration: formInputDecoration('상세 주소를 입력하세요'.tr()),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle(context, FontAwesomeIcons.addressBook, '연락처'.tr()),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '전화번호'.tr(),
            child: TextFormField(
              controller: phoneController,
              decoration: formInputDecoration('예: +63-2-1234-5678'),
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '휴대폰 번호'.tr(),
            child: TextFormField(
              controller: mobileController,
              decoration: formInputDecoration('예: +63-917-123-4567'.tr()),
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle(context, FontAwesomeIcons.commentDots, '메신저'.tr()),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '카카오톡 ID'.tr(),
            child: TextFormField(
              controller: kakaoController,
              decoration: formInputDecoration('오픈채팅 ID 또는 링크'.tr()),
            ),
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '텔레그램 ID'.tr(),
            child: TextFormField(
              controller: telegramController,
              decoration: formInputDecoration('사용자명 또는 링크'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        FaIcon(icon, size: 14, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: scheme.outlineVariant)),
      ],
    );
  }
}
