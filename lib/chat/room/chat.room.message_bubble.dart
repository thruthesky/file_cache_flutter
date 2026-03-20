import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/list/widgets/display_thumbnail.dart';
import 'package:philgo/file/file.functions.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:philgo/router.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/widgets/avatar.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/user/widgets/block_user_dialog.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:philgo/common_widgets/full_screen_media_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Message bubble widget for displaying chat messages
class ChatRoomMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final UserModel? sender;
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

    // Check if message is deleted (soft delete)
    if (message.isDeleted) {
      return _buildDeletedMessage(context);
    }

    // Check if message should be blinded due to moderation
    if (_shouldBlindMessage()) {
      return _buildBlindedMessage(context);
    }

    // Check if message is from a blocked user (only for other users' messages)
    if (!isCurrentUser && sender != null) {
      return Blocked(
        otherUserUid: sender!.firebaseUid,
        yes: () => _buildBlockedMessage(context),
        no: () => _buildNormalMessage(context),
      );
    }

    return _buildNormalMessage(context);
  }

  /// Build normal message bubble
  Widget _buildNormalMessage(BuildContext context) {
    return Padding(
      padding: messagePadding,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // User info section (avatar + name) above the message
          if (showSenderInfo)
            Padding(
              padding: EdgeInsets.only(bottom: senderInfoSpacing),
              child: Row(
                mainAxisAlignment: isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!isCurrentUser) ...[
                    // Other user avatar with long press
                    GestureDetector(
                      onTap: () => !isAdminChatUser(sender!.firebaseUid)
                          ? _showMessageOptions(context)
                          : null,
                      child: userAvatar(),
                    ),
                    SizedBox(width: avatarNameSpacing),
                    // Other user name with long press
                    GestureDetector(
                      onTap: () => !isAdminChatUser(sender!.firebaseUid)
                          ? _showMessageOptions(context)
                          : null,
                      child: Text(
                        userDisplayName(),
                        style: TextStyle(
                          fontSize: senderNameFontSize,
                          color: senderNameColor,
                          fontWeight: senderNameFontWeight,
                        ),
                      ),
                    ),
                  ] else ...[
                    // "You" text for current user
                    Text(
                      '나'.tr(),
                      style: TextStyle(
                        fontSize: senderNameFontSize,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: senderNameFontWeight,
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
                  // 3-dot menu icon for current user's messages
                  if (isCurrentUser && (_canEdit() || _canDelete()))
                    GestureDetector(
                      onTap: () => _showMessageOptionsOrEditDelete(context),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2, right: 4),
                        child: FaIcon(
                          FontAwesomeIcons.ellipsisVertical,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 150),
                        ),
                      ),
                    ),
                  // Message bubble content - max 80% width
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints.maxWidth * maxWidthFraction,
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
                            SizedBox(height: imageSpacing),
                        ],
                        if (message.text?.isNotEmpty == true)
                          Container(
                              padding: textPadding,
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 50)
                                    : Theme.of(context).colorScheme.onSecondary,
                                borderRadius:
                                    BorderRadius.circular(
                                      bubbleBorderRadius,
                                    ).copyWith(
                                      bottomLeft: Radius.circular(
                                        !isCurrentUser && showSenderInfo
                                            ? bubbleTailRadius
                                            : bubbleBorderRadius,
                                      ),
                                      bottomRight: Radius.circular(
                                        isCurrentUser && showSenderInfo
                                            ? bubbleTailRadius
                                            : bubbleBorderRadius,
                                      ),
                                    ),
                              ),
                              child: SelectableLinkify(
                                text: message.text!,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.secondary,
                                  fontSize: messageFontSize,
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

                        SizedBox(height: timestampSpacing),

                        // Timestamp + edited indicator
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTimestamp(context, message.sentAt),
                              style: TextStyle(
                                fontSize: timestampFontSize,
                                color: timestampColor,
                              ),
                            ),
                            if (message.isEdited) ...[
                              SizedBox(width: 4),
                              Text(
                                '(수정됨)'.tr(),
                                style: TextStyle(
                                  fontSize: timestampFontSize,
                                  color: timestampColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
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

  /// Show appropriate options menu based on message ownership
  void _showMessageOptionsOrEditDelete(BuildContext context) {
    if (_canEdit() || _canDelete()) {
      _showEditDeleteOptions(context);
    } else {
      _showMessageOptions(context);
    }
  }

  /// Show edit/delete options for current user's messages
  void _showEditDeleteOptions(BuildContext parentContext) {
    if (roomId == null) return;

    showModalBottomSheet(
      context: parentContext,
      builder: (context) => Container(
        padding: bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: bottomSheetHeaderPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '메시지 옵션'.tr(),
                    style: TextStyle(
                      fontSize: bottomSheetHeaderFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: '닫기'.tr(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Edit option (only for own messages with text)
            if (_canEdit() && message.text?.isNotEmpty == true)
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.lightPenToSquare,
                  color: Theme.of(parentContext).colorScheme.primary,
                  size: 20,
                ),
                title: Text('수정'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditDialog(parentContext);
                },
              ),

            // Delete option (own messages + admins)
            if (_canDelete())
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.lightTrashCan,
                  color: Colors.red,
                  size: 20,
                ),
                title: Text(
                  '삭제'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmDialog(parentContext);
                },
              ),

            SizedBox(height: bottomSheetItemSpacing),
          ],
        ),
      ),
    );
  }

  /// Show edit dialog with text field
  void _showEditDialog(BuildContext parentContext) {
    final controller = TextEditingController(text: message.text ?? '');
    final theme = Theme.of(parentContext);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: parentContext,
      builder: (context) => Dialog(
        elevation: dialogElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogBorderRadius),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline,
              width: dialogBorderWidth,
            ),
            borderRadius: BorderRadius.circular(dialogBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Padding(
                padding: dialogTitlePadding,
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightPenToSquare,
                      color: colorScheme.primary,
                      size: dialogHeaderIconSize,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '메시지 수정'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Text field
              Padding(
                padding: dialogBodyPadding,
                child: TextField(
                  controller: controller,
                  maxLines: 5,
                  minLines: 2,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: '메시지를 입력하세요'.tr(),
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: dialogActionsPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('취소'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final newText = controller.text.trim();
                        if (newText.isEmpty) return;
                        if (newText == message.text) {
                          Navigator.of(context).pop();
                          return;
                        }
                        try {
                          await ChatService.instance.editMessage(
                            roomId: roomId!,
                            messageId: message.id!,
                            newText: newText,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('수정에 실패했습니다'.tr()),
                              ),
                            );
                          }
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.primary,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onPrimary,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('저장'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmDialog(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: parentContext,
      builder: (context) => Dialog(
        elevation: dialogElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogBorderRadius),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline,
              width: dialogBorderWidth,
            ),
            borderRadius: BorderRadius.circular(dialogBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Padding(
                padding: dialogTitlePadding,
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightTrashCan,
                      color: colorScheme.error,
                      size: dialogHeaderIconSize,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '메시지 삭제'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: dialogBodyPadding,
                child: Text(
                  '이 메시지를 삭제하시겠습니까?'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: dialogActionsPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('취소'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await ChatService.instance.deleteMessage(
                            roomId: roomId!,
                            messageId: message.id!,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('삭제에 실패했습니다'.tr()),
                              ),
                            );
                          }
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onError,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('삭제'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build deleted message placeholder
  Widget _buildDeletedMessage(BuildContext context) {
    return Padding(
      padding: messagePadding,
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: textPadding,
            decoration: BoxDecoration(
              color: blockedBgColor,
              borderRadius: BorderRadius.circular(bubbleBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTrashCan,
                  size: blockedIconSize,
                  color: blockedTextColor,
                ),
                SizedBox(width: blockedIconSpacing),
                Text(
                  '삭제된 메시지입니다'.tr(),
                  style: TextStyle(
                    color: blockedTextColor,
                    fontSize: blockedTextFontSize,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Check if current user is an admin
  bool _isAdmin() {
    final uid = loginUid();
    if (uid == null) return false;
    final settings = SettingsState.of(globalContext).settings;
    return settings?.adminUids.contains(uid) ?? false;
  }

  /// Check if current user can edit this message
  bool _canEdit() {
    return isCurrentUser && !message.isDeleted;
  }

  /// Check if current user can delete this message
  bool _canDelete() {
    return (isCurrentUser || _isAdmin()) && !message.isDeleted;
  }

  /// Build protocol message (system messages) centered with light gray color
  Widget _buildProtocolMessage(BuildContext context) {
    String protocolText = _getProtocolText(context);

    return Padding(
      padding: protocolOuterPadding,
      child: Center(
        child: Container(
          padding: protocolPadding,
          decoration: BoxDecoration(
            color: protocolBgColor,
            borderRadius: BorderRadius.circular(
              protocolBorderRadius,
            ),
          ),
          child: Text(
            protocolText,
            style: TextStyle(
              fontSize: protocolFontSize,
              color: protocolTextColor,
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
        return '채팅방이 생성되었습니다'.tr();
      case ChatProtocol.join:
        return '{}님이 입장했습니다'.tr(args: [senderName]);
      case ChatProtocol.invitationNotSent:
        return '초대가 전송되지 않았습니다'.tr();
      case ChatProtocol.left:
        return '{}님이 퇴장했습니다'.tr(args: [senderName]);
      case ChatProtocol.removed:
        return '{}님이 방에서 제거되었습니다'.tr(args: [senderName]);
      default:
        // Fallback to the message text if protocol is not recognized
        return message.text ?? '';
    }
  }

  /// Build user avatar widget
  Widget userAvatar() {
    return Avatar(
      photoUrl: sender?.photoUrl != null && sender!.photoUrl.isNotEmpty
          ? sender!.photoUrl
          : null,
    );
  }

  /// Get user display name
  String userDisplayName() {
    if (sender == null) return '이름없음'.tr();

    if (sender!.nickname.isNotEmpty) {
      return sender!.nickname;
    } else {
      return '이름없음'.tr();
    }
  }

  /// Build multiple files vertically (images, videos, and other files)
  Widget _buildMultipleImages(BuildContext context) {
    if (message.urls == null || message.urls!.isEmpty) {
      return const SizedBox.shrink();
    }

    final urls = message.urls!;
    final mediaUrls = urls.where((u) {
      final type = getMediaType(toAbsoluteUrl(u));
      return type == MediaType.image || type == MediaType.video;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < urls.length; i++) ...[
          GestureDetector(
            onTap: () {
              final absoluteUrl = toAbsoluteUrl(urls[i]);
              final type = getMediaType(absoluteUrl);
              if (type == MediaType.file) {
                launchUrl(
                  Uri.parse(absoluteUrl),
                  mode: LaunchMode.externalApplication,
                );
              } else if (onImageTap != null) {
                onImageTap!(urls[i]);
              } else {
                final mediaIndex = mediaUrls.indexOf(urls[i]);
                _showFullScreenMedia(
                  context,
                  mediaUrls.map((u) => toAbsoluteUrl(u)).toList(),
                  mediaIndex >= 0 ? mediaIndex : 0,
                );
              }
            },
            child: DisplayThumbnail(
              url: urls[i],
              size: bubbleImageWidth,
            ),
          ),
          // Add spacing between files except for the last one
          if (i < urls.length - 1) SizedBox(height: imageSpacing),
        ],
      ],
    );
  }

  /// Show full screen media viewer (images and videos)
  void _showFullScreenMedia(
    BuildContext context,
    List<String> mediaUrls,
    int initialIndex,
  ) async {
    // Use await to prevent widget rebuild on navigation back
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          mediaUrls: mediaUrls,
          initialIndex: initialIndex,
        ),
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
      blindReason = '이 메시지는 AI 검토에 의해 차단되었습니다.'.tr();
    } else if (message.moderated == 'A') {
      blindReason = '이 메시지는 광고로 차단되었습니다.'.tr();
    }

    return Padding(
      padding: messagePadding,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // User info section (avatar + name) above the message
          if (showSenderInfo)
            Padding(
              padding: EdgeInsets.only(bottom: senderInfoSpacing),
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
                    SizedBox(width: avatarNameSpacing),
                    // Other user name with long press
                    GestureDetector(
                      onLongPress: () => _showMessageOptions(context),
                      child: Text(
                        userDisplayName(),
                        style: TextStyle(
                          fontSize: senderNameFontSize,
                          color: senderNameColor,
                          fontWeight: senderNameFontWeight,
                        ),
                      ),
                    ),
                  ] else ...[
                    // "You" text for current user
                    Text(
                      '나'.tr(),
                      style: TextStyle(
                        fontSize: senderNameFontSize,
                        color: senderNameColor,
                        fontWeight: senderNameFontWeight,
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
                          constraints.maxWidth * maxWidthFraction,
                    ),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: textPadding,
                          decoration: BoxDecoration(
                            color: blockedBgColor,
                            borderRadius:
                                BorderRadius.circular(
                                  bubbleBorderRadius,
                                ).copyWith(
                                  bottomLeft: Radius.circular(
                                    !isCurrentUser && showSenderInfo
                                        ? bubbleTailRadius
                                        : bubbleBorderRadius,
                                  ),
                                  bottomRight: Radius.circular(
                                    isCurrentUser && showSenderInfo
                                        ? bubbleTailRadius
                                        : bubbleBorderRadius,
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
                                    size: blockedIconSize,
                                    color: blockedTextColor,
                                  ),
                                  SizedBox(
                                    width: blockedIconSpacing,
                                  ),
                                  Text(
                                    blindReason,
                                    style: TextStyle(
                                      color: blockedTextColor,
                                      fontSize: blockedTextFontSize,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: timestampSpacing),

                        // Timestamp
                        Text(
                          formatTimestamp(context, message.sentAt),
                          style: TextStyle(
                            fontSize: timestampFontSize,
                            color: timestampColor,
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
      padding: messagePadding,
      child: GestureDetector(
        onTap: () => _showUnblockOption(context),
        child: Container(
          padding: textPadding,
          decoration: BoxDecoration(
            color: blockedBgColor,
            borderRadius: BorderRadius.circular(bubbleBorderRadius),
            border: Border.all(color: blockedBorderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                color: blockedTextColor,
                size: blockedIconSize,
              ),
              SizedBox(width: avatarNameSpacing),
              Flexible(
                child: Text(
                  '이 메시지는 차단되었습니다.'.tr(),
                  style: TextStyle(
                    color: blockedTextColor,
                    fontSize: blockedTextFontSize,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.touch_app,
                color: timestampColor,
                size: blockedTextFontSize,
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

    showModalBottomSheet(
      context: parentContext,
      builder: (context) => Container(
        padding: bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: bottomSheetHeaderPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '메뉴'.tr(),
                    style: TextStyle(
                      fontSize: bottomSheetHeaderFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: '닫기'.tr(),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: const VisualDensity(horizontal: -4),
              leading: userAvatar(),
              title: Text('프로필'.tr()),
              onTap: () {
                Navigator.of(context).pop();
                showProfileDialog(parentContext, sender!);
              },
            ),
            SizedBox(height: bottomSheetItemSpacing),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: Text('최근 글'.tr()),
              onTap: () {
                Navigator.of(context).pop();
                showUserRecentPostsDialog(
                  context: parentContext,
                  otherUser: sender!,
                );
              },
            ),
            SizedBox(height: bottomSheetItemSpacing),
            // Report option
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: Text('신고'.tr(), style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                ChatService.instance.showChatMessageReportDialog(
                  context: parentContext,
                  message: message,
                  roomId: roomId!,
                );
              },
            ),
            SizedBox(height: bottomSheetItemSpacing),

            // Block/Unblock option (only if sender is not current user)
            if (sender != null) ...[
              Blocked(
                otherUserUid: sender!.firebaseUid,
                yes: () => ListTile(
                  leading: Icon(Icons.person_add, color: Colors.green),
                  title: Text(
                    '차단 해제'.tr(),
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
                    '사용자 차단'.tr(),
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBlockDialog(parentContext);
                  },
                ),
              ),

              SizedBox(height: bottomSheetItemSpacing),
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
        otherUserUid: sender!.firebaseUid,
        yes: () => UnblockUserDialog(
          otherUserUid: sender!.firebaseUid,
          onUnblocked: () {
            // Optionally refresh or show success message
          },
        ),
        no: () => BlockUserDialog(
          otherUserUid: sender!.firebaseUid,
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
        padding: bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: bottomSheetHeaderPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '차단된 사용자 옵션'.tr(),
                    style: TextStyle(
                      fontSize: bottomSheetHeaderFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: '닫기'.tr(),
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
              subtitle: Text('이 메시지는 차단되었습니다.'.tr()),
            ),
            SizedBox(height: bottomSheetItemSpacing),

            // Unblock option
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.green),
              title: Text(
                '차단 해제'.tr(),
                style: const TextStyle(color: Colors.green),
              ),
              subtitle: Text('이 사용자의 차단을 해제하면 메시지를 볼 수 있습니다.'.tr()),
              onTap: () {
                Navigator.of(context).pop();
                _performUnblock(context);
              },
            ),
            SizedBox(height: bottomSheetItemSpacing),
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
        otherUserUid: sender!.firebaseUid,
        onUnblocked: () {
          // Show success message
        },
      ),
    );
  }
}
