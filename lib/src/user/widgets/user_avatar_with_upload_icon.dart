import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_v6_flutter.dart';

class UserAvatarWithUploadIcon extends StatelessWidget {
  const UserAvatarWithUploadIcon({
    super.key,
    required this.user,
    this.size = 125.0,
    this.padding,
    this.alignment = Alignment.center,
    this.onTapDelete,
  });

  final User user;
  final double size;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final VoidCallback? onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            UserAvatar(
              user: user,
              size: size,
              alignment: Alignment.center,
              padding: padding,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FaIcon(FontAwesomeIcons.solidCamera, size: size / 4),
            ),
            if (user.photoUrl != null && user.photoUrl?.isEmpty == false)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    bool re = await showConfirmDialog(
                      message: PhilgoTr.of(context)!.want_to_delete,
                    );
                    if (re) {
                      onTapDelete?.call();
                    }
                  },
                  child: Container(
                    // 빨간색 원형 배경
                    width: size / 4,
                    height: size / 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                      // 테두리를 흰색으로 추가하여 이미지와 구분
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    // X 아이콘
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: size / 6, // 아이콘을 원형 안에 맞게 작게
                        color: Theme.of(
                          context,
                        ).colorScheme.onError, // 빨간 배경에 대비되는 색상 (보통 흰색)
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
