import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
        // Push Notification Toggle
        PushNotificationIcon(subscriptionId: roomId, reverse: true),

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
                                LibTr.of(context)!.admin_chat_notice,
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
                          title: Text(LibTr.of(context)!.edit),
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
                          title: Text(LibTr.of(context)!.profile),
                          onTap: () {
                            Navigator.of(context).pop();
                            showProfileDialog(parentContext, otherUser!);
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
                          title: Text(LibTr.of(context)!.join_url),
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
                        title: Text(LibTr.of(context)!.report),
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
                              LibTr.of(context)!.unblock_user,
                              style: TextStyle(color: Colors.green),
                            ),
                            onTap: () {
                              showUnblockDialog(parentContext);
                            },
                          ),
                          no: () => ListTile(
                            leading: Icon(Icons.block),
                            title: Text(LibTr.of(context)!.block_user),
                            onTap: () {
                              Navigator.of(context).pop();
                              showBlockDialog(parentContext);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Leave option
                      ListTile(
                        leading: const Icon(Icons.exit_to_app),
                        title: Text(LibTr.of(context)!.leave),
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
    showSuccessSnackBar(context, LibTr.of(context)!.copied_to_clipboard);
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
    if (otherUser == null) return;

    showDialog(
      context: parentContext,
      builder: (context) => BlockUserDialog(
        user: otherUser!,
        onBlocked: () {
          Navigator.of(parentContext).pop(); // Close chat message.
          // Optionally refresh or show success message
        },
      ),
    );
  }

  /// Show block/unblock dialog
  void showUnblockDialog(BuildContext parentContext) {
    if (otherUser == null) return;

    showDialog(
      context: parentContext,
      builder: (context) => UnblockUserDialog(
        user: otherUser!,
        onUnblocked: () {
          // Optionally refresh or show success message
        },
      ),
    );
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
                    LibTr.of(context)!.members_count(room!.users.length),
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
