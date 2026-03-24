import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/bookmark/widgets/bookmark_group_picker.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/widgets/login_required_dialog.dart';
import 'package:philgo/user/widgets/user_avatar.dart';

/// 다른 사용자의 공개 프로필 화면
///
/// [idx] 또는 [firebaseUid] 중 하나만 전달해야 한다.
/// 둘 다 전달하거나 둘 다 null이면 assert 에러가 발생한다.
class OtherUserScreen extends StatefulWidget {
  static const String routeName = '/user/profile';

  static Function(BuildContext ctx, int idx) pushByIdx = (ctx, idx) =>
      ctx.push('$routeName?idx=$idx');
  static Function(BuildContext ctx, String uid) pushByUid = (ctx, uid) =>
      ctx.push('$routeName?firebase_uid=$uid');

  final int? idx;
  final String? firebaseUid;

  const OtherUserScreen({super.key, this.idx, this.firebaseUid})
    : assert(
        (idx != null) ^ (firebaseUid != null),
        'idx 또는 firebaseUid 중 하나만 전달해야 합니다.',
      );

  @override
  State<OtherUserScreen> createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  UserModel? _user;
  List<Post> _recentPosts = [];
  bool _isLoading = true;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      if (widget.idx != null) {
        _user = await UserService.getUser(idx: widget.idx!);
      } else {
        _user = await UserService.getByFirebaseUid(
          firebaseUid: widget.firebaseUid!,
        );
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _loadRecentPosts();
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog(e.toString());
      if (mounted) Navigator.of(context).pop();
      // rethrow; no need to rethrow. after you pop the page, you will see the snackbar error message again
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) {
        final dialogScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: dialogScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              // "Error"
              Text('오류'.tr(), style: const TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: dialogScheme.onSurfaceVariant),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadRecentPosts() async {
    if (_user == null) return;
    final result = await PostService.list(idxMember: _user!.idx, limit: 10);
    if (!mounted) return;
    setState(() {
      _recentPosts = result.posts;
    });
  }

  Future<void> _toggleBookmark() async {
    if (!UserService.isLoggedIn) {
      LoginRequiredDialog.show(context);
      return;
    }
    if (_user == null) return;
    final result = await showBookmarkGroupPicker(
      context: context,
      isBookmarked: _bookmarked,
    );
    if (result == null || !mounted) return;

    if (result.removed) {
      await BookmarkService.instance.remove(
        entityType: 'user',
        entityIdx: _user!.idx,
      );
      if (!mounted) return;
      setState(() => _bookmarked = false);
    } else {
      await BookmarkService.instance.add(
        entityType: 'user',
        entityIdx: _user!.idx,
        groupName: result.groupName ?? '',
      );
      if (!mounted) return;
      setState(() => _bookmarked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Profile"
        title: Text('프로필'.tr()),
        backgroundColor: color.surface,
        foregroundColor: color.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          if (_user != null)
            PopupMenuButton<String>(
              icon: FaIcon(
                FontAwesomeIcons.lightEllipsisVertical,
                size: 18,
                color: color.onSurface,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'block':
                    ScaffoldMessenger.of(context).showSnackBar(
                      // "[NO TRANSLATION: 차단 기능은 준비 중입니다.]"
                      SnackBar(content: Text('차단 기능은 준비 중입니다.'.tr())),
                    );
                  case 'report':
                    ScaffoldMessenger.of(context).showSnackBar(
                      // "[NO TRANSLATION: 신고 기능은 준비 중입니다.]"
                      SnackBar(content: Text('신고 기능은 준비 중입니다.'.tr())),
                    );
                }
              },
              itemBuilder: (ctx) {
                final popScheme = Theme.of(ctx).colorScheme;
                return [
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightBan,
                          size: 15,
                          color: popScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        // "Block"
                        Text('차단'.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightFlag,
                          size: 15,
                          color: popScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          // "Report"
                          '신고'.tr(),
                          style: TextStyle(color: popScheme.error),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      backgroundColor: color.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  // "Unable to load user information"
                  '사용자 정보를 불러올 수 없습니다'.tr(),
                  style: TextStyle(color: color.error),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final user = _user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Avatar + name centered
          Center(
            child: Column(
              children: [
                UserAvatar(photoUrl: user.photoUrl, radius: 48),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.onSurface,
                  ),
                ),
                if (user.nickname.isNotEmpty &&
                    user.nickname != user.displayName) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${user.nickname}',
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats row (text only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // "Posts"
              _buildStat('글'.tr(), user.noOfPost.toString()),
              // "Comments"
              _buildStat('댓글'.tr(), user.noOfComment.toString()),
              // "Level"
              _buildStat('레벨'.tr(), user.level.toString()),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                _bookmarked
                    ? FontAwesomeIcons.solidBookmark
                    : FontAwesomeIcons.lightBookmark,
                // "Bookmark"
                '북마크'.tr(),
                _toggleBookmark,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                FontAwesomeIcons.lightCommentDots,
                // "Chat"
                '채팅'.tr(),
                () {
                  ChatRoomScreen.push(context, user.firebaseUid);
                },
              ),
              const SizedBox(width: 16),
              // "Block"
              _buildActionButton(FontAwesomeIcons.lightBan, '차단'.tr(), () {
                ScaffoldMessenger.of(
                  context,
                  // "[NO TRANSLATION: 차단 기능은 준비 중입니다.]"
                ).showSnackBar(SnackBar(content: Text('차단 기능은 준비 중입니다.'.tr())));
              }),
            ],
          ),

          const SizedBox(height: 32),

          // Recent posts section
          if (_recentPosts.isNotEmpty) ...[
            Text(
              // "Recent Posts"
              '최근 글'.tr(),
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ..._recentPosts.map((post) => _buildPostItem(post)),
          ],
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return InkWell(
      onTap: () {
        PostViewScreen.push(context, post);
        // Navigator.of(
        //   context,
        // ).push(MaterialPageRoute(builder: (_) => PostViewScreen(post: post)));
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(color: color.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(post.stamp),
                    style: text.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (post.noOfComment > 0) ...[
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.lightComment,
                size: 12,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.noOfComment}',
                style: text.bodySmall?.copyWith(color: color.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: text.bodySmall?.copyWith(color: color.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool isActive = false,
  }) {
    final c = isActive
        ? color.primary
        : isDestructive
        ? color.error
        : color.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 18, color: c),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, color: c)),
          ],
        ),
      ),
    );
  }

  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
