import 'dart:async';

import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      // Comic design: Transparent background, no shadow
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        _FavoriteIconButton(roomId: join.id),
        PushNotificationIcon(subscriptionId: join.id, reverse: true),

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

      /// Comic design: No elevation, transparent background
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        /// Comic design: 2px border, rounded corners, no shadow
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PhilgoTr.of(context)!.menu,

                    /// Comic design: Use theme text style
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
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

            /// Comic design: 2px divider
            Divider(
              color: Theme.of(context).colorScheme.outline,
              thickness: 2.0,
              height: 24,
            ),
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
                      /// Admin chat notice with Comic design
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          /// Comic design: Use theme primaryContainer for notice background
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),

                          /// Comic design: 2.0px border with primary color
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                PhilgoTr.of(context)!.admin_chat_notice,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
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
                        yes: () => _buildComicMenuItem(
                          context: context,
                          icon: FaIcon(
                            FontAwesomeIcons.lightUserPlus,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: PhilgoTr.of(context)!.unblock_user,
                          onTap: () {
                            Navigator.of(context).pop();
                            showUnblockDialog(parentContext);
                          },
                        ),
                        no: () => Column(
                          children: [
                            /// Profile menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: Avatar(photoUrl: getPhotoUrl()),
                              title: PhilgoTr.of(context)!.profile,
                              onTap: () {
                                Navigator.of(context).pop();
                                showProfileDialog(parentContext, otherUser);
                              },
                            ),
                            const SizedBox(height: 8),

                            /// Recent posts menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightNewspaper,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              title: PhilgoTr.of(context)!.recent_post,
                              onTap: () {
                                Navigator.of(context).pop();
                                showUserRecentPostsDialog(
                                  context: parentContext,
                                  otherUser: otherUser,
                                );
                              },
                            ),
                            const SizedBox(height: 8),

                            /// Report menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightFlag,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              title: PhilgoTr.of(context)!.report,
                              onTap: () {
                                Navigator.of(context).pop();
                                reportRoom(parentContext);
                              },
                            ),
                            const SizedBox(height: 8),

                            /// Block user menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightBan,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              title: PhilgoTr.of(context)!.block_user,
                              onTap: () {
                                Navigator.of(context).pop();
                                showBlockDialog(parentContext);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
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
        title: Text(PhilgoTr.of(context)!.leave_room),
        content: Text(PhilgoTr.of(context)!.leave_room_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(PhilgoTr.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(PhilgoTr.of(context)!.leave),
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
                  // Comic design: Use theme text style instead of hardcoded
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    return PhilgoTr.of(PhilgoConfig.globalContext)!.no_name;
  }

  /// Build a menu item with Comic design
  /// Comic design: 2px border, rounded corners, no shadow
  Widget _buildComicMenuItem({
    required BuildContext context,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),

          /// Comic design: 2.0px border with outline color
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            /// Icon
            SizedBox(width: 32, height: 32, child: Center(child: icon)),
            const SizedBox(width: 12),

            /// Title
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
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
            // Comic design: Use theme primary color instead of hardcoded amber
            color: isFavorited ? Colors.amberAccent : null,
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

      /// Comic design: No elevation, transparent background
      elevation: 0,
      backgroundColor: Colors.transparent,
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
                ? PhilgoTr.of(context)!.added_to_folder(folderName)
                : PhilgoTr.of(context)!.removed_from_folder(folderName),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          PhilgoTr.of(context)!.failed_to_update_favorite(e.toString()),
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
      builder: (dialogContext) => Dialog(
        /// Comic design: No elevation, transparent background
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          /// Comic design: 2px border, rounded corners, no shadow
          decoration: BoxDecoration(
            color: Theme.of(dialogContext).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(dialogContext).colorScheme.outline,
              width: 2.0,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                PhilgoTr.of(context)!.create_new_folder,
                style: Theme.of(
                  dialogContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              /// Text field
              TextField(
                controller: folderNameController,
                decoration: InputDecoration(
                  labelText: PhilgoTr.of(context)!.folder_name,
                  hintText: PhilgoTr.of(context)!.enter_folder_name,

                  /// Comic design: 2px border
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(dialogContext).colorScheme.outline,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(dialogContext).colorScheme.outline,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(dialogContext).colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(dialogContext).pop();
                    addToFavoriteFolder(value.trim());
                  }
                },
              ),
              const SizedBox(height: 24),

              /// Action buttons - Comic design
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button - Comic design neutral button
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(dialogContext).colorScheme.outline,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: surface background
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(dialogContext).colorScheme.surface,
                      ),
                      // Comic design: onSurface text color
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(dialogContext).colorScheme.onSurface,
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
                        Theme.of(dialogContext).textTheme.bodyMedium,
                      ),
                    ),
                    child: Text(PhilgoTr.of(context)!.cancel),
                  ),
                  const SizedBox(width: 8),
                  // Create button - Comic design primary button
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
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(dialogContext).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: primary background
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(dialogContext).colorScheme.primary,
                      ),
                      // Comic design: onPrimary text color
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(dialogContext).colorScheme.onPrimary,
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
                        Theme.of(dialogContext).textTheme.bodyMedium,
                      ),
                    ),
                    child: Text(PhilgoTr.of(context)!.create),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    // Dispose controller after dialog is fully closed
    // folderNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Comic design: 2px border, rounded corners, no shadow
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),

        /// Comic design: 2px border with outline color, no shadow
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header - Title, Add Folder Button, Close Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    /// Comic design: Use theme titleLarge style with font weight
                    Text(
                      PhilgoTr.of(context)!.add_to_favorites,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// Comic design: Add button with Font Awesome icon
                    IconButton(
                      onPressed: () =>
                          _showCreateFolderDialog(PhilgoConfig.globalContext),
                      icon: FaIcon(
                        FontAwesomeIcons.lightCirclePlus,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: PhilgoTr.of(context)!.create_new_folder,
                    ),
                  ],
                ),

                /// Comic design: Close button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: PhilgoTr.of(context)!.close,
                ),
              ],
            ),
          ),

          /// Comic design: 2px divider with outline color
          Divider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 2.0,
            height: 24,
          ),

          /// Folder list section - Shows folders from UserService
          Flexible(
            child: isLoadingInitial
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),

                      /// Comic design: Loading indicator with theme primary color
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 3.0,
                      ),
                    ),
                  )
                : ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: UserService.instance.favoriteFoldersStream,
                    builder: (context, folders, child) {
                      if (folders.isEmpty) {
                        /// Comic design: Empty state with 2px border
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),

                              /// Comic design: 2px border, no shadow
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              PhilgoTr.of(context)!.no_bookmarked_folders,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: folders.length,

                        /// Comic design: Add spacing between items
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final folderName = folder['folderName'] as String;
                          final isSelected = selectedFolders.contains(
                            folderName,
                          );

                          /// Track loading state for each folder
                          final isFolderLoading =
                              folderLoadingStates[folderName] ?? false;

                          /// Comic design: ListTile with 2px border
                          return InkWell(
                            onTap: isFolderLoading
                                ? null
                                : () => addToFavoriteFolder(folderName),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withValues(alpha: 0.3)
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),

                                /// Comic design: 2px border
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: 2.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  /// Checkbox or loading indicator
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: isFolderLoading
                                        ? CircularProgressIndicator(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            strokeWidth: 2,
                                          )
                                        : Checkbox(
                                            value: isSelected,
                                            onChanged: (value) =>
                                                addToFavoriteFolder(folderName),
                                            fillColor:
                                                WidgetStateProperty.resolveWith(
                                                  (states) {
                                                    if (states.contains(
                                                      WidgetState.selected,
                                                    )) {
                                                      return Theme.of(
                                                        context,
                                                      ).colorScheme.primary;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),

                                  /// Folder info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          folderName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          PhilgoTr.of(context)!.chats_count(
                                            folder['countFavorites'] as int,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
