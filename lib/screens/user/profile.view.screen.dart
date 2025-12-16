import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/user/widgets/profile_view.state_item.dart';
import 'package:philgo/widgets/user/latest.user.posts.dart';
import 'package:philgo_api/philgo_api.dart';
// import 'package:philgo_api/philgo_api.dart';

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
        // debug: true,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showMenuModal(context),
            icon: const Icon(Icons.settings),
            tooltip: PhilgoTr.of(context)!.menu,
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
                                /// Chat button with enhanced design
                                Expanded(
                                  child: AspectRatio(
                                    /// Maintain 1:1 aspect ratio for consistency with stat boxes
                                    aspectRatio: 1,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          ChatRoomScreen.push(
                                            context,
                                            user!.uid,
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            /// Gradient background matching stat boxes
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.1),
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),

                                            /// Flat design - subtle border
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                /// Chat icon at top
                                                FaIcon(
                                                  FontAwesomeIcons
                                                      .lightCommentDots,
                                                  size: 20,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                                const SizedBox(height: 6),

                                                /// Large emphasis text
                                                Text(
                                                  '1:1',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.onSurface,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),

                                                /// Label text
                                                Text(
                                                  T.chat,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// Posts stat
                                Expanded(
                                  child: ProfileViewStatItem(
                                    icon: FontAwesomeIcons.lightFileLines,
                                    value: user?.noOfPost ?? 0,
                                    label: T.posts,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// Comments stat
                                Expanded(
                                  child: ProfileViewStatItem(
                                    icon: FontAwesomeIcons.lightComments,
                                    value: user?.noOfComment ?? 0,
                                    label: T.comments,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
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
                    tooltip: PhilgoTr.of(context)!.close,
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
                        title: Text(PhilgoTr.of(context)!.chat),
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
                          PhilgoTr.of(context)!.unblock_user,
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
                        title: Text(PhilgoTr.of(context)!.block_user),
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
