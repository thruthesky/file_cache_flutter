import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
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
    final chatTheme = ChatThemeData.instance;
    final bubbleTheme = chatTheme.bubble;

    return Padding(
      padding: bubbleTheme.messagePadding,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // User info section (avatar + name) above the message
          if (showSenderInfo)
            Padding(
              padding: EdgeInsets.only(bottom: bubbleTheme.senderInfoSpacing),
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
                    SizedBox(width: bubbleTheme.avatarNameSpacing),
                    // Other user name with long press
                    GestureDetector(
                      onTap: () => !isAdminChatUser(sender!.uid)
                          ? _showMessageOptions(context)
                          : null,
                      child: Text(
                        userDisplayName(),
                        style: TextStyle(
                          fontSize: bubbleTheme.senderNameFontSize,
                          color: bubbleTheme.senderNameColor,
                          fontWeight: bubbleTheme.senderNameFontWeight,
                        ),
                      ),
                    ),
                  ] else ...[
                    // "You" text for current user
                    Text(
                      "You",
                      style: TextStyle(
                        fontSize: bubbleTheme.senderNameFontSize,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: bubbleTheme.senderNameFontWeight,
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
                      maxWidth:
                          constraints.maxWidth * bubbleTheme.maxWidthFraction,
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
                            SizedBox(height: bubbleTheme.imageSpacing),
                        ],
                        if (message.text?.isNotEmpty == true)
                          GestureDetector(
                            onLongPress: () => _showMessageOptions(context),
                            child: Container(
                              padding: bubbleTheme.textPadding,
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 50)
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                borderRadius: BorderRadius.circular(
                                  bubbleTheme.bubbleBorderRadius,
                                ).copyWith(
                                  bottomLeft: Radius.circular(
                                    !isCurrentUser && showSenderInfo
                                        ? bubbleTheme.bubbleTailRadius
                                        : bubbleTheme.bubbleBorderRadius,
                                  ),
                                  bottomRight: Radius.circular(
                                    isCurrentUser && showSenderInfo
                                        ? bubbleTheme.bubbleTailRadius
                                        : bubbleTheme.bubbleBorderRadius,
                                  ),
                                ),
                              ),
                              child: SelectableLinkify(
                                text: message.text!,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                      : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  fontSize: bubbleTheme.messageFontSize,
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

                        SizedBox(height: bubbleTheme.timestampSpacing),

                        // Timestamp
                        Text(
                          formatTimestamp(context, message.sentAt),
                          style: TextStyle(
                            fontSize: bubbleTheme.timestampFontSize,
                            color: bubbleTheme.timestampColor,
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
    final chatTheme = ChatThemeData.instance;
    final bubbleTheme = chatTheme.bubble;
    String protocolText = _getProtocolText(context);

    return Padding(
      padding: bubbleTheme.protocolOuterPadding,
      child: Center(
        child: Container(
          padding: bubbleTheme.protocolPadding,
          decoration: BoxDecoration(
            color: bubbleTheme.protocolBgColor,
            borderRadius:
                BorderRadius.circular(bubbleTheme.protocolBorderRadius),
          ),
          child: Text(
            protocolText,
            style: TextStyle(
              fontSize: bubbleTheme.protocolFontSize,
              color: bubbleTheme.protocolTextColor,
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

    final chatTheme = ChatThemeData.instance;
    final bubbleTheme = chatTheme.bubble;
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
              borderRadius:
                  BorderRadius.circular(bubbleTheme.imageBorderRadius),
              child: CachedNetworkImage(
                imageUrl: urls[i],
                width: bubbleTheme.imageWidth,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: bubbleTheme.imageWidth,
                  height: bubbleTheme.imageHeight,
                  color: bubbleTheme.imagePlaceholderColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: bubbleTheme.imageWidth,
                  height: bubbleTheme.imageHeight,
                  color: bubbleTheme.imagePlaceholderColor,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
          // Add spacing between images except for the last one
          if (i < urls.length - 1)
            SizedBox(height: bubbleTheme.imageSpacing),
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
    final chatTheme = ChatThemeData.instance;
    final bubbleTheme = chatTheme.bubble;

    String blindReason = '';
    if (message.moderated == 'M') {
      blindReason = "This message was blocked by AI moderation.";
    } else if (message.moderated == 'A') {
      blindReason = "This message was blocked as an advertisement.";
    }

    return Padding(
      padding: bubbleTheme.messagePadding,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // User info section (avatar + name) above the message
          if (showSenderInfo)
            Padding(
              padding: EdgeInsets.only(bottom: bubbleTheme.senderInfoSpacing),
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
                    SizedBox(width: bubbleTheme.avatarNameSpacing),
                    // Other user name with long press
                    GestureDetector(
                      onLongPress: () => _showMessageOptions(context),
                      child: Text(
                        userDisplayName(),
                        style: TextStyle(
                          fontSize: bubbleTheme.senderNameFontSize,
                          color: bubbleTheme.senderNameColor,
                          fontWeight: bubbleTheme.senderNameFontWeight,
                        ),
                      ),
                    ),
                  ] else ...[
                    // "You" text for current user
                    Text(
                      "You",
                      style: TextStyle(
                        fontSize: bubbleTheme.senderNameFontSize,
                        color: bubbleTheme.senderNameColor,
                        fontWeight: bubbleTheme.senderNameFontWeight,
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
                      maxWidth:
                          constraints.maxWidth * bubbleTheme.maxWidthFraction,
                    ),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: bubbleTheme.textPadding,
                          decoration: BoxDecoration(
                            color: bubbleTheme.blockedBgColor,
                            borderRadius: BorderRadius.circular(
                              bubbleTheme.bubbleBorderRadius,
                            ).copyWith(
                              bottomLeft: Radius.circular(
                                !isCurrentUser && showSenderInfo
                                    ? bubbleTheme.bubbleTailRadius
                                    : bubbleTheme.bubbleBorderRadius,
                              ),
                              bottomRight: Radius.circular(
                                isCurrentUser && showSenderInfo
                                    ? bubbleTheme.bubbleTailRadius
                                    : bubbleTheme.bubbleBorderRadius,
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
                                    size: bubbleTheme.blockedIconSize,
                                    color: bubbleTheme.blockedTextColor,
                                  ),
                                  SizedBox(
                                    width: bubbleTheme.blockedIconSpacing,
                                  ),
                                  Text(
                                    blindReason,
                                    style: TextStyle(
                                      color: bubbleTheme.blockedTextColor,
                                      fontSize:
                                          bubbleTheme.blockedTextFontSize,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: bubbleTheme.timestampSpacing),

                        // Timestamp
                        Text(
                          formatTimestamp(context, message.sentAt),
                          style: TextStyle(
                            fontSize: bubbleTheme.timestampFontSize,
                            color: bubbleTheme.timestampColor,
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
    final chatTheme = ChatThemeData.instance;
    final bubbleTheme = chatTheme.bubble;

    return Padding(
      padding: bubbleTheme.messagePadding,
      child: GestureDetector(
        onTap: () => _showUnblockOption(context),
        child: Container(
          padding: bubbleTheme.textPadding,
          decoration: BoxDecoration(
            color: bubbleTheme.blockedBgColor,
            borderRadius:
                BorderRadius.circular(bubbleTheme.bubbleBorderRadius),
            border: Border.all(color: bubbleTheme.blockedBorderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                color: bubbleTheme.blockedTextColor,
                size: bubbleTheme.blockedIconSize,
              ),
              SizedBox(width: bubbleTheme.avatarNameSpacing),
              Flexible(
                child: Text(
                  "This message was blocked.",
                  style: TextStyle(
                    color: bubbleTheme.blockedTextColor,
                    fontSize: bubbleTheme.blockedTextFontSize,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.touch_app,
                color: bubbleTheme.timestampColor,
                size: bubbleTheme.blockedTextFontSize,
              ),
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

    final chatTheme = ChatThemeData.of(parentContext);
    final bubbleTheme = chatTheme.bubble;

    showModalBottomSheet(
      context: parentContext,
      builder: (context) => Container(
        padding: bubbleTheme.bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: bubbleTheme.bottomSheetHeaderPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: bubbleTheme.bottomSheetHeaderFontSize,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: const VisualDensity(horizontal: -4),
              leading: userAvatar(),
              title: Text("Profile"),
              onTap: () {
                Navigator.of(context).pop();
                showProfileDialog(parentContext, sender!);
              },
            ),
            SizedBox(height: bubbleTheme.bottomSheetItemSpacing),
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
            SizedBox(height: bubbleTheme.bottomSheetItemSpacing),
            // Report option
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: Text("Report", style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                ChatService.instance.showChatMessageReportDialog(
                  context: parentContext,
                  message: message,
                  roomId: roomId!,
                );
              },
            ),
            SizedBox(height: bubbleTheme.bottomSheetItemSpacing),

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

              SizedBox(height: bubbleTheme.bottomSheetItemSpacing),
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

    final chatTheme = ChatThemeData.instance;
    final bubbleTheme = chatTheme.bubble;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: bubbleTheme.bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: bubbleTheme.bottomSheetHeaderPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Blocked User Options",
                    style: TextStyle(
                      fontSize: bubbleTheme.bottomSheetHeaderFontSize,
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
            SizedBox(height: bubbleTheme.bottomSheetItemSpacing),

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
            SizedBox(height: bubbleTheme.bottomSheetItemSpacing),
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
