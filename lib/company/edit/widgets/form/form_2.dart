import 'package:flutter/material.dart';

/// Step 2: 위치 및 연락처 (지역, 주소, 전화, 핸드폰, 카카오, 텔레그램)
class CompanyEditForm2 extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController mobileController;
  final TextEditingController kakaoController;
  final TextEditingController telegramController;

  const CompanyEditForm2({
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
          _sectionLabel('지역'),
          const SizedBox(height: 8),
          TextFormField(
            controller: locationController,
            decoration: _inputDecoration('예: 마닐라, 세부, 다바오'),
          ),
          const SizedBox(height: 20),
          _sectionLabel('주소'),
          const SizedBox(height: 8),
          TextFormField(
            controller: addressController,
            decoration: _inputDecoration('상세 주소를 입력하세요'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _sectionLabel('전화번호'),
          const SizedBox(height: 8),
          TextFormField(
            controller: phoneController,
            decoration: _inputDecoration('예: +63-2-1234-5678'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _sectionLabel('휴대폰 번호'),
          const SizedBox(height: 8),
          TextFormField(
            controller: mobileController,
            decoration: _inputDecoration('예: +63-917-123-4567'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _sectionLabel('카카오톡 ID'),
          const SizedBox(height: 8),
          TextFormField(
            controller: kakaoController,
            decoration: _inputDecoration('카카오톡 오픈채팅 ID 또는 링크'),
          ),
          const SizedBox(height: 20),
          _sectionLabel('텔레그램 ID'),
          const SizedBox(height: 8),
          TextFormField(
            controller: telegramController,
            decoration: _inputDecoration('텔레그램 사용자명 또는 링크'),
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
