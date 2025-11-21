import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

String? loginUid() => FirebaseAuth.instance.currentUser?.uid;
// Short alias for loginUid. Note that this is non-nullable function.
String myUid() => loginUid()!;

String userPath(String uid) {
  return 'users/$uid';
}

DatabaseReference userRef(String uid) {
  return FirebaseDatabase.instance.ref(userPath(uid));
}

String myBlockedUsersPath() {
  return 'users/${myUid()}/blocked_users';
}

DatabaseReference myBlockedUsersRef() {
  return FirebaseDatabase.instance.ref(myBlockedUsersPath());
}

DatabaseReference myBlockedUserRef(String uid) {
  return myBlockedUsersRef().child(uid);
}

Future<User?> getUser(String uid) async {
  try {
    final event = await userRef(uid).once();
    if (event.snapshot.exists) {
      return User.fromSnapshot(event.snapshot);
    }
    return null;
  } catch (e) {
    throw Exception('Failed to get user: $e');
  }
}

/// Block a user
Future blockUser(String otherUserUid) async {
  if (loginUid() == null) {
    throw ('User must login first');
  }

  if (loginUid() == otherUserUid) {
    throw ('Cannot block yourself');
  }

  await myBlockedUserRef(otherUserUid).set(true);
}

/// Unblock a user
Future unblockUser(String uid) async {
  if (loginUid() == null) {
    throw ('User must login first');
  }

  await myBlockedUserRef(uid).remove();
}

void showProfileDialog(BuildContext context, User otherUser) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(photoUrl: otherUser.photoUrl, size: 120),
            SizedBox(height: 16),
            Text(
              otherUser.nickname,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    UserService.instance.onTapViewProfile != null
                        ? UserService.instance.onTapViewProfile!.call(
                            context,
                            otherUser,
                          )
                        : showInfoDialog(
                            context,
                            'View profile',
                            'Use UserService to initialize onTapViewProfile',
                          );
                  },
                  child: Text(LibTr.of(context)!.view_profile),
                ),
                Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(LibTr.of(context)!.close),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// 최근 게시글을 보여주는 바텀 시트
/// Shows recent posts in a bottom sheet
void showUserRecentPostsDialog({
  required BuildContext context,
  required User otherUser,
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
                      LibTr.of(context)!.recent_post,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: LibTr.of(context)!.close,
                    ),
                  ],
                ),
              ),

              /// 컨텐츠 영역 - 게시글 리스트
              /// Content area with posts list
              Expanded(
                child: FutureBuilder(
                  future: getLatestByUser(firebase_uid: otherUser.uid),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (asyncSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${asyncSnapshot.error}'),
                      );
                    }

                    List<Post>? posts = asyncSnapshot.data;

                    if (posts?.isEmpty ?? true) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(LibTr.of(context)!.no_recent_posts),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: posts!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PostListTile(
                            post: post,
                            onTap: () {
                              UserService.instance.onTapUserRecentPostItem !=
                                      null
                                  ? UserService
                                        .instance
                                        .onTapUserRecentPostItem!
                                        .call(context, post)
                                  : showInfoDialog(
                                      context,
                                      'Recent post on tap',
                                      'Use UserService to initialize onTapUserRecentPostItem',
                                    );
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
