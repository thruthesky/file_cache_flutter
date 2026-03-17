import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'form_shared.dart';

/// Step 3: 이미지 업로드 (로고, 대표 이미지, 추가 사진)
///
/// FileUpload 위젯으로 카메라/갤러리에서 선택 후 서버에 업로드한다.
/// 업로드 완료 시 onXxxUploaded 콜백으로 URL을 상위에 전달한다.
class CompanyImageUploadForm extends StatelessWidget {
  final String? logoUrl;
  final String? titleImageUrl;
  final String? photoUrl;
  final ValueChanged<String> onLogoUploaded;
  final ValueChanged<String> onTitleImageUploaded;
  final ValueChanged<String> onPhotoUploaded;

  const CompanyImageUploadForm({
    super.key,
    this.logoUrl,
    this.titleImageUrl,
    this.photoUrl,
    required this.onLogoUploaded,
    required this.onTitleImageUploaded,
    required this.onPhotoUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormFieldLabel(
            label: '로고 이미지'.tr(),
            hint: '업소의 로고 또는 프로필 이미지'.tr(),
            child: _UploadTile(
              imageUrl: logoUrl,
              icon: FontAwesomeIcons.image,
              hint: '로고 선택'.tr(),
              aspectRatio: 1,
              module: 'company',
              code: 'logo',
              onUploaded: onLogoUploaded,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '대표 이미지'.tr(),
            hint: '목록 및 상단에 표시되는 메인 이미지'.tr(),
            child: _UploadTile(
              imageUrl: titleImageUrl,
              icon: FontAwesomeIcons.panorama,
              hint: '대표 이미지 선택'.tr(),
              aspectRatio: 16 / 9,
              module: 'company',
              code: 'title_image',
              onUploaded: onTitleImageUploaded,
            ),
          ),
          const SizedBox(height: 24),
          FormFieldLabel(
            label: '추가 사진'.tr(),
            hint: '업소 내부, 메뉴, 분위기 사진 등'.tr(),
            child: _UploadTile(
              imageUrl: photoUrl,
              icon: FontAwesomeIcons.camera,
              hint: '사진 선택'.tr(),
              aspectRatio: 4 / 3,
              module: 'company',
              code: 'photo',
              onUploaded: onPhotoUploaded,
            ),
          ),
        ],
      ),
    );
  }
}

/// 개별 이미지 업로드 타일
///
/// FileUpload 위젯으로 감싸 탭 시 카메라/갤러리 선택 시트를 표시한다.
/// 업로드 중에는 반투명 오버레이 + 로딩 인디케이터가 표시된다.
class _UploadTile extends StatefulWidget {
  final String? imageUrl;
  final IconData icon;
  final String hint;
  final double aspectRatio;
  final String module;
  final String code;
  final ValueChanged<String> onUploaded;

  const _UploadTile({
    this.imageUrl,
    required this.icon,
    required this.hint,
    required this.aspectRatio,
    required this.module,
    required this.code,
    required this.onUploaded,
  });

  @override
  State<_UploadTile> createState() => _UploadTileState();
}

class _UploadTileState extends State<_UploadTile> {
  late String? _url;

  @override
  void initState() {
    super.initState();
    _url = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = _url != null && _url!.isNotEmpty;

    Widget tileContent;
    if (hasImage) {
      tileContent = Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.penToSquare,
                    size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text('변경'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    } else {
      tileContent = Column(
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
              child: FaIcon(widget.icon,
                  size: 22, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.hint,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '탭하여 선택'.tr(),
            style: TextStyle(fontSize: 11, color: scheme.outlineVariant),
          ),
        ],
      );
    }

    final tile = AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: hasImage ? null : Border.all(color: scheme.outlineVariant),
          image: hasImage
              ? DecorationImage(image: NetworkImage(_url!), fit: BoxFit.cover)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: tileContent,
        ),
      ),
    );

    // Wrap in Stack: FileUpload covers the tile, delete button sits on top-right
    return Stack(
      children: [
        FileUpload(
          module: widget.module,
          code: widget.code,
          onUploaded: (model) {
            setState(() => _url = model.url);
            widget.onUploaded(model.url);
          },
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '업로드 실패: {}'.tr(args: [e.toString().replaceFirst('Exception: ', '')])),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: tile,
        ),
        if (hasImage)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() => _url = null);
                widget.onUploaded('');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('사진이 삭제되었습니다'.tr())),
                );
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
