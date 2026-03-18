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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: dialogMaxHeight,
          maxWidth: dialogMaxWidth,
        ),
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
            // Header - Comic 스타일
            Container(
              padding: dialogHeaderPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dialogHeaderBorderRadius),
                  topRight: Radius.circular(
                    dialogHeaderBorderRadius,
                  ),
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
                    FontAwesomeIcons.lightUserGroup,
                    color: colorScheme.primary,
                    size: dialogHeaderIconSize,
                  ),
                  SizedBox(width: dialogItemSpacing),
                  Text("Search Friends", style: textTheme.titleMedium),
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
            Expanded(
              child: Padding(
                padding: dialogContentPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
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
                            searchIconPadding,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.lightMagnifyingGlass,
                            color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
              size: dialogEmptyIconSize,
              color: colorScheme.outline,
            ),
            SizedBox(height: dialogEmptySpacing),
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
              size: dialogEmptyIconSize,
              color: colorScheme.outline,
            ),
            SizedBox(height: dialogEmptySpacing),
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
          SizedBox(height: dialogItemSpacing),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return InkWell(
          onTap: () => _startChatWithUser(user),
          borderRadius: BorderRadius.circular(
            dialogItemBorderRadius,
          ),
          child: Container(
            padding: dialogItemPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                dialogItemBorderRadius,
              ),
              border: Border.all(
                color: colorScheme.outline,
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
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      dialogAvatarBorderRadius,
                    ),
                    border: Border.all(
                      color: colorScheme.primary,
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
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: dialogItemSpacing),
                // Chat button - Comic style
                Container(
                  padding: chatButtonPadding,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      chatButtonBorderRadius,
                    ),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: chatButtonBorderWidth,
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
