import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/user/user.firebase_model.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/user/user.functions.dart';
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

  List<UserFirebaseModel> _searchResults = [];
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
      // Search users by nickname_lower_case
      final usersRef = FirebaseDatabase.instance.ref(USERS);
      final snapshot = await usersRef
          .orderByChild(NICKNAME_LOWER_CASE)
          .equalTo(query)
          .get();

      List<UserFirebaseModel> results = [];
      if (snapshot.exists) {
        final usersData = snapshot.value as Map<dynamic, dynamic>;
        for (final entry in usersData.entries) {
          final uid = entry.key as String;
          final userData = entry.value as Map<dynamic, dynamic>;

          if (mounted) {
            // Don't include current user in results
            if (loginUid() != null && loginUid() != uid) {
              results.add(
                UserFirebaseModel(
                  uid: uid,
                  nickname: userData[NICKNAME] ?? '',
                  nicknameLowerCase: userData[NICKNAME_LOWER_CASE] ?? '',
                  photoUrl: userData[PHOTO_URL],
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
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

  Future<void> _startChatWithUser(UserFirebaseModel user) async {
    if (loginUid() == null) return;

    try {
      // Create single chat room ID
      final roomId = makeSingleChatRoomId(loginUid()!, user.uid);

      // Navigate to chat room
      if (mounted) {
        Navigator.of(context).pop(roomId);
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        showErrorSnackBar(context, "Failed to start chat: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = ChatThemeData.instance;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: chatTheme.dialog.elevation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: chatTheme.dialog.maxHeight,
          maxWidth: chatTheme.dialog.maxWidth,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
          border: Border.all(
            color: colorScheme.outline,
            width: chatTheme.dialog.borderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Comic 스타일
            Container(
              padding: chatTheme.dialog.headerPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(chatTheme.dialog.headerBorderRadius),
                  topRight:
                      Radius.circular(chatTheme.dialog.headerBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline,
                    width: chatTheme.dialog.headerBorderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightUserGroup,
                    color: colorScheme.primary,
                    size: chatTheme.dialog.headerIconSize,
                  ),
                  SizedBox(width: chatTheme.dialog.itemSpacing),
                  Text("Search Friends", style: textTheme.titleMedium),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(
                      chatTheme.dialog.closeButtonBorderRadius,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          chatTheme.dialog.closeButtonBorderRadius,
                        ),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: chatTheme.dialog.closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: chatTheme.dialog.closeIconSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: chatTheme.dialog.contentPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field - Comic 스타일
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          chatTheme.dialog.searchFieldBorderRadius,
                        ),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: chatTheme.dialog.searchFieldBorderWidth,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: "Search by nickname",
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(
                              chatTheme.dialog.searchIconPadding,
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightMagnifyingGlass,
                              color: colorScheme.primary,
                              size: chatTheme.dialog.searchIconSize,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              chatTheme.dialog.searchContentPadding,
                        ),
                      ),
                    ),
                    SizedBox(height: chatTheme.dialog.contentSpacing),

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = ChatThemeData.instance;

    // Loading state - Comic 스타일
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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
              size: chatTheme.dialog.emptyIconSize,
              color: colorScheme.outline,
            ),
            SizedBox(height: chatTheme.dialog.emptySpacing),
            Text(
              "Search by nickname",
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
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
              size: chatTheme.dialog.emptyIconSize,
              color: colorScheme.outline,
            ),
            SizedBox(height: chatTheme.dialog.emptySpacing),
            Text(
              "No users found",
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      );
    }

    // Results list - Comic 스타일
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: chatTheme.dialog.itemSpacing),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return InkWell(
          onTap: () => _startChatWithUser(user),
          borderRadius:
              BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
          child: Container(
            padding: chatTheme.dialog.itemPadding,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
              border: Border.all(
                color: colorScheme.outline,
                width: chatTheme.dialog.itemBorderWidth,
              ),
            ),
            child: Row(
              children: [
                // Avatar with Comic border
                Container(
                  width: chatTheme.dialog.avatarSize,
                  height: chatTheme.dialog.avatarSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      chatTheme.dialog.avatarBorderRadius,
                    ),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: chatTheme.dialog.avatarBorderWidth,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      chatTheme.dialog.avatarBorderRadius - 2,
                    ),
                    child: Avatar(photoUrl: user.photoUrl, size: 36),
                  ),
                ),
                SizedBox(width: chatTheme.dialog.avatarSpacing),
                // User info
                Expanded(
                  child: Text(
                    user.nickname,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: chatTheme.dialog.itemSpacing),
                // Chat button - Comic style
                Container(
                  padding: chatTheme.dialog.chatButtonPadding,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      chatTheme.dialog.chatButtonBorderRadius,
                    ),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: chatTheme.dialog.chatButtonBorderWidth,
                    ),
                  ),
                  child: Text(
                    "Chat",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
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
