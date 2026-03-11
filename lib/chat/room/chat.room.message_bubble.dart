import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/user/user.firebase_model.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/widgets/avatar.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/user/widgets/block_user_dialog.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:philgo/util/widgets/full_screen_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Message bubble widget for displaying chat messages
class ChatRoomMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final UserFirebaseModel? sender;
  final bool isCurrentUser;
  final bool showSenderInfo;
  final String? roomId; // Add roomId for reporting functionality
  final Function(String url)? onImageTap;

  const ChatRoomMessageBubble({
    super.key,
    required this.message,
    this.sender,
    required this.isCurrentUser,
    this.showSenderInfo = true,
    this.roomId,
    this.onImageTap,
  });
  @override
  Widget build(BuildContext context) {
    // Check if this is a protocol message
    if (ChatProtocol.isProtocolMessage(message.protocol)) {
      // Hide join and left messages for single chats
      if (message.protocol == ChatProtocol.join ||
          message.protocol == ChatProtocol.left) {
        return const SizedBox.shrink(); // Return empty widget
      }
      return _buildProtocolMessage(context);
    }

    // Check if message should be blinded due to moderation
    if (_shouldBlindMessage()) {
      return _buildBlindedMessage(context);
    }

    // Check if message is from a blocked user (only for other users' messages)
    if (!isCurrentUser && sender != null) {
      return Blocked(
        otherUserUid: sender!.uid,
        yes: () => _buildBlockedMessage(context),
        no: () => _buildNormalMessage(context),
      );
    }

    return _buildNormalMessage(context);
  }

  /// Build normal message bubble
  Widget _buildNormalMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // User info section (avatar + name) above the message
          if (showSenderInfo)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!isCurrentUser) ...[
                    // Other user avatar with long press
                    GestureDetector(
                      onTap: () => !isAdminChatUser(sender!.uid)
                          ? _showMessageOptions(context)
                          : null,
                      child: userAvatar(),
                    ),
                    const SizedBox(width: 8),
                    // Other user name with long press
                    GestureDetector(
                      onTap: () => !isAdminChatUser(sender!.uid)
                          ? _showMessageOptions(context)
                          : null,
                      child: Text(
                        userDisplayName(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // "You" text for current user
                    Text(
                      "You",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Message bubble
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message bubble content - max 80% width
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (message.urls != null &&
                            message.urls!.isNotEmpty) ...[
                          _buildMultipleImages(context),
                          if (message.text?.isNotEmpty == true)
                            const SizedBox(height: 8),
                        ],
                        if (message.text?.isNotEmpty == true)
                          GestureDetector(
                            onLongPress: () => _showMessageOptions(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 50)
                                    : Theme.of(context).colorScheme.onSecondary,
                                borderRadius: BorderRadius.circular(18)
                                    .copyWith(
                                      bottomLeft: Radius.circular(
                                        !isCurrentUser && showSenderInfo
                                            ? 4
                                            : 18,
                                      ),
                                      bottomRight: Radius.circular(
                                        isCurrentUser && showSenderInfo
                                            ? 4
                                            : 18,
                                      ),
                                    ),
                              ),
                              child: SelectableLinkify(
                                text: message.text!,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.secondary,
                                  fontSize: 16,
                                ),
                                linkStyle: isCurrentUser
                                    ? TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      )
                                    : null,
                                options: LinkifyOptions(humanize: false),
                                onOpen: (link) async {
                                  log(link.toString(), name: 'link:onOpen');

                                  if (!await launchUrl(Uri.parse(link.url))) {
                                    throw Exception(
                                      'Could not launch ${link.url}',
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 4),

                        // Timestamp
                        Text(
                          formatTimestamp(context, message.sentAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build protocol message (system messages) centered with light gray color
  Widget _buildProtocolMessage(BuildContext context) {
    String protocolText = _getProtocolText(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            protocolText,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Get localized protocol message text
  String _getProtocolText(BuildContext context) {
    final senderName = sender?.nickname ?? 'Unknown';

    switch (message.protocol) {
      case ChatProtocol.create:
        return "Room has been created";
      case ChatProtocol.join:
        return "$senderName has joined the room";
      case ChatProtocol.invitationNotSent:
        return "Invitation not sent";
      case ChatProtocol.left:
        return "$senderName left the room";
      case ChatProtocol.removed:
        return "$senderName has been removed from the room";
      default:
        // Fallback to the message text if protocol is not recognized
        return message.text ?? '';
    }
  }

  /// Build user avatar widget
  Widget userAvatar() {
    return Avatar(
      photoUrl: sender?.photoUrl != null && sender!.photoUrl!.isNotEmpty
          ? sender!.photoUrl!
          : null,
    );
  }

  /// Get user display name
  String userDisplayName() {
    if (sender == null) return 'no-name';

    if (sender!.nickname.isNotEmpty) {
      return sender!.nickname;
    } else {
      return 'no-name';
    }
  }

  /// Build multiple images vertically
  Widget _buildMultipleImages(BuildContext context) {
    if (message.urls == null || message.urls!.isEmpty) {
      return const SizedBox.shrink();
    }

    final urls = message.urls!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < urls.length; i++) ...[
          GestureDetector(
            onTap: () => onImageTap != null
                ? onImageTap!(urls[i])
                : _showFullScreenImage(context, urls, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: urls[i],
                width: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
          // Add spacing between images except for the last one
          if (i < urls.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// Show full screen image viewer
  void _showFullScreenImage(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) async {
    // Use await to prevent widget rebuild on navigation back
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageViewer(imageUrls: urls, initialIndex: initialIndex),
        // Maintain the route state to avoid rebuilding previous screen
        maintainState: true,
      ),
    );
  }

  /// Check if message should be blinded due to moderation
  bool _shouldBlindMessage() {
    // Blind if moderated by AI (M)
    if (message.moderated == 'M') {
      return true;
    }

    return false;
  }

  /// Build blinded message bubble for moderated content
  Widget _buildBlindedMessage(BuildContext context) {
    String blindReason = '';
    if (message.moderated == 'M') {
      blindReason = "This message was blocked by AI moderation.";
    } else if (message.moderated == 'A') {
      blindReason = "This message was blocked as an advertisement.";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // User info section (avatar + name) above the message
          if (showSenderInfo)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!isCurrentUser) ...[
                    // Other user avatar with long press
                    GestureDetector(
                      onLongPress: () => _showMessageOptions(context),
                      child: userAvatar(),
                    ),
                    const SizedBox(width: 8),
                    // Other user name with long press
                    GestureDetector(
                      onLongPress: () => _showMessageOptions(context),
                      child: Text(
                        userDisplayName(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // "You" text for current user
                    Text(
                      "You",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Blinded message bubble
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blinded message content - max 80% width
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(18).copyWith(
                              bottomLeft: Radius.circular(
                                !isCurrentUser && showSenderInfo ? 4 : 18,
                              ),
                              bottomRight: Radius.circular(
                                isCurrentUser && showSenderInfo ? 4 : 18,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Blinded content indicator
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility_off,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    blindReason,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Timestamp
                        Text(
                          formatTimestamp(context, message.sentAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build blocked message display with unblock option
  Widget _buildBlockedMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => _showUnblockOption(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "This message was blocked.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.touch_app, color: Colors.grey[500], size: 14),
            ],
          ),
        ),
      ),
    );
  }

  /// Show message options (report, copy, etc.)
  void _showMessageOptions(BuildContext parentContext) {
    // Don't show options for current user's messages or if roomId is null
    if (isCurrentUser || roomId == null) return;

    showModalBottomSheet(
      context: parentContext,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                    "Menu",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: "Close",
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity(horizontal: -4),
              leading: userAvatar(),
              title: Text("Profile"),
              onTap: () {
                Navigator.of(context).pop();
                showProfileDialog(parentContext, sender!);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: Text("Recent Posts"),
              onTap: () {
                Navigator.of(context).pop();
                showUserRecentPostsDialog(
                  context: parentContext,
                  otherUser: sender!,
                );
              },
            ),
            const SizedBox(height: 8),
            // Report option
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: Text("Report", style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                showChatMessageReportDialog(
                  context: parentContext,
                  message: message,
                  roomId: roomId!,
                );
              },
            ),
            const SizedBox(height: 8),

            // Block/Unblock option (only if sender is not current user)
            if (sender != null) ...[
              Blocked(
                otherUserUid: sender!.uid,
                yes: () => ListTile(
                  leading: Icon(Icons.person_add, color: Colors.green),
                  title: Text(
                    "Unblock User",
                    style: TextStyle(color: Colors.green),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBlockDialog(parentContext);
                  },
                ),
                no: () => ListTile(
                  leading: Icon(Icons.block, color: Colors.orange),
                  title: Text(
                    "Block User",
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBlockDialog(parentContext);
                  },
                ),
              ),

              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// Show block/unblock dialog for message sender
  void _showBlockDialog(BuildContext context) {
    if (sender == null) return;

    // Show unblock dialog
    showDialog(
      context: context,
      builder: (context) => Blocked(
        otherUserUid: sender!.uid,
        yes: () => UnblockUserDialog(
          otherUserUid: sender!.uid,
          onUnblocked: () {
            // Optionally refresh or show success message
          },
        ),
        no: () => BlockUserDialog(
          otherUserUid: sender!.uid,
          displayName: sender!.nickname,
          onBlocked: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// Show unblock option for blocked message
  void _showUnblockOption(BuildContext context) {
    if (sender == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                    "Blocked User Options",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: "Close",
                  ),
                ],
              ),
            ),
            const Divider(),

            // User info
            ListTile(
              leading: userAvatar(),
              title: Text(
                userDisplayName(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("This message was blocked."),
            ),
            const SizedBox(height: 8),

            // Unblock option
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.green),
              title: Text(
                "Unblock User",
                style: const TextStyle(color: Colors.green),
              ),
              subtitle: Text("Unblock this user to view their messages."),
              onTap: () {
                Navigator.of(context).pop();
                _performUnblock(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Perform the unblock operation
  void _performUnblock(BuildContext context) {
    if (sender == null) return;

    showDialog(
      context: context,
      builder: (context) => UnblockUserDialog(
        otherUserUid: sender!.uid,
        onUnblocked: () {
          // Show success message
        },
      ),
    );
  }
}
