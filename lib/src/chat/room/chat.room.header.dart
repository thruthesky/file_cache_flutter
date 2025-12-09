import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';

/// Header widget for chat room screen showing room info and options
class ChatRoomHeader extends StatelessWidget {
  final ChatRoom? room;
  final User? otherUser;
  final String roomId;
  final bool isSingleChat;
  final VoidCallback? onEditTap;
  final VoidCallback? onLeave;
  final VoidCallback? onBackPressed;

  const ChatRoomHeader({
    super.key,
    this.room,
    this.otherUser,
    required this.roomId,
    required this.isSingleChat,
    this.onEditTap,
    this.onLeave,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onBackPressed,
        icon: const Icon(Icons.arrow_back),
      ),
      title: buildRoomTitle(context),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        /// 즐겨찾기 버튼 - 채팅방을 즐겨찾기 폴더에 추가
        /// Firebase에서 실시간으로 즐겨찾기 상태를 확인하여 아이콘 변경
        _FavoriteIconButton(roomId: roomId),

        // Push Notification Toggle
        PushNotificationIcon(subscriptionId: roomId, reverse: true),

        // Gear Menu Button
        IconButton(
          onPressed: () => showMenuModal(context),
          icon: const Icon(Icons.settings),
          tooltip: PhilgoTr.of(context)!.menu,
        ),
      ],
    );
  }

  /// Show menu modal with various options
  void showMenuModal(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PhilgoTr.of(context)!.menu,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: PhilgoTr.of(context)!.close,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show admin notice for admin chats, or regular options for other chats
                    if (isAdminChatRoom(
                      roomId: roomId,
                      otherUserUid: otherUser?.uid,
                    )) ...[
                      // Admin chat notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                PhilgoTr.of(context)!.admin_chat_notice,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Edit option (only for group/open chats and if current user is master)
                      if (shouldShowEditOption()) ...[
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(PhilgoTr.of(context)!.edit),
                          onTap: () {
                            Navigator.of(context).pop();
                            if (onEditTap != null) onEditTap!();
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Push Notification option
                      if (isSingleChat && otherUser != null) ...[
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity(
                            horizontal: -4,
                            vertical: -2,
                          ),
                          leading: Avatar(photoUrl: getPhotoUrl()),
                          title: Text(PhilgoTr.of(context)!.profile),
                          onTap: () {
                            Navigator.of(context).pop();
                            showProfileDialog(parentContext, otherUser!);
                          },
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.post_add),
                          title: Text(PhilgoTr.of(context)!.recent_post),
                          onTap: () {
                            Navigator.of(context).pop();
                            showUserRecentPostsDialog(
                              context: parentContext,
                              otherUser: otherUser!,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Join URL option
                      if (!isSingleChat) ...[
                        ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(PhilgoTr.of(context)!.join_url),
                          onTap: () {
                            Navigator.of(context).pop();
                            copyRoomIdToClipboard(context);
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Regular chat options (report, block, leave)
                      // Report option
                      ListTile(
                        leading: const Icon(Icons.report),
                        title: Text(PhilgoTr.of(context)!.report),
                        onTap: () {
                          Navigator.of(context).pop();
                          reportRoom(parentContext);
                        },
                      ),
                      const SizedBox(height: 8),

                      // Block/Unblock option (only for single chat)
                      if (isSingleChat && otherUser != null) ...[
                        Blocked(
                          otherUserUid: otherUser!.uid,
                          yes: () => ListTile(
                            leading: Icon(
                              Icons.person_add,
                              color: Colors.green,
                            ),
                            title: Text(
                              PhilgoTr.of(context)!.unblock_user,
                              style: TextStyle(color: Colors.green),
                            ),
                            onTap: () {
                              showUnblockDialog(
                                context: parentContext,
                                otherUserUid: otherUser!.uid,
                              );
                            },
                          ),
                          no: () => ListTile(
                            leading: Icon(Icons.block),
                            title: Text(PhilgoTr.of(context)!.block_user),
                            onTap: () {
                              Navigator.of(context).pop();
                              showBlockDialog(
                                context: parentContext,
                                otherUserUid: otherUser!.uid,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Leave option
                      ListTile(
                        leading: const Icon(Icons.exit_to_app),
                        title: Text(PhilgoTr.of(context)!.leave),
                        onTap: () {
                          Navigator.of(context).pop();
                          showLeaveConfirmDialog(parentContext);
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if edit option should be shown
  /// Only show if: room is not single, room exists, and current user is master
  bool shouldShowEditOption() {
    // Don't show for single chat
    if (isSingleChat) return false;

    // Don't show if room doesn't exist
    if (room == null) return false;

    // Don't show if current user is not logged in
    if (loginUid() == null) return false;

    // Check if current user is in master users
    return room!.masterUsers.containsKey(loginUid()) &&
        room!.masterUsers[loginUid()] == true;
  }

  /// Copy room ID to clipboard
  void copyRoomIdToClipboard(BuildContext context) {
    String url = 'https://philgo.com/chat/rooms.php?id=$roomId';
    if (kIsWeb) {
      url = Uri.base.resolve('/chat/rooms.php?id=$roomId').toString();
    }
    Clipboard.setData(ClipboardData(text: url));
    showSuccessSnackBar(context, PhilgoTr.of(context)!.copied_to_clipboard);
  }

  /// Report room - show report dialog
  void reportRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportChatRoom(
        roomId: roomId,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show confirmation dialog for leaving room
  /// Comic design applied - 2.0px border, rounded corners, no shadow
  void showLeaveConfirmDialog(BuildContext parentContext) async {
    final theme = Theme.of(parentContext);
    final colorScheme = theme.colorScheme;

    bool confirm = await showDialog(
      context: parentContext,
      builder: (context) => Dialog(
        // Comic design: no shadow
        elevation: 0,
        // Comic design: rounded corners (borderRadius: 12)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Remove default background to use Container decoration
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            // Comic design: surface background color
            color: colorScheme.surface,
            // Comic design: 2.0px outline border with rounded corners
            border: Border.all(color: colorScheme.outline, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title section - Comic design spacing (multiples of 8)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  PhilgoTr.of(context)!.leave_room,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Content section - Comic design spacing
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  PhilgoTr.of(context)!.leave_room_confirmation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // Actions section - Comic design buttons with spacing
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button - Comic design neutral button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(
                        // Comic design: no shadow
                        elevation: WidgetStateProperty.all(0),
                        // Comic design: 2.0px border with rounded corners
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                        ),
                        // Comic design: surface background
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        // Comic design: onSurface text color
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        // Comic design: padding in multiples of 8
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        // Comic design: text style from Theme
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text(PhilgoTr.of(context)!.cancel),
                    ),
                    const SizedBox(width: 8),
                    // Leave button - Comic design error button (destructive action)
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ButtonStyle(
                        // Comic design: no shadow
                        elevation: WidgetStateProperty.all(0),
                        // Comic design: 2.0px border with rounded corners
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: 2.0,
                            ),
                          ),
                        ),
                        // Comic design: error background for destructive action
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        // Comic design: onError text color
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onError,
                        ),
                        // Comic design: padding in multiples of 8
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        // Comic design: text style from Theme
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text(PhilgoTr.of(context)!.leave),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && parentContext.mounted) {
      // User confirmed to leave the room
      onLeave?.call();
    }
  }

  Widget buildRoomTitle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showProfileDialog(context, otherUser!);
      },
      child: Row(
        children: [
          Avatar(photoUrl: getPhotoUrl()),
          const SizedBox(width: 12),

          // Room/User Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getRoomName(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                if (room != null && !isSingleChat && room!.users.isNotEmpty)
                  Text(
                    PhilgoTr.of(context)!.members_count(room!.users.length),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? getPhotoUrl() {
    if (isSingleChat && otherUser != null) {
      return otherUser!.photoUrl;
    } else if (room != null) {
      return room!.imageUrl;
    }
    return null;
  }

  String getRoomName() {
    if (isSingleChat && otherUser != null) {
      return otherUser!.nickname;
    } else if (room != null) {
      return room!.name;
    }
    return "no-name";
  }
}

/// 즐겨찾기 아이콘 버튼 - 실시간으로 즐겨찾기 상태를 확인하여 아이콘 표시
/// Firebase의 chat/favorites 경로를 직접 구독하여 실시간 업데이트
class _FavoriteIconButton extends StatefulWidget {
  final String roomId;

  const _FavoriteIconButton({required this.roomId});

  @override
  State<_FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<_FavoriteIconButton> {
  final _isFavoritedNotifier = ValueNotifier<bool>(false);
  StreamSubscription<DatabaseEvent>? _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    _listenToFavorites();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _isFavoritedNotifier.dispose();
    super.dispose();
  }

  /// Firebase에서 즐겨찾기 상태를 실시간으로 구독
  void _listenToFavorites() {
    if (loginUid() == null) return;

    final database = FirebaseDatabase.instance;
    final favoritesRef = database.ref('chat/favorites/${loginUid()}');

    _favoritesSubscription = favoritesRef.onValue.listen((event) {
      bool isFavorited = false;

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        // 모든 폴더를 순회하며 현재 roomId가 있는지 확인
        for (var roomsData in data.values) {
          if (roomsData is Map && roomsData.containsKey(widget.roomId)) {
            isFavorited = true;
            break;
          }
        }
      }

      _isFavoritedNotifier.value = isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loginUid() == null) {
      return IconButton(
        onPressed: () => _showFavoritesModal(context),
        icon: const Icon(Icons.star_border),
        tooltip: PhilgoTr.of(context)!.add_to_favorites,
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isFavoritedNotifier,
      builder: (context, isFavorited, child) {
        return IconButton(
          onPressed: () => _showFavoritesModal(context),
          icon: Icon(
            isFavorited ? Icons.star : Icons.star_border,
            color: isFavorited ? Colors.amber : null,
          ),
          tooltip: PhilgoTr.of(context)!.add_to_favorites,
        );
      },
    );
  }

  /// 즐겨찾기 모달 표시
  void _showFavoritesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FavoritesModal(roomId: widget.roomId),
    );
  }
}

/// 즐겨찾기 폴더 모달 위젯 - 채팅방을 즐겨찾기 폴더에 추가/제거하는 모달
class _FavoritesModal extends StatefulWidget {
  final String roomId;

  const _FavoritesModal({required this.roomId});

  @override
  State<_FavoritesModal> createState() => _FavoritesModalState();
}

class _FavoritesModalState extends State<_FavoritesModal> {
  final Dio _dio = Dio();
  Set<String> selectedFolders = {};
  bool isLoading = false;
  bool isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentFavorites();
  }

  /// 현재 채팅방이 속한 즐겨찾기 폴더 목록 로드
  /// Firebase에서 각 폴더를 확인하여 현재 채팅방이 포함되어 있는지 체크
  Future<void> _loadCurrentFavorites() async {
    if (loginUid() == null) {
      setState(() {
        isLoadingInitial = false;
      });
      return;
    }

    setState(() {
      isLoadingInitial = true;
    });

    try {
      final database = FirebaseDatabase.instance;
      final favoritesRef = database.ref('chat/favorites/${loginUid()}');
      final snapshot = await favoritesRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        // 각 폴더를 순회하며 현재 roomId가 있는지 확인
        data.forEach((folderName, roomsData) {
          if (roomsData is Map) {
            // roomsData 맵에 현재 roomId가 키로 존재하는지 확인
            if (roomsData.containsKey(widget.roomId)) {
              selectedFolders.add(folderName.toString());
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading current favorites: $e');
    } finally {
      setState(() {
        isLoadingInitial = false;
      });
    }
  }

  /// 즐겨찾기 폴더 토글 - 폴더를 추가하거나 제거
  Future<void> _toggleFolder(String folderName) async {
    if (loginUid() == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // API 호출하여 즐겨찾기 추가/제거
      final response = await _dio.post(
        'https://us-central1-philgo-64b1a.cloudfunctions.net/onFavorite',
        data: {
          'myUid': loginUid(),
          'roomId': widget.roomId,
          'folderName': folderName,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (selectedFolders.contains(folderName)) {
            selectedFolders.remove(folderName);
          } else {
            selectedFolders.add(folderName);
          }
        });

        if (mounted) {
          showSuccessSnackBar(
            context,
            selectedFolders.contains(folderName)
                ? 'Added to $folderName'
                : 'Removed from $folderName',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to update favorite: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 헤더 - 제목과 닫기 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to Favorites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: PhilgoTr.of(context)!.close,
                ),
              ],
            ),
          ),
          const Divider(),

          /// 즐겨찾기 폴더 목록 - UserService에서 가져온 폴더들 표시
          Flexible(
            child: isLoadingInitial
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: UserService.instance.favoriteFoldersStream,
                    builder: (context, folders, child) {
                      if (folders.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            PhilgoTr.of(context)!.no_bookmarked_folders,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final folderName = folder['folderName'] as String;
                          final isSelected = selectedFolders.contains(
                            folderName,
                          );

                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: isLoading
                                  ? null
                                  : (value) => _toggleFolder(folderName),
                            ),
                            title: Text(folderName),
                            subtitle: Text(
                              '${folder['countFavorites']} chats',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: isLoading
                                ? null
                                : () => _toggleFolder(folderName),
                          );
                        },
                      );
                    },
                  ),
          ),

          if (isLoading && !isLoadingInitial)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
