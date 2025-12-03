import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 친구 검색 다이얼로그
/// Comic 스타일 적용: 2.0 테두리, 그림자 없음, 둥근 모서리
class SearchFriendsDialog extends StatefulWidget {
  const SearchFriendsDialog({super.key});

  @override
  State<SearchFriendsDialog> createState() => _SearchFriendsDialogState();
}

class _SearchFriendsDialogState extends State<SearchFriendsDialog> {
  final TextEditingController _searchController = TextEditingController();

  List<User> _searchResults = [];
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

      List<User> results = [];
      if (snapshot.exists) {
        final usersData = snapshot.value as Map<dynamic, dynamic>;
        for (final entry in usersData.entries) {
          final uid = entry.key as String;
          final userData = entry.value as Map<dynamic, dynamic>;

          if (mounted) {
            // Don't include current user in results
            if (loginUid() != null && loginUid() != uid) {
              results.add(
                User(
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

  Future<void> _startChatWithUser(User user) async {
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
        showErrorSnackBar(
          context,
          LibTr.of(context)!.failed_to_start_chat(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 2.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Comic 스타일
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: 2.0),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightUserGroup,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LibTr.of(context)!.search_friends,
                    style: textTheme.titleMedium,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field - Comic 스타일
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: LibTr.of(context)!.search_by_nickname,
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: FaIcon(
                              FontAwesomeIcons.lightMagnifyingGlass,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline, width: 2.0),
          ),
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
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
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              LibTr.of(context)!.search_by_nickname,
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline, width: 2.0),
              ),
              child: FaIcon(
                FontAwesomeIcons.lightMagnifyingGlassChart,
                size: 48,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LibTr.of(context)!.no_users_found,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      );
    }

    // Results list - Comic 스타일
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return InkWell(
          onTap: () => _startChatWithUser(user),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline, width: 2.0),
            ),
            child: Row(
              children: [
                // Avatar with Comic border
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary, width: 2.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Avatar(photoUrl: user.photoUrl, size: 36),
                  ),
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: Text(
                    user.nickname,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Chat button - Comic style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.primary, width: 2.0),
                  ),
                  child: Text(
                    LibTr.of(context)!.chat,
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
