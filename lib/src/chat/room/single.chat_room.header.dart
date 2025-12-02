import 'dart:async';

import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';

/// Header widget for chat room screen showing room info and options
class SingleChatRoomHeader extends StatelessWidget {
  final ChatJoin join;
  final User otherUser;
  final VoidCallback? onLeave;
  final VoidCallback? onBackPressed;

  const SingleChatRoomHeader({
    super.key,
    required this.join,
    required this.otherUser,
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
        _FavoriteIconButton(roomId: join.id),
        PushNotificationIcon(subscriptionId: join.id, reverse: true),

        // Gear Menu Button
        IconButton(
          onPressed: () => showMenuModal(context),
          icon: const Icon(Icons.settings),
          tooltip: LibTr.of(context)!.menu,
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
                    LibTr.of(context)!.menu,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: LibTr.of(context)!.close,
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
                      roomId: join.id,
                      otherUserUid: otherUser.uid,
                    )) ...[
                      // Admin chat notice with enhanced flat design
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          /// Gradient background for visual interest
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          /// Flat design - subtle border
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                LibTr.of(context)!.admin_chat_notice,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Blocked(
                        otherUserUid: otherUser.uid,
                        yes: () => ListTile(
                          leading: Icon(Icons.person_add, color: Colors.green),
                          title: Text(
                            LibTr.of(context)!.unblock_user,
                            style: TextStyle(color: Colors.green),
                          ),
                          onTap: () {
                            showUnblockDialog(parentContext);
                          },
                        ),
                        no: () => Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              visualDensity: VisualDensity(
                                horizontal: -4,
                                vertical: -2,
                              ),
                              leading: Avatar(photoUrl: getPhotoUrl()),
                              title: Text(LibTr.of(context)!.profile),
                              onTap: () {
                                Navigator.of(context).pop();
                                showProfileDialog(parentContext, otherUser);
                              },
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.post_add),
                              title: Text(LibTr.of(context)!.recent_post),
                              onTap: () {
                                Navigator.of(context).pop();
                                showUserRecentPostsDialog(
                                  context: parentContext,
                                  otherUser: otherUser,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            // Regular chat options (report, block, leave)
                            // Report option
                            ListTile(
                              leading: const Icon(Icons.report),
                              title: Text(LibTr.of(context)!.report),
                              onTap: () {
                                Navigator.of(context).pop();
                                reportRoom(parentContext);
                              },
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: Icon(Icons.block),
                              title: Text(LibTr.of(context)!.block_user),
                              onTap: () {
                                Navigator.of(context).pop();
                                showBlockDialog(parentContext);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Leave option
                      // ListTile(
                      //   leading: const Icon(Icons.exit_to_app),
                      //   title: Text(LibTr.of(context)!.leave),
                      //   onTap: () {
                      //     Navigator.of(context).pop();
                      //     showLeaveConfirmDialog(parentContext);
                      //   },
                      // ),
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

  /// Report room - show report dialog
  void reportRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportChatRoom(
        roomId: join.id,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show confirmation dialog for leaving room
  void showLeaveConfirmDialog(BuildContext parentContext) async {
    bool confirm = await showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text(LibTr.of(context)!.leave_room),
        content: Text(LibTr.of(context)!.leave_room_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LibTr.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(LibTr.of(context)!.leave),
          ),
        ],
      ),
    );

    if (confirm == true && parentContext.mounted) {
      // User confirmed to leave the room
      onLeave?.call();
    }
  }

  /// Show block/unblock dialog
  void showBlockDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => BlockUserDialog(
        otherUserUid: otherUser.uid,
        onBlocked: () {
          Navigator.of(parentContext).pop(); // Close chat message.
        },
      ),
    );
  }

  /// Show block/unblock dialog
  void showUnblockDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => UnblockUserDialog(
        otherUserUid: otherUser.uid,
        onUnblocked: () {
          // Optionally refresh or show success message
        },
      ),
    );
  }

  Widget buildRoomTitle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showProfileDialog(context, otherUser);
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? getPhotoUrl() {
    if (otherUser.photoUrl != null && otherUser.photoUrl!.isNotEmpty) {
      return otherUser.photoUrl;
    }
    if (join.userPhotoUrl.isNotEmpty) {
      return join.userPhotoUrl;
    }
    return null;
  }

  String getRoomName() {
    if (join.customName.isNotEmpty) {
      return join.customName;
    }
    if (otherUser.nickname.isNotEmpty) {
      return otherUser.nickname;
    }
    if (join.userDisplayName.isNotEmpty) {
      return join.userDisplayName;
    }
    return LibTr.of(Config.globalContext)!.no_name;
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
        tooltip: LibTr.of(context)!.add_to_favorites,
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
          tooltip: LibTr.of(context)!.add_to_favorites,
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

  /// 각 폴더별 로딩 상태를 추적하는 맵 - folderName을 키로 사용
  Map<String, bool> folderLoadingStates = {};
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
  Future<void> addToFavoriteFolder(String folderName) async {
    if (loginUid() == null) return;

    setState(() {
      folderLoadingStates[folderName] = true;
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
                ? LibTr.of(context)!.added_to_folder(folderName)
                : LibTr.of(context)!.removed_from_folder(folderName),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          LibTr.of(context)!.failed_to_update_favorite(e.toString()),
        );
      }
    } finally {
      setState(() {
        folderLoadingStates[folderName] = false;
      });
    }
  }

  /// 새 폴더 생성 다이얼로그 표시
  void _showCreateFolderDialog(BuildContext context) async {
    final TextEditingController folderNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LibTr.of(context)!.create_new_folder),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            labelText: LibTr.of(context)!.folder_name,
            hintText: LibTr.of(context)!.enter_folder_name,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(dialogContext).pop();
              addToFavoriteFolder(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LibTr.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final folderName = folderNameController.text.trim();
              if (folderName.isNotEmpty) {
                await addToFavoriteFolder(folderName);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: Text(LibTr.of(context)!.create),
          ),
        ],
      ),
    );
    // Dispose controller after dialog is fully closed
    // folderNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 헤더 - 제목, 폴더 추가 버튼, 닫기 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      LibTr.of(context)!.add_to_favorites,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () =>
                          _showCreateFolderDialog(Config.globalContext),
                      icon: const Icon(Icons.add),
                      tooltip: LibTr.of(context)!.create_new_folder,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: LibTr.of(context)!.close,
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
                            LibTr.of(context)!.no_bookmarked_folders,
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

                          /// 현재 폴더의 로딩 상태 확인
                          final isFolderLoading =
                              folderLoadingStates[folderName] ?? false;

                          return ListTile(
                            leading: isFolderLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Checkbox(
                                    value: isSelected,
                                    onChanged: (value) =>
                                        addToFavoriteFolder(folderName),
                                  ),
                            title: Text(folderName),
                            subtitle: Text(
                              LibTr.of(
                                context,
                              )!.chats_count(folder['countFavorites'] as int),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: isFolderLoading
                                ? null
                                : () => addToFavoriteFolder(folderName),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
