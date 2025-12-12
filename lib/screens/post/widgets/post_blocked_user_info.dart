import 'package:flutter/material.dart';

import 'package:philgo_api/philgo_api.dart';

/// 차단된 사용자의 게시글 정보를 표시하는 위젯
///
/// 게시글 읽기 화면에서 차단된 사용자의 게시글을 표시할 때 사용됩니다.
/// 탭하면 차단 해제 다이얼로그가 표시됩니다.
///
/// ### 매개변수:
/// - [photoUrl] → 사용자 프로필 사진 URL
/// - [nickname] → 사용자 닉네임
/// - [firebaseUid] → Firebase UID (차단 해제에 필요)
///
/// ### 예시:
/// ```dart
/// PostBlockedUserInfo(
///   photoUrl: 'https://example.com/photo.jpg',
///   nickname: '홍길동',
///   firebaseUid: 'abc123',
/// )
/// ```
class PostBlockedUserInfo extends StatelessWidget {
  /// 사용자 프로필 사진 URL (nullable - 없을 수 있음)
  final String? photoUrl;

  /// 사용자 닉네임
  final String nickname;

  /// Firebase UID (차단 해제에 필요)
  final String firebaseUid;

  const PostBlockedUserInfo({
    super.key,
    this.photoUrl,
    required this.nickname,
    required this.firebaseUid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // 탭하면 차단 해제 다이얼로그 표시
        showUnblockDialog(context: context, otherUserUid: firebaseUid);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 사용자 아바타
            Avatar(photoUrl: photoUrl),
            const SizedBox(width: 12),
            // 차단된 사용자 메시지
            Expanded(
              child: Text(
                '${PhilgoTr.of(context)!.post_from_blocked_user} $nickname',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
