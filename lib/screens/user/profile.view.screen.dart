import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
      isLoading = false;
    });

    // try {
    //   final userData = await philgoApiUserProfile(widget.firebaseUid);
    //   setState(() {
    //     user = userData;
    //     isLoading = false;
    //   });
    // } catch (e) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   if (mounted) {
    //     showSafeErrorDialog('사용자 정보를 불러올 수 없습니다.');
    //   }
    // }
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                            widget.photoUrl != null &&
                                widget.photoUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  widget.photoUrl!,
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

                    SizedBox(height: 24),

                    Text(
                      widget.nickname ?? T.unknownUser,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 16),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'UID: ${widget.firebaseUid}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
