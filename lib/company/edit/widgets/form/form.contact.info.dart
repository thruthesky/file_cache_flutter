import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'form_shared.dart';

/// Step 2: 위치 및 연락처
///
/// 카카오톡 QR 코드 이미지 업로드 시 자동으로 QR을 디코딩하여
/// 카카오톡 채널 URL 필드에 자동 입력한다.
class CompanyContactInfoForm extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController mobileController;
  final TextEditingController kakaoController;
  final TextEditingController telegramController;
  final TextEditingController kakaoChannelUrlController;
  final String? kakaoQrCodeUrl;
  final ValueChanged<String> onKakaoQrCodeUploaded;

  const CompanyContactInfoForm({
    super.key,
    required this.locationController,
    required this.addressController,
    required this.phoneController,
    required this.mobileController,
    required this.kakaoController,
    required this.telegramController,
    required this.kakaoChannelUrlController,
    this.kakaoQrCodeUrl,
    required this.onKakaoQrCodeUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Location"
          _sectionTitle(context, FontAwesomeIcons.locationDot, '위치'.tr()),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "Area"
            label: '지역'.tr(),
            child: TextFormField(
              controller: locationController,
              // "e.g. Manila, Cebu, Davao"
              decoration: formInputDecoration('예: 마닐라, 세부, 다바오'.tr()),
            ),
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "Address"
            label: '주소'.tr(),
            child: TextFormField(
              controller: addressController,
              // "Enter detailed address"
              decoration: formInputDecoration('상세 주소를 입력하세요'.tr()),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 28),
          // "Contact"
          _sectionTitle(context, FontAwesomeIcons.addressBook, '연락처'.tr()),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "Phone"
            label: '전화번호'.tr(),
            child: TextFormField(
              controller: phoneController,
              decoration: formInputDecoration('예: +63-2-1234-5678'),
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "Mobile Number"
            label: '휴대폰 번호'.tr(),
            child: TextFormField(
              controller: mobileController,
              // "e.g. +63-917-123-4567"
              decoration: formInputDecoration('예: +63-917-123-4567'.tr()),
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 28),
          // "Messenger"
          _sectionTitle(context, FontAwesomeIcons.commentDots, '메신저'.tr()),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "KakaoTalk ID"
            label: '카카오톡 ID'.tr(),
            child: TextFormField(
              controller: kakaoController,
              // "Open chat ID or link"
              decoration: formInputDecoration('오픈채팅 ID 또는 링크'.tr()),
            ),
          ),
          const SizedBox(height: 16),
          _KakaoQrUploadField(
            imageUrl: kakaoQrCodeUrl,
            onUploaded: onKakaoQrCodeUploaded,
            onQrDecoded: (decoded) {
              if (decoded != null && decoded.isNotEmpty) {
                kakaoChannelUrlController.text = decoded;
              }
            },
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "KakaoTalk Channel URL"
            label: '카카오톡 채널 URL'.tr(),
            // "Auto-filled when QR image is uploaded"
            hint: 'QR 이미지 업로드 시 자동 입력됩니다'.tr(),
            child: TextFormField(
              controller: kakaoChannelUrlController,
              decoration: formInputDecoration('https://open.kakao.com/...'),
            ),
          ),
          const SizedBox(height: 16),
          FormFieldLabel(
            // "Telegram ID"
            label: '텔레그램 ID'.tr(),
            child: TextFormField(
              controller: telegramController,
              // "Username or link"
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

/// 카카오톡 QR 코드 이미지 업로드 필드
///
/// 이미지 업로드 후 mobile_scanner를 사용하여 QR 코드를 자동 디코딩한다.
class _KakaoQrUploadField extends StatefulWidget {
  final String? imageUrl;
  final ValueChanged<String> onUploaded;
  final ValueChanged<String?> onQrDecoded;

  const _KakaoQrUploadField({
    this.imageUrl,
    required this.onUploaded,
    required this.onQrDecoded,
  });

  @override
  State<_KakaoQrUploadField> createState() => _KakaoQrUploadFieldState();
}

class _KakaoQrUploadFieldState extends State<_KakaoQrUploadField> {
  late String? _url;
  bool _isUploading = false;
  String? _lastPickedFilePath;

  @override
  void initState() {
    super.initState();
    _url = widget.imageUrl;
  }

  Future<void> _tryDecodeQr(String filePath) async {
    final controller = MobileScannerController(
      autoStart: false,
      formats: [BarcodeFormat.qrCode],
    );
    final result = await controller.analyzeImage(filePath);
    await controller.dispose();
    if (result != null && result.barcodes.isNotEmpty) {
      final decoded = result.barcodes.first.rawValue;
      log('[KakaoQR] Decoded QR: $decoded');
      widget.onQrDecoded(decoded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = _url != null && _url!.isNotEmpty;

    return FormFieldLabel(
      // "KakaoTalk QR Code", "Optional"
      label: '${'카카오톡 QR 코드'.tr()} (${'선택'.tr()})',
      // "Channel URL will be auto-filled when QR image is uploaded"
      hint: 'QR 이미지를 업로드하면 채널 URL이 자동 입력됩니다'.tr(),
      child: Stack(
        children: [
          FileUpload(
            camera: true,
            cameraVideo: false,
            file: false,
            gallery: true,
            module: 'company',
            code: 'kakaotalk_qr_code',
            onBeforeUpload: () async {
              if (_url != null && _url!.isNotEmpty) {
                await ApiService.instance.fileDeleteByUrl(_url!);
              }
              return true;
            },
            onUploadingChanged: (uploading) {
              if (mounted) setState(() => _isUploading = uploading);
            },
            onUploaded: (model) {
              setState(() => _url = model.url);
              widget.onUploaded(model.url);
              // QR 디코딩은 로컬 파일에서 시도
              if (_lastPickedFilePath != null) {
                _tryDecodeQr(_lastPickedFilePath!);
              }
            },
            onError: (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    // "Upload failed: {}"
                    '업로드 실패: {}'.tr(
                      args: [e.toString().replaceFirst('Exception: ', '')],
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border:
                    hasImage ? null : Border.all(color: scheme.outlineVariant),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(_url!), fit: BoxFit.contain)
                    : null,
              ),
              child: hasImage
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(FontAwesomeIcons.penToSquare,
                                  size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              // "Change"
                              Text('변경'.tr(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.lightQrcode,
                            size: 28, color: scheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        // "Upload KakaoTalk QR Image"
                        Text('카카오톡 QR 이미지 업로드'.tr(),
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        // "Tap to select"
                        Text('탭하여 선택'.tr(),
                            style: TextStyle(
                                fontSize: 11, color: scheme.outlineVariant)),
                      ],
                    ),
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (hasImage && !_isUploading)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  final urlToDelete = _url;
                  setState(() => _url = null);
                  widget.onUploaded('');
                  if (urlToDelete != null && urlToDelete.isNotEmpty) {
                    await ApiService.instance.fileDeleteByUrl(urlToDelete);
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.xmark,
                        size: 13, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
