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

/// Show recent posts dialog
void showUserRecentPostsDialog({
  required BuildContext context,
  required User otherUser,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LibTr.of(context)!.recent_post,
                style: const TextStyle(
                  fontSize: 18,
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

        content: SingleChildScrollView(
          child: FutureBuilder(
            future: getLatestByUser(otherUser.uid),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (asyncSnapshot.hasError) {
                return Center(child: Text('Error: ${asyncSnapshot.error}'));
              }

              List<Post>? posts = asyncSnapshot.data;

              if (posts?.isEmpty ?? true) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(LibTr.of(context)!.no_recent_posts),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  // Display recent posts for the user
                  for (Post post in posts!)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ListTile(
                        onTap: () {
                          UserService.instance.onTapUserRecentPostItem != null
                              ? UserService.instance.onTapUserRecentPostItem!
                                    .call(context, post)
                              : showInfoDialog(
                                  context,
                                  'Recent post on tap',
                                  'Use UserService to initialize onTapUserRecentPostItem',
                                );
                        },
                        leading: post.photo_url.isNotEmpty
                            ? Image.network(
                                post.photo_url,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : null, //CircleAvatar(child: Icon(Icons.article)),
                        title: Text(post.subject),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.content, maxLines: 1),
                            Row(
                              children: [
                                // Row(
                                //   children: [
                                //     Icon(Icons.thumb_up),
                                //     SizedBox(width: 4),
                                //     Text(post.no_of_comment.toString()),
                                //   ],
                                // ),
                                if (post.no_of_comment > 0)
                                  Row(
                                    children: [
                                      Icon(Icons.forum),
                                      SizedBox(width: 4),
                                      Text(post.no_of_comment.toString()),
                                    ],
                                  ),

                                Spacer(),
                                Text(
                                  formatTimestamp(context, post.stamp * 1000),
                                  style: TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LibTr.of(context)!.close),
          ),
        ],
      );
    },
  );
}
