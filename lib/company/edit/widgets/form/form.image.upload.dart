import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'form_shared.dart';

/// Step 3: 이미지 업로드 (로고, 대표 이미지, 추가 사진)
class CompanyEditForm3 extends StatelessWidget {
  final String? logoUrl;
  final String? titleImageUrl;
  final String? photoUrl;
  final VoidCallback? onPickLogo;
  final VoidCallback? onPickTitleImage;
  final VoidCallback? onPickPhoto;

  const CompanyEditForm3({
    super.key,
    this.logoUrl,
    this.titleImageUrl,
    this.photoUrl,
    this.onPickLogo,
    this.onPickTitleImage,
    this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormFieldLabel(
            label: '로고 이미지',
            hint: '업소의 로고 또는 프로필 이미지',
            child: _ImagePickerTile(
              imageUrl: logoUrl,
              onPick: onPickLogo,
              icon: FontAwesomeIcons.image,
              hint: '로고 선택',
              aspectRatio: 1,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '대표 이미지',
            hint: '목록 및 상단에 표시되는 메인 이미지',
            child: _ImagePickerTile(
              imageUrl: titleImageUrl,
              onPick: onPickTitleImage,
              icon: FontAwesomeIcons.panorama,
              hint: '대표 이미지 선택',
              aspectRatio: 16 / 9,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '추가 사진',
            hint: '업소 내부, 메뉴, 분위기 사진 등',
            child: _ImagePickerTile(
              imageUrl: photoUrl,
              onPick: onPickPhoto,
              icon: FontAwesomeIcons.camera,
              hint: '사진 선택',
              aspectRatio: 4 / 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onPick;
  final IconData icon;
  final String hint;
  final double aspectRatio;

  const _ImagePickerTile({
    this.imageUrl,
    this.onPick,
    required this.icon,
    required this.hint,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onPick,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.outlineVariant,
              style: hasImage ? BorderStyle.none : BorderStyle.solid,
            ),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
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
                        children: const [
                          FaIcon(FontAwesomeIcons.penToSquare,
                              size: 11, color: Colors.white),
                          SizedBox(width: 4),
                          Text('변경',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Center(
                        child: FaIcon(icon,
                            size: 22, color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hint,
                      style: TextStyle(
                          fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '탭하여 선택',
                      style: TextStyle(
                          fontSize: 11, color: scheme.outlineVariant),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
