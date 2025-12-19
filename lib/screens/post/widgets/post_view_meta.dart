import 'package:flutter/material.dart';

import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 작성자 메타 정보 위젯
///
/// 아바타, 닉네임, 작성 날짜를 표시합니다.
/// 탭하면 작성자 프로필 화면으로 이동합니다.
///
/// ### 매개변수:
/// - [firebaseUid] → 작성자의 Firebase UID (프로필 이동에 필요)
/// - [nickname] → 작성자 닉네임
/// - [photoUrl] → 작성자 프로필 사진 URL (nullable)
/// - [formattedDate] → 이미 포맷팅된 작성 날짜 문자열 (예: "2024-01-15")
/// - [avatarSize] → 아바타 크기 (기본값: 40)
/// - [padding] → 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
///
/// ### 예시:
/// ```dart
/// PostViewMeta(
///   nickname: '홍길동',
///   photoUrl: 'https://example.com/photo.jpg',
///   formattedDate: '2024-01-15',
/// )
/// ```
class PostViewMeta extends StatelessWidget {
  final int idxMember;

  /// 작성자 닉네임
  final String nickname;

  /// 작성자 프로필 사진 URL (nullable)
  final String? photoUrl;

  /// 이미 포맷팅된 작성 날짜 문자열 (예: "2024-01-15")
  final String formattedDate;

  /// 아바타 크기 (기본값: 40)
  final double avatarSize;

  /// 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
  final EdgeInsets padding;

  const PostViewMeta({
    super.key,
    required this.idxMember,
    required this.nickname,
    this.photoUrl,
    required this.formattedDate,
    this.avatarSize = 40,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          // 작성자 아바타
          Avatar(photoUrl: photoUrl, size: avatarSize),
          const SizedBox(width: 12),

          // 작성자 이름 및 작성 날짜
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임
                InkWell(
                  onTap: () {
                    ProfileViewScreen.push(
                      context,
                      idxMember: idxMember,
                      nickname: nickname,
                      photoUrl: photoUrl,
                    );
                  },
                  child: Text(
                    nickname,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // 작성 날짜
                Text(
                  formattedDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
