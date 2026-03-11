import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          _sectionLabel('로고 이미지'),
          const SizedBox(height: 4),
          Text(
            '업소의 로고 또는 프로필 이미지',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildImagePicker(
            context,
            imageUrl: logoUrl,
            onPick: onPickLogo,
            icon: FontAwesomeIcons.image,
            hint: '로고 선택',
            aspectRatio: 1,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),
          _sectionLabel('대표 이미지'),
          const SizedBox(height: 4),
          Text(
            '목록 및 상단에 표시되는 메인 이미지',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildImagePicker(
            context,
            imageUrl: titleImageUrl,
            onPick: onPickTitleImage,
            icon: FontAwesomeIcons.panorama,
            hint: '대표 이미지 선택',
            aspectRatio: 16 / 9,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),
          _sectionLabel('추가 사진'),
          const SizedBox(height: 4),
          Text(
            '업소 내부, 메뉴, 분위기 사진 등',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildImagePicker(
            context,
            imageUrl: photoUrl,
            onPick: onPickPhoto,
            icon: FontAwesomeIcons.camera,
            hint: '사진 선택',
            aspectRatio: 4 / 3,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context, {
    String? imageUrl,
    VoidCallback? onPick,
    required IconData icon,
    required String hint,
    required double aspectRatio,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPick,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
            image: imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null || imageUrl.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: 32, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : Align(
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
                      child: const Text(
                        '변경',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}
