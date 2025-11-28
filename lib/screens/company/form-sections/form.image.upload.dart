import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/image.upload.field.dart';
import 'package:philgo/widgets/information.box.dart';

/// 이미지 업로드 폼 섹션
/// All company image uploads
class FormImageUpload extends StatelessWidget {
  const FormImageUpload({
    super.key,
    required this.logoUrl,
    required this.onLogoSelected,
    required this.onLogoDelete,
    required this.businessLicenseUrl,
    required this.onBusinessLicenseSelected,
    required this.onBusinessLicenseDelete,
    required this.companyIntroImageUrl,
    required this.onCompanyIntroImageSelected,
    required this.onCompanyIntroImageDelete,
    required this.officeInteriorUrl,
    required this.onOfficeInteriorSelected,
    required this.onOfficeInteriorDelete,
  });

  final String logoUrl;
  final ValueChanged<String> onLogoSelected;
  final VoidCallback onLogoDelete;
  final String businessLicenseUrl;
  final ValueChanged<String> onBusinessLicenseSelected;
  final VoidCallback onBusinessLicenseDelete;
  final String companyIntroImageUrl;
  final ValueChanged<String> onCompanyIntroImageSelected;
  final VoidCallback onCompanyIntroImageDelete;
  final String officeInteriorUrl;
  final ValueChanged<String> onOfficeInteriorSelected;
  final VoidCallback onOfficeInteriorDelete;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 회사 로고 업로드
        ImageUploadField(
          label: "${T.companyLogo} *",
          imageUrl: logoUrl,
          onImageSelected: onLogoSelected,
          onDelete: onLogoDelete,
        ),

        /// 사업자 등록증 업로드
        ImageUploadField(
          label: T.businessLicense,
          imageUrl: businessLicenseUrl,
          onImageSelected: onBusinessLicenseSelected,
          onDelete: onBusinessLicenseDelete,
        ),

        /// 회사 소개 이미지 업로드
        ImageUploadField(
          label: T.companyIntroImage,
          imageUrl: companyIntroImageUrl,
          onImageSelected: onCompanyIntroImageSelected,
          onDelete: onCompanyIntroImageDelete,
        ),

        /// 소개 이미지 가이드라인
        InformationBox(
          message: T.companyIntroImageGuideline,
        ),

        SizedBox(height: sp.s8),

        /// 사무실/매장 내부 사진 업로드
        ImageUploadField(
          label: T.officeInteriorPhoto,
          imageUrl: officeInteriorUrl,
          onImageSelected: onOfficeInteriorSelected,
          onDelete: onOfficeInteriorDelete,
        ),

        /// 내부 사진 가이드라인
        InformationBox(message: T.officeInteriorGuideline),
      ],
    );
  }
}
