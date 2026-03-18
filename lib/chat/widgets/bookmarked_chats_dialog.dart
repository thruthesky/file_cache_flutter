import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/bookmark/bookmark.model.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/user/widgets/avatar.dart';

/// 북마크된 채팅 목록 다이얼로그
///
/// v7 Bookmark API를 통해 그룹 내 chat_room 북마크를 조회한다.
class BookmarkedChatsDialog extends StatefulWidget {
  const BookmarkedChatsDialog({
    super.key,
    required this.groupIdx,
    required this.groupName,
  });

  final int groupIdx;
  final String groupName;

  @override
  State<BookmarkedChatsDialog> createState() => _BookmarkedChatsDialogState();
}

class _BookmarkedChatsDialogState extends State<BookmarkedChatsDialog> {
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final result = await BookmarkService.instance.listByGroup(
      idxGroup: widget.groupIdx,
      entityType: 'chat_room',
    );
    if (!mounted) return;
    setState(() {
      _bookmarks = result.bookmarks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          border: Border.all(
            color: colorScheme.outline,
            width: dialogBorderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: dialogHeaderPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dialogHeaderBorderRadius),
                  topRight: Radius.circular(dialogHeaderBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline,
                    width: dialogHeaderBorderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightComments,
                    color: colorScheme.primary,
                    size: dialogHeaderIconSize,
                  ),
                  SizedBox(width: dialogItemSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '북마크된 채팅'.tr(),
                          style: textTheme.titleMedium,
                        ),
                        SizedBox(height: subtitleSpacing),
                        Text(
                          widget.groupName,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                    child: Container(
                      padding: dialogCloseButtonPadding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          closeButtonBorderRadius,
                        ),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: closeIconSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 목록
            if (_isLoading)
              Padding(
                padding: dialogEmptyPadding,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 3.0,
                  ),
                ),
              )
            else if (_bookmarks.isEmpty)
              Padding(
                padding: dialogEmptyPadding,
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightComments,
                      size: dialogEmptyIconSize,
                      color: colorScheme.outline,
                    ),
                    SizedBox(height: dialogEmptySpacing),
                    Text(
                      '북마크된 채팅이 없습니다'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: dialogListMaxHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _bookmarks.length,
                  padding: dialogContentPadding,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: dialogItemSpacing),
                  itemBuilder: (_, i) => _buildItem(_bookmarks[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BookmarkModel bookmark) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name =
        bookmark.otherNickname ?? bookmark.otherName ?? bookmark.entityId;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ChatRoomScreen.push(context, bookmark.entityId);
      },
      borderRadius: BorderRadius.circular(dialogItemBorderRadius),
      child: Container(
        padding: dialogItemPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(dialogItemBorderRadius),
          border: Border.all(
            color: colorScheme.outline,
            width: dialogItemBorderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: dialogAvatarSize,
              height: dialogAvatarSize,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(dialogAvatarBorderRadius),
                border: Border.all(
                  color: colorScheme.primary,
                  width: dialogAvatarBorderWidth,
                ),
              ),
              child: Avatar(photoUrl: bookmark.otherPhotoUrl),
            ),
            SizedBox(width: dialogAvatarSpacing),
            Expanded(
              child: Text(
                name,
                style: textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
