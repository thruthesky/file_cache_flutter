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
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 전화번호 필드 (필수)
        FormFieldLabel(label: T.phoneNumber, isRequired: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: landlineController,
          hintText: T.enterPhoneNumber,
        ),

        SizedBox(height: sp.s16),

        /// 휴대전화 번호 필드 (필수)
        FormFieldLabel(label: T.mobileNumber, isRequired: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: mobileNumberController,
          hintText: T.enterMobileNumber,
        ),

        SizedBox(height: sp.s16),

        /// 모바일 연락 방법 선택 (문자/전화)
        FormFieldLabel(label: T.mobileContactMethod, isOptional: true),
        SizedBox(height: sp.s8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: scheme.surfaceContainerLow,
          ),
          child: RadioGroup<String>(
            groupValue: mobileContactMethod,
            onChanged: (value) {
              onMobileContactMethodChanged(value);
            },
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      T.sendText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: 'text',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      T.makeCall,
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: 'call',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: sp.s24),

        /// 구분선: 선택 입력 영역
        _buildOptionalSectionDivider(theme, scheme),

        SizedBox(height: sp.s16),

        /// 카카오톡 ID 필드 (선택)
        FormFieldLabel(label: T.kakaoId, isOptional: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: kakaotalkIdController,
          hintText: T.enterKakaotalkId,
        ),

        SizedBox(height: sp.s16),

        /// 카카오톡 QR 코드 업로드 (선택)
        ImageUploadField(
          label: '${T.uploadKakaoQrCode} (${T.optional})',
          imageUrl: kakaoTalkQrCodeUrl,
          isDecodeQr: true,
          onImageSelected: onKakaoQrCodeSelected,
          onDelete: onKakaoQrCodeDelete,
          onQrCodeDecoded: onQrCodeDecoded,
        ),

        SizedBox(height: sp.s16),

        /// 카카오 채널 URL 필드 (선택)
        FormFieldLabel(label: T.kakaoChannelUrl, isOptional: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: kakaotalkQrCodeController,
          hintText: T.kakaoChannelUrlPlaceholder,
        ),

        SizedBox(height: sp.s16),

        /// 텔레그램 ID 필드 (선택)
        FormFieldLabel(label: T.telegramId, isOptional: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: telegramIdController,
          hintText: T.enterTelegramId,
        ),
      ],
    );
  }

  /// 선택 입력 영역 구분선
  Widget _buildOptionalSectionDivider(ThemeData theme, ColorScheme scheme) {
    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            T.optional,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: scheme.outlineVariant)),
      ],
    );
  }
}
