import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/image.upload.field.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 회사 연락처 정보 폼 섹션
/// Phone numbers, contact method, and messaging IDs
class FormContactInfo extends StatelessWidget {
  const FormContactInfo({
    super.key,
    required this.landlineController,
    required this.mobileNumberController,
    required this.mobileContactMethod,
    required this.onMobileContactMethodChanged,
    required this.kakaotalkIdController,
    required this.kakaotalkQrCodeController,
    required this.kakaoTalkQrCodeUrl,
    required this.onKakaoQrCodeSelected,
    required this.onKakaoQrCodeDelete,
    required this.onQrCodeDecoded,
    required this.telegramIdController,
  });

  final TextEditingController landlineController;
  final TextEditingController mobileNumberController;
  final String? mobileContactMethod;
  final ValueChanged<String?> onMobileContactMethodChanged;
  final TextEditingController kakaotalkIdController;
  final TextEditingController kakaotalkQrCodeController;
  final String kakaoTalkQrCodeUrl;
  final ValueChanged<String> onKakaoQrCodeSelected;
  final VoidCallback onKakaoQrCodeDelete;
  final ValueChanged<String?> onQrCodeDecoded;
  final TextEditingController telegramIdController;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 유선 전화번호
        TextFieldSet(
          controller: landlineController,
          label: '${T.phoneNumber} *',
          hintText: T.enterPhoneNumber,
          prefixFaIconData: FontAwesomeIcons.lightPhone,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        /// 휴대폰 번호
        TextFieldSet(
          controller: mobileNumberController,
          label: '${T.mobileNumber} *',
          hintText: T.enterMobileNumber,
          prefixFaIconData: FontAwesomeIcons.lightPhone,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        /// 모바일 연락 방법 선택 (문자/전화)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.mobileContactMethod,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
              ),
              SizedBox(height: sp.s8),
              RadioGroup<String>(
                groupValue: mobileContactMethod,
                onChanged: (value) {
                  onMobileContactMethodChanged(value);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(T.sendText),
                        value: 'text',
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(T.makeCall),
                        value: 'call',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: sp.s8),

        /// 카카오톡 ID
        TextFieldSet(
          controller: kakaotalkIdController,
          label: 'KakaoID',
          hintText: 'Enter kakaotalk ID',
          prefixFaIconData: FontAwesomeIcons.message,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        /// 카카오톡 QR 코드 업로드
        ImageUploadField(
          label: 'Upload Kakao QR Code',
          imageUrl: kakaoTalkQrCodeUrl,
          isDecodeQr: true,
          onImageSelected: onKakaoQrCodeSelected,
          onDelete: onKakaoQrCodeDelete,
          onQrCodeDecoded: onQrCodeDecoded,
        ),

        /// 카카오 채널 URL
        TextFieldSet(
          controller: kakaotalkQrCodeController,
          label: 'Kakao Channel URL',
          hintText: 'https://pf.kakao.com/...',
          prefixFaIconData: FontAwesomeIcons.message,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        /// 텔레그램 ID
        TextFieldSet(
          controller: telegramIdController,
          label: 'Telegram ID',
          hintText: "Enter Telegram ID",
          prefixFaIconData: FontAwesomeIcons.message,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ],
    );
  }
}
