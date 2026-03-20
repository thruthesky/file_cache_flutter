import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/post/list/widgets/post.list.tile.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/widgets/avatar.dart';

String? loginUid() => FirebaseAuth.instance.currentUser?.uid;
// Short alias for loginUid. Note that this is non-nullable function.
String myUid() => loginUid()!;

DatabaseReference userChatUnreadCountRef(String uid) {
  return FirebaseDatabase.instance.ref('users/$uid/chatUnreadCount');
}

DatabaseReference userPinnedChatRoomsRef(String uid) {
  return FirebaseDatabase.instance.ref('users/$uid/pinnedChatRooms');
}

String userPrivatePath(String uid) {
  return 'user-private/$uid';
}

DatabaseReference userPrivateRef(String uid) {
  return FirebaseDatabase.instance.ref(userPrivatePath(uid));
}

DatabaseReference userPrivateBlocksRef(String uid) {
  return userPrivateRef(uid).child('blocks');
}

String myBlockedUsersPath() {
  return 'user-private/${myUid()}/blocks';
}

DatabaseReference myBlockedUsersRef() {
  return FirebaseDatabase.instance.ref(myBlockedUsersPath());
}

DatabaseReference myBlockedUserRef(String uid) {
  return myBlockedUsersRef().child(uid);
}

/// Block a user by Firebase UID
Future toggleBlockUser(String otherUserUid) async {
  if (loginUid() == null) {
    throw ('User must login first');
  }

  if (loginUid() == otherUserUid) {
    throw ('Cannot block yourself');
  }

  final res = await ApiService.instance.v7api(
    'user.toggleBlock',
    data: {'blockee_firebase_uid': otherUserUid},
    debug: true,
  );
  log(res.toString(), name: 'toggleBlockUser::');
  return res['blocked'];
}

/// Block/unblock a user by member idx (게시글/댓글 작성자 차단용)
///
/// 반환: true = 차단됨, false = 차단 해제됨
Future<bool> toggleBlockUserByIdx(int idxBlockee) async {
  if (loginUid() == null) {
    throw ('User must login first');
  }
  final res = await ApiService.instance.v7api(
    'user.toggleBlock',
    data: {'idx_blockee': idxBlockee},
  );
  return res['blocked'] == true;
}


/// Show user profile dialog with Comic design
void showProfileDialog(BuildContext context, UserModel otherUser) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        // Comic design: no shadow
        elevation: 0,
        // Comic design: rounded corners (borderRadius: 12)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Remove default background to use Container decoration
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            // Comic design: surface background color
            color: colorScheme.surface,
            // Comic design: 2.0px outline border with rounded corners
            border: Border.all(color: colorScheme.outline, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content section - Comic design spacing
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User Avatar
                    Avatar(photoUrl: otherUser.photoUrl, size: 120),
                    const SizedBox(height: 16),
                    // User Nickname
                    Text(
                      otherUser.nickname,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions section - Comic design buttons with spacing
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View Profile button - Comic design primary button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          OtherUserScreen.pushByIdx(context, otherUser.idx);
                        },
                        style: ButtonStyle(
                          // Comic design: no shadow
                          elevation: WidgetStateProperty.all(0),
                          // Comic design: 2.0px border with rounded corners
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: colorScheme.primary,
                                width: 2.0,
                              ),
                            ),
                          ),
                          // Comic design: primary background
                          backgroundColor: WidgetStateProperty.all(
                            colorScheme.primary,
                          ),
                          // Comic design: onPrimary text color
                          foregroundColor: WidgetStateProperty.all(
                            colorScheme.onPrimary,
                          ),
                          // Comic design: padding in multiples of 8
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          // Comic design: text style from Theme
                          textStyle: WidgetStateProperty.all(
                            theme.textTheme.bodyMedium,
                          ),
                        ),
                        child: Text('view_profile'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close button - Comic design neutral button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(
                        // Comic design: no shadow
                        elevation: WidgetStateProperty.all(0),
                        // Comic design: 2.0px border with rounded corners
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                        ),
                        // Comic design: surface background
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        // Comic design: onSurface text color
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        // Comic design: padding in multiples of 8
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        // Comic design: text style from Theme
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 최근 게시글을 보여주는 바텀 시트
/// Shows recent posts in a bottom sheet
void showUserRecentPostsDialog({
  required BuildContext context,
  required UserModel otherUser,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              /// 헤더 영역 - 타이틀과 닫기 버튼
              /// Header area with title and close button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최근 게시글'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: '닫기'.tr(),
                    ),
                  ],
                ),
              ),

              /// 컨텐츠 영역 - 게시글 리스트
              /// Content area with posts list
              Expanded(
                child: FutureBuilder(
                  future: PostService.list(idxMember: otherUser.idx),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (asyncSnapshot.hasError) {
                      return Center(
                        child: Text('오류: {}'.tr(args: [asyncSnapshot.error.toString()])),
                      );
                    }

                    final List<Post> posts = asyncSnapshot.data?.posts ?? [];

                    if (posts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('최근 게시글이 없습니다'.tr()),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PostListTile(
                            post: post,
                            onTap: () {
                              OtherUserScreen.pushByIdx(context, otherUser.idx);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
