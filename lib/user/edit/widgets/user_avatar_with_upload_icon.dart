import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:philgo/file_upload/widgets/file_upload.dart';
import 'package:philgo/file_upload/file_upload.model.dart';
import 'package:philgo/user/widgets/avatar.dart';

/// 프로필 사진 아바타 + 업로드 아이콘 위젯
///
/// - 전체 영역 탭 시 사진 업로드 (카메라/갤러리)
/// - 사진이 있을 경우 삭제 버튼(우상단) 표시
class UserAvatarWithUploadIcon extends StatelessWidget {
  const UserAvatarWithUploadIcon({
    super.key,
    required this.photoUrl,
    this.size = 125.0,
    this.onUploaded,
    this.onTapDelete,
  });

  final String? photoUrl;
  final double size;
  final void Function(FileUploadModel model)? onUploaded;
  final VoidCallback? onTapDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: FileUpload(
        module: 'user',
        code: 'profile_photo',
        camera: true,
        gallery: true,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        onUploaded: onUploaded,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 프로필 아바타
            Avatar(photoUrl: photoUrl, size: size, radius: size / 2),

            // 카메라 아이콘 (우하단) — 탭 이벤트는 FileUpload가 처리
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size / 4,
                height: size / 4,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.solidCamera,
                    size: size / 7,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),

            // 삭제 버튼 (우상단) — 사진이 있을 때만 표시
            if (photoUrl != null && photoUrl!.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapDelete,
                  child: Container(
                    width: size / 4,
                    height: size / 4,
                    decoration: BoxDecoration(
                      color: scheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: size / 6,
                        color: scheme.onError,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
