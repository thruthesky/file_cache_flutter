import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:philgo/user/widgets/avatar.dart';

/// 친구 검색 다이얼로그
/// Comic 스타일 적용: 2.0 테두리, 그림자 없음, 둥근 모서리
class SearchFriendsDialog extends StatefulWidget {
  const SearchFriendsDialog({super.key});

  @override
  State<SearchFriendsDialog> createState() => _SearchFriendsDialogState();
}

class _SearchFriendsDialogState extends State<SearchFriendsDialog> {
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _searchUsers(query.trim().toLowerCase());
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isSearching = true;
    });
    debugPrint('Searching for users with query: $query');

    try {
      List<UserModel> users = await UserService.search(nickname: query);
      if (mounted) {
        setState(() {
          _searchResults = users;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _startChatWithUser(UserModel user) async {
    if (loginUid() == null) return;

    try {
      // Create single chat room ID
      final roomId = makeSingleChatRoomId(loginUid()!, user.firebaseUid);

      // Navigate to chat room
      if (mounted) {
        Navigator.of(context).pop(roomId);
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        // "Failed to start chat: {}"
        showErrorSnackBar(context, '채팅 시작 실패: {}'.tr(args: [e.toString()]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: dialogMaxHeight,
          maxWidth: dialogMaxWidth,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          border: Border.all(
            color: color.outline,
            width: dialogBorderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Comic 스타일
            Container(
              padding: dialogHeaderPadding,
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dialogHeaderBorderRadius),
                  topRight: Radius.circular(dialogHeaderBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: color.outline,
                    width: dialogHeaderBorderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightUserGroup,
                    color: color.primary,
                    size: dialogHeaderIconSize,
                  ),
                  SizedBox(width: dialogItemSpacing),
                  // "Find Friends"
                  Text('친구 검색'.tr(), style: text.titleMedium),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(
                      closeButtonBorderRadius,
                    ),
                    child: Container(
                      padding: dialogCloseButtonPadding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          closeButtonBorderRadius,
                        ),
                        border: Border.all(
                          color: color.outline,
                          width: closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: closeIconSize,
                        color: color.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: dialogContentPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: text.bodyLarge,
                      decoration: InputDecoration(
                        // "Search by nickname"
                        hintText: '닉네임으로 검색'.tr(),
                        hintStyle: text.bodyLarge?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(searchIconPadding),
                          child: FaIcon(
                            FontAwesomeIcons.lightMagnifyingGlass,
                            color: color.primary,
                            size: searchIconSize,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: searchContentPadding,
                      ),
                    ),
                    SizedBox(height: dialogContentSpacing),

                    // Search results
                    Expanded(child: _buildSearchResults()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Loading state - Comic 스타일
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(color.primary),
        ),
      );
    }

    // Empty search - Comic 스타일
    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightMagnifyingGlass,
              size: dialogEmptyIconSize,
              color: color.outline,
            ),
            SizedBox(height: dialogEmptySpacing),
            Text(
              // "Search by nickname"
              '닉네임으로 검색'.tr(),
              style: text.bodyLarge?.copyWith(color: color.outline),
            ),
          ],
        ),
      );
    }

    // No results - Comic 스타일
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightMagnifyingGlassChart,
              size: dialogEmptyIconSize,
              color: color.outline,
            ),
            SizedBox(height: dialogEmptySpacing),
            Text(
              // "No users found"
              '사용자를 찾을 수 없습니다'.tr(),
              style: text.bodyLarge?.copyWith(color: color.outline),
            ),
          ],
        ),
      );
    }

    // Results list - Comic 스타일
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => SizedBox(height: dialogItemSpacing),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return InkWell(
          onTap: () => _startChatWithUser(user),
          borderRadius: BorderRadius.circular(dialogItemBorderRadius),
          child: Container(
            padding: dialogItemPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(dialogItemBorderRadius),
              border: Border.all(
                color: color.outline,
                width: dialogItemBorderWidth,
              ),
            ),
            child: Row(
              children: [
                // Avatar with Comic border
                Container(
                  width: dialogAvatarSize,
                  height: dialogAvatarSize,
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      dialogAvatarBorderRadius,
                    ),
                    border: Border.all(
                      color: color.primary,
                      width: dialogAvatarBorderWidth,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      dialogAvatarBorderRadius - 2,
                    ),
                    child: Avatar(photoUrl: user.photoUrl, size: 36),
                  ),
                ),
                SizedBox(width: dialogAvatarSpacing),
                // User info
                Expanded(
                  child: Text(
                    user.nickname,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: dialogItemSpacing),
                // Chat button - Comic style
                Container(
                  padding: chatButtonPadding,
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(chatButtonBorderRadius),
                    border: Border.all(
                      color: color.primary,
                      width: chatButtonBorderWidth,
                    ),
                  ),
                  child: Text(
                    // "Chat"
                    '채팅'.tr(),
                    style: text.labelLarge?.copyWith(
                      color: color.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
