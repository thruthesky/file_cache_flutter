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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
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
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Comments stat
                        Expanded(
                          child: StatContainer(
                            value: user?.noOfComment ?? 0,
                            label: T.comments, // 'Comments',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  LatestUserPosts(firebase_uid: widget.firebaseUid),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
