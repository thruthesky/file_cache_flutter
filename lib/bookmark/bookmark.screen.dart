import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/bookmark/bookmark.model.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/bookmark/bookmark_group.model.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';
import 'package:philgo/user/widgets/user_avatar.dart';

/// 북마크 관리 화면
///
/// 그룹 목록 → 그룹 내 북마크 목록 2단 구조.
/// 그룹 목록은 [BookmarkService.instance.bookmarkGroups] ValueNotifier를 통해
/// 항상 최신 상태로 유지된다.
class BookmarkScreen extends StatefulWidget {
  static const String routeName = '/bookmark';

  static Future push(BuildContext context) => context.push(routeName);

  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  BookmarkGroupModel? _selectedGroup;
  List<BookmarkModel> _bookmarks = [];
  bool _isLoadingBookmarks = false;

  Future<void> _loadBookmarks(BookmarkGroupModel group) async {
    setState(() {
      _selectedGroup = group;
      _isLoadingBookmarks = true;
    });
    final result = await BookmarkService.instance.listByGroup(
      idxGroup: group.idx,
    );
    if (!mounted) return;
    setState(() {
      _bookmarks = result.bookmarks;
      _isLoadingBookmarks = false;
    });
  }

  Future<void> _createGroup() async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          // "Create Group"
          title: Text('그룹 생성'.tr()),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              // "Group Name"
              hintText: '그룹 이름'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              // "Cancel"
              child: Text('취소'.tr()),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx, text);
              },
              // "Create"
              child: Text('생성'.tr()),
            ),
          ],
        );
      },
    );
    if (name == null) return;
    await BookmarkService.instance.createGroup(name: name);
  }

  Future<void> _deleteGroup(BookmarkGroupModel group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // "Delete Group"
        title: Text('그룹 삭제'.tr()),
        // "All bookmarks in this group will also be deleted"
        content: Text('그룹의 모든 북마크도 함께 삭제됩니다'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            // "Cancel"
            child: Text('취소'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: color.error),
            // "Delete"
            child: Text('삭제'.tr()),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await BookmarkService.instance.deleteGroup(idxGroup: group.idx);
  }

  Future<void> _removeBookmark(BookmarkModel bookmark) async {
    await BookmarkService.instance.remove(
      entityType: bookmark.entityType,
      entityIdx: bookmark.entityIdx > 0 ? bookmark.entityIdx : null,
      entityId: bookmark.entityId.isNotEmpty ? bookmark.entityId : null,
    );
    if (!mounted) return;
    setState(() {
      _bookmarks = _bookmarks.where((b) => b.idx != bookmark.idx).toList();
    });
  }

  void _onBookmarkTap(BookmarkModel bookmark) {
    switch (bookmark.entityType) {
      case 'post':
        if (bookmark.entityIdx > 0) _navigateToPost(bookmark.entityIdx);
      case 'comment':
        final parentIdx = bookmark.parentIdx;
        if (parentIdx != null && parentIdx > 0) _navigateToPost(parentIdx);
      case 'user':
        if (bookmark.entityIdx > 0) {
          OtherUserScreen.pushByIdx(context, bookmark.entityIdx);
        }
      case 'chat_room':
        if (bookmark.entityId.isNotEmpty) {
          ChatRoomScreen.push(context, bookmark.entityId);
        }
    }
  }

  Future<void> _navigateToPost(int idx) async {
    final post = await PostService.get(idx);
    if (!mounted) return;
    PostViewScreen.push(context, post);
  }

  void _backToGroups() {
    setState(() {
      _selectedGroup = null;
      _bookmarks = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Bookmark"
        title: Text(_selectedGroup != null ? _selectedGroup!.name : '북마크'.tr()),
        backgroundColor: color.surface,
        foregroundColor: color.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: _selectedGroup != null
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.lightChevronLeft, size: 18),
                onPressed: _backToGroups,
              )
            : null,
      ),
      backgroundColor: color.surface,
      floatingActionButton: _selectedGroup == null
          ? FloatingActionButton.small(
              onPressed: _createGroup,
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              child: const FaIcon(FontAwesomeIcons.lightPlus, size: 18),
            )
          : null,
      body: _selectedGroup != null ? _buildBookmarkList() : _buildGroupList(),
    );
  }

  // ── 그룹 목록 ──────────────────────────────────────

  Widget _buildGroupList() {
    return ValueListenableBuilder<List<BookmarkGroupModel>>(
      valueListenable: BookmarkService.instance.bookmarkGroups,
      builder: (context, groups, _) {
        if (groups.isEmpty) {
          // "No groups"
          return _buildEmpty(FontAwesomeIcons.lightFolderOpen, '그룹이 없습니다'.tr());
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: groups.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: color.outlineVariant,
          ),
          itemBuilder: (_, i) => _buildGroupTile(groups[i]),
        );
      },
    );
  }

  Widget _buildGroupTile(BookmarkGroupModel group) {
    return ListTile(
      leading: FaIcon(
        FontAwesomeIcons.lightFolder,
        size: 20,
        color: color.onSurfaceVariant,
      ),
      title: Text(
        group.name,
        style: text.bodyLarge?.copyWith(color: color.onSurface),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${group.count}',
              style: text.labelSmall?.copyWith(color: color.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteGroup(group),
            child: FaIcon(
              FontAwesomeIcons.lightTrashCan,
              size: 14,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onTap: () => _loadBookmarks(group),
    );
  }

  // ── 북마크 목록 ──────────────────────────────────────

  Widget _buildBookmarkList() {
    if (_isLoadingBookmarks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarks.isEmpty) {
      // "No bookmarks"
      return _buildEmpty(FontAwesomeIcons.lightBookmark, '북마크가 없습니다'.tr());
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _bookmarks.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: color.outlineVariant,
      ),
      itemBuilder: (_, i) {
        final bookmark = _bookmarks[i];
        return Dismissible(
          key: ValueKey(bookmark.idx),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: color.error,
            child: FaIcon(
              FontAwesomeIcons.lightTrashCan,
              color: color.onError,
              size: 18,
            ),
          ),
          onDismissed: (_) => _removeBookmark(bookmark),
          child: _buildBookmarkTile(bookmark),
        );
      },
    );
  }

  Widget _buildBookmarkTile(BookmarkModel bookmark) {
    return ListTile(
      leading: _buildBookmarkIcon(bookmark),
      title: Text(
        _bookmarkTitle(bookmark),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyMedium?.copyWith(color: color.onSurface),
      ),
      subtitle: Text(
        _bookmarkSubtitle(bookmark),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodySmall?.copyWith(color: color.onSurfaceVariant),
      ),
      onTap: () => _onBookmarkTap(bookmark),
    );
  }

  Widget _buildBookmarkIcon(BookmarkModel bookmark) {
    switch (bookmark.entityType) {
      case 'post':
        return FaIcon(
          FontAwesomeIcons.lightFileLines,
          size: 20,
          color: color.onSurfaceVariant,
        );
      case 'comment':
        return FaIcon(
          FontAwesomeIcons.lightComment,
          size: 20,
          color: color.onSurfaceVariant,
        );
      case 'user':
        return UserAvatar(photoUrl: bookmark.photoUrl ?? '');
      case 'chat_room':
        return FaIcon(
          FontAwesomeIcons.lightComments,
          size: 20,
          color: color.onSurfaceVariant,
        );
      default:
        return FaIcon(
          FontAwesomeIcons.lightBookmark,
          size: 20,
          color: color.onSurfaceVariant,
        );
    }
  }

  String _bookmarkTitle(BookmarkModel bookmark) {
    switch (bookmark.entityType) {
      case 'post':
        // "No Title"
        return bookmark.subject ?? '제목 없음'.tr();
      case 'comment':
        // "No Preview"
        return bookmark.contentPreview ?? '내용 미리보기 없음'.tr();
      case 'user':
        // "No name"
        return bookmark.nickname ?? '이름없음'.tr();
      case 'chat_room':
        return bookmark.otherNickname ??
            bookmark.otherName ??
            bookmark.entityId;
      default:
        return bookmark.entityId.isNotEmpty
            ? bookmark.entityId
            : '#${bookmark.entityIdx}';
    }
  }

  String _bookmarkSubtitle(BookmarkModel bookmark) {
    switch (bookmark.entityType) {
      case 'post':
        return bookmark.postId ?? bookmark.entityType;
      case 'comment':
        // "Comments"
        return '댓글'.tr();
      case 'user':
        // "User"
        return '사용자'.tr();
      case 'chat_room':
        // "Chat"
        return '채팅'.tr();
      default:
        return bookmark.entityType;
    }
  }

  // ── 공통 ──────────────────────────────────────

  Widget _buildEmpty(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 48, color: color.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
