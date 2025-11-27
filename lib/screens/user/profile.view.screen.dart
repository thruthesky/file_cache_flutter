import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/home/main/user.stats.dart';
import 'package:philgo/widgets/user/latest.user.posts.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
// import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ProfileViewScreen extends StatefulWidget {
  static const String routeName = '/user-profile';

  static Future<void> push(
    BuildContext context, {
    required String firebaseUid,
    String? nickname,
    String? photoUrl,
  }) {
    return context.push(
      routeName,
      extra: {
        'firebaseUid': firebaseUid,
        'nickname': nickname,
        'photoUrl': photoUrl,
      },
    );
  }

  const ProfileViewScreen({
    super.key,
    required this.firebaseUid,
    this.nickname,
    this.photoUrl,
  });

  final String firebaseUid;

  final String? nickname;

  final String? photoUrl;

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  bool isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await func(
        'get_user_public_profile',
        data: {'firebase_uid': widget.firebaseUid},
        debug: true,
      );
      setState(() {
        user = User.fromJson(userData);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSafeErrorDialog('사용자 정보를 불러올 수 없습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.userProfile),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () => showMenuModal(context),
            icon: const Icon(Icons.settings),
            tooltip: LibTr.of(context)!.menu,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   margin: EdgeInsets.only(top: 32),
                  //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.surfaceContainerHighest,
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Text(
                  //     'UID: ${widget.firebaseUid}',
                  //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //       color: Theme.of(context).colorScheme.onSurfaceVariant,
                  //       fontFamily: 'monospace',
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child:
                          widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user?.photoUrl ?? widget.photoUrl ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.lightUser,
                                      size: 60,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: FaIcon(
                                FontAwesomeIcons.lightUser,
                                size: 60,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    user?.nickname ?? widget.nickname ?? T.unknownUser,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Blocked(
                    otherUserUid: widget.firebaseUid,
                    yes: () => SizedBox.shrink(),
                    no: () {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Three equal-sized stat boxes
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                /// Points stat
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ChatRoomScreen.push(context, user!.uid);
                                    },
                                    child: Card(
                                      elevation: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.message,
                                              size: 24,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              T.chat,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// Posts stat
                                Expanded(
                                  child: StatContainer(
                                    value: user?.noOfPost ?? 0,
                                    // value: 1,
                                    label: T.posts, // 'Posts',
                                    icon: FontAwesomeIcons.lightFileLines,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// Comments stat
                                Expanded(
                                  child: StatContainer(
                                    value: user?.noOfComment ?? 0,
                                    label: T.comments, // 'Comments',
                                    icon: FontAwesomeIcons.lightComment,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          LatestUserPosts(firebase_uid: widget.firebaseUid),

                          SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  /// Show menu modal with various options
  void showMenuModal(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Avatar(photoUrl: user?.photoUrl),
                      Text(
                        user!.nickname,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: LibTr.of(context)!.close,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Blocked(
                      otherUserUid: user!.uid,
                      no: () => ListTile(
                        leading: Icon(Icons.message),
                        title: Text(LibTr.of(context)!.chat),
                        onTap: () {
                          Navigator.of(context).pop();
                          ChatRoomScreen.push(context, user!.uid);
                        },
                      ),
                      yes: () => SizedBox.fromSize(),
                    ),

                    Blocked(
                      otherUserUid: user!.uid,
                      yes: () => ListTile(
                        leading: Icon(Icons.person_add, color: Colors.green),
                        title: Text(
                          LibTr.of(context)!.unblock_user,
                          style: TextStyle(color: Colors.green),
                        ),
                        onTap: () {
                          showDialog(
                            context: parentContext,
                            builder: (context) => UnblockUserDialog(
                              otherUserUid: user!.uid,
                              onUnblocked: () {
                                // Optionally refresh or show success message
                              },
                            ),
                          );
                        },
                      ),
                      no: () => ListTile(
                        leading: Icon(Icons.block),
                        title: Text(LibTr.of(context)!.block_user),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: parentContext,
                            builder: (context) => BlockUserDialog(
                              otherUserUid: user!.uid,
                              onBlocked: () {
                                Navigator.of(parentContext).pop();
                                // Close chat message.
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
