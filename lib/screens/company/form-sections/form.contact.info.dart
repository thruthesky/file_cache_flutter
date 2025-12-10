import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/form-sections/form_field_label.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/image.upload.field.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';

/// 회사 연락처 정보 폼 섹션 - Comic Design
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Comic Design: Phone Number Field
        FormFieldLabel(label: T.phoneNumber, isRequired: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: landlineController,
          hintText: T.enterPhoneNumber,
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Mobile Number Field
        FormFieldLabel(label: T.mobileNumber, isRequired: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: mobileNumberController,
          hintText: T.enterMobileNumber,
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Mobile Contact Method Selection
        FormFieldLabel(label: T.mobileContactMethod),
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

        SizedBox(height: sp.s16),

        /// Comic Design: KakaoTalk ID Field
        FormFieldLabel(label: T.kakaoId),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: kakaotalkIdController,
          hintText: T.enterKakaotalkId,
        ),

        SizedBox(height: sp.s16),

        /// 카카오톡 QR 코드 업로드
        ImageUploadField(
          label: T.uploadKakaoQrCode,
          imageUrl: kakaoTalkQrCodeUrl,
          isDecodeQr: true,
          onImageSelected: onKakaoQrCodeSelected,
          onDelete: onKakaoQrCodeDelete,
          onQrCodeDecoded: onQrCodeDecoded,
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Kakao Channel URL Field
        FormFieldLabel(label: T.kakaoChannelUrl),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: kakaotalkQrCodeController,
          hintText: T.kakaoChannelUrlPlaceholder,
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Telegram ID Field
        FormFieldLabel(label: T.telegramId),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: telegramIdController,
          hintText: T.enterTelegramId,
        ),
      ],
    );
  }
}
