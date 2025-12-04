import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 차단된 사용자 목록 바텀시트 - Comic Design
/// Shows bottom sheet with list of blocked users
Future<void> showBlockedUserListDialog(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (BuildContext context) {
      final scheme = Theme.of(context).colorScheme;
      final theme = Theme.of(context);

      return Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: scheme.surface,
          // Comic Design: Rounded top corners with 12px radius
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          // Comic Design: 2.0px border on top, left, and right
          border: const Border(
            top: BorderSide(color: Colors.transparent, width: 2.0),
            left: BorderSide(color: Colors.transparent, width: 2.0),
            right: BorderSide(color: Colors.transparent, width: 2.0),
          ),
        ),
        child: Column(
          children: [
            /// Comic Design: Drag handle indicator
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            /// Comic Design: Header with title and close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      LibTr.of(context)!.blocked_user_options,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                    tooltip: LibTr.of(context)!.close,
                  ),
                ],
              ),
            ),

            /// 차단된 사용자 목록
            /// Blocked users list
            const Expanded(child: BlockedUserList()),
          ],
        ),
      );
    },
  );
}

/// 차단된 사용자 목록 위젯
/// Blocked users list widget
class BlockedUserList extends StatelessWidget {
  const BlockedUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Login(
      builder: (uid) => _buildBlockedUserList(context, uid),
      notLoggedIn: Center(child: Text(LibTr.of(context)!.login_required)),
    );
  }

  /// FirebaseDatabaseQueryBuilder를 사용하여 차단된 사용자 목록 구성
  /// Build blocked users list using FirebaseDatabaseQueryBuilder
  Widget _buildBlockedUserList(BuildContext context, String uid) {
    return FirebaseDatabaseQueryBuilder(
      query: userPrivateBlocksRef(uid),
      pageSize: 20,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              LibTr.of(context)!.error_with_message(snapshot.error.toString()),
            ),
          );
        }

        if (snapshot.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 빈 상태 아이콘 - Font Awesome 사용
                /// Empty state icon using Font Awesome
                FaIcon(
                  FontAwesomeIcons.userCheck,
                  size: 80,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  'No blocked users',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Users you block will appear here',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: snapshot.docs.length + (snapshot.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= snapshot.docs.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            final doc = snapshot.docs[index];
            if (doc.key == null || doc.value != true) {
              return const SizedBox.shrink();
            }

            final blockedUid = doc.key!;

            /// 차단된 사용자 타일
            /// Blocked user tile
            return BlockedUserTile(
              key: ValueKey(blockedUid),
              blockedUid: blockedUid,
            );
          },
        );
      },
    );
  }
}

/// 차단된 사용자 타일
/// Individual blocked user tile widget
class BlockedUserTile extends StatelessWidget {
  final String blockedUid;

  const BlockedUserTile({super.key, required this.blockedUid});

  @override
  Widget build(BuildContext context) {
    /// FutureBuilder를 사용하여 사용자 데이터 가져오기
    /// Use FutureBuilder to fetch user data from Firebase
    return FutureBuilder<User?>(
      future: getUser(blockedUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;

        /// Comic Design: 차단 사용자 타일 with border
        /// Enhanced design for blocked user tile with Comic styling
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            // Comic Design: Card with 1.5px border (list item style)
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              /// 사용자 아바타
              /// User avatar from users/$uid/photoUrl
              leading: Avatar(photoUrl: user.photoUrl, size: 48),

              /// 사용자 이름과 상태
              /// User name and status
              title: Text(
                user.nickname,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),

              /// 차단 상태 표시 (아이콘 포함)
              /// Display blocked status with icon
              subtitle: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.ban,
                    size: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      LibTr.of(context)!.blocked_user_subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),

              /// 차단 해제 버튼
              /// Unblock action button
              trailing: IconButton(
                onPressed: () {
                  showUnblockDialog(context: context, otherUserUid: blockedUid);
                },
                icon: FaIcon(
                  FontAwesomeIcons.userCheck,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: LibTr.of(context)!.unblock_user,
              ),

              /// 타일 전체 클릭 시 차단 해제 다이얼로그 표시
              /// Show unblock dialog when tile is tapped
              onTap: () {
                showUnblockDialog(context: context, otherUserUid: blockedUid);
              },
            ),
          ),
        );
      },
    );
  }
}
