import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  LibTr.of(context)!.search_friends,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: LibTr.of(context)!.search_by_nickname,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Text(
          LibTr.of(context)!.search_by_nickname,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              LibTr.of(context)!.no_users_found,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Avatar(photoUrl: user.photoUrl, size: 40),
            title: Text(
              user.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: user.nickname.isNotEmpty ? Text(user.nickname) : null,
            trailing: ElevatedButton(
              onPressed: () => _startChatWithUser(user),
              child: Text(
                LibTr.of(context)!.chat,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
