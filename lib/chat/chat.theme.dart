import 'package:flutter/material.dart';

class ChatThemeData {
  final ChatHeaderTheme header;
  final ChatRoomListTheme roomList;
  final ChatBubbleTheme bubble;
  final ChatInputTheme input;
  final ChatDialogTheme dialog;
  final ChatPinnedTheme pinned;
  final ChatBadgeTheme badge;

  const ChatThemeData({
    required this.header,
    required this.roomList,
    required this.bubble,
    required this.input,
    required this.dialog,
    required this.pinned,
    required this.badge,
  });

  static final ChatThemeData instance = ChatThemeData(
    header: ChatHeaderTheme.defaults,
    roomList: ChatRoomListTheme.defaults,
    bubble: ChatBubbleTheme.defaults,
    input: ChatInputTheme.defaults,
    dialog: ChatDialogTheme.defaults,
    pinned: ChatPinnedTheme.defaults,
    badge: ChatBadgeTheme.defaults,
  );
}

// ============================================================================
// ChatHeaderTheme
// ============================================================================

class ChatHeaderTheme {
  final double iconSize;
  final double menuIconSize;
  final EdgeInsets padding;
  final double bottomBorderWidth;

  const ChatHeaderTheme({
    required this.iconSize,
    required this.menuIconSize,
    required this.padding,
    required this.bottomBorderWidth,
  });

  static const defaults = ChatHeaderTheme(
    iconSize: 18.0,
    menuIconSize: 16.0,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    bottomBorderWidth: 1.0,
  );
}

// ============================================================================
// ChatRoomListTheme
// ============================================================================

class ChatRoomListTheme {
  final EdgeInsets tileMargin;
  final double tileBorderRadius;
  final double tileBorderWidth;
  final EdgeInsets tilePadding;
  final double avatarSpacing;
  final double avatarBorderRadius;
  final double avatarBorderWidth;
  final double pinnedIconSize;
  final double pinnedIconPadding;
  final double pinnedIconTiltAngle;
  final double pinnedIconBorderWidth;
  final double onlineIndicatorSize;
  final double onlineIndicatorBorderWidth;
  final double onlineIndicatorBorderRadius;
  final double favoriteIndicatorSize;
  final double favoriteIconSize;
  final double favoriteIndicatorBorderWidth;
  final double menuIconSize;
  final double titleSubtitleSpacing;
  final double rowElementSpacing;
  final EdgeInsets emptyStatePadding;
  final EdgeInsets emptyStateContainerPadding;
  final double emptyStateIconSize;
  final double emptyStateBorderRadius;
  final double emptyStateBorderWidth;
  final double emptyStateSpacing;
  final EdgeInsets listPadding;
  final EdgeInsets loadingPadding;

  const ChatRoomListTheme({
    required this.tileMargin,
    required this.tileBorderRadius,
    required this.tileBorderWidth,
    required this.tilePadding,
    required this.avatarSpacing,
    required this.avatarBorderRadius,
    required this.avatarBorderWidth,
    required this.pinnedIconSize,
    required this.pinnedIconPadding,
    required this.pinnedIconTiltAngle,
    required this.pinnedIconBorderWidth,
    required this.onlineIndicatorSize,
    required this.onlineIndicatorBorderWidth,
    required this.onlineIndicatorBorderRadius,
    required this.favoriteIndicatorSize,
    required this.favoriteIconSize,
    required this.favoriteIndicatorBorderWidth,
    required this.menuIconSize,
    required this.titleSubtitleSpacing,
    required this.rowElementSpacing,
    required this.emptyStatePadding,
    required this.emptyStateContainerPadding,
    required this.emptyStateIconSize,
    required this.emptyStateBorderRadius,
    required this.emptyStateBorderWidth,
    required this.emptyStateSpacing,
    required this.listPadding,
    required this.loadingPadding,
  });

  static const defaults = ChatRoomListTheme(
    tileMargin: EdgeInsets.only(top: 16, left: 8, right: 8),
    tileBorderRadius: 12.0,
    tileBorderWidth: 2.0,
    tilePadding: EdgeInsets.all(12),
    avatarSpacing: 12.0,
    avatarBorderRadius: 28.0,
    avatarBorderWidth: 2.0,
    pinnedIconSize: 16.0,
    pinnedIconPadding: 8.0,
    pinnedIconTiltAngle: 0.4,
    pinnedIconBorderWidth: 2.0,
    onlineIndicatorSize: 14.0,
    onlineIndicatorBorderWidth: 2.0,
    onlineIndicatorBorderRadius: 7.0,
    favoriteIndicatorSize: 16.0,
    favoriteIconSize: 8.0,
    favoriteIndicatorBorderWidth: 2.0,
    menuIconSize: 20.0,
    titleSubtitleSpacing: 4.0,
    rowElementSpacing: 4.0,
    emptyStatePadding: EdgeInsets.all(32),
    emptyStateContainerPadding: EdgeInsets.all(24),
    emptyStateIconSize: 64.0,
    emptyStateBorderRadius: 12.0,
    emptyStateBorderWidth: 2.0,
    emptyStateSpacing: 24.0,
    listPadding: EdgeInsets.all(8),
    loadingPadding: EdgeInsets.all(16),
  );
}

// ============================================================================
// ChatBubbleTheme
// ============================================================================

class ChatBubbleTheme {
  final EdgeInsets messagePadding;
  final EdgeInsets textPadding;
  final double bubbleBorderRadius;
  final double bubbleTailRadius;
  final double maxWidthFraction;
  final double senderNameFontSize;
  final FontWeight senderNameFontWeight;
  final double messageFontSize;
  final double timestampFontSize;
  final double protocolFontSize;
  final double imageWidth;
  final double imageHeight;
  final double imageBorderRadius;
  final double imageSpacing;
  final double senderInfoSpacing;
  final double avatarNameSpacing;
  final double timestampSpacing;
  final EdgeInsets protocolOuterPadding;
  final EdgeInsets protocolPadding;
  final double protocolBorderRadius;
  final double blockedIconSize;
  final double blockedTextFontSize;
  final double blockedIconSpacing;
  final EdgeInsets bottomSheetPadding;
  final EdgeInsets bottomSheetHeaderPadding;
  final double bottomSheetHeaderFontSize;
  final double bottomSheetItemSpacing;
  final Color senderNameColor;
  final Color timestampColor;
  final Color protocolBgColor;
  final Color protocolTextColor;
  final Color blockedBgColor;
  final Color blockedTextColor;
  final Color blockedBorderColor;
  final Color imagePlaceholderColor;

  const ChatBubbleTheme({
    required this.messagePadding,
    required this.textPadding,
    required this.bubbleBorderRadius,
    required this.bubbleTailRadius,
    required this.maxWidthFraction,
    required this.senderNameFontSize,
    required this.senderNameFontWeight,
    required this.messageFontSize,
    required this.timestampFontSize,
    required this.protocolFontSize,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageBorderRadius,
    required this.imageSpacing,
    required this.senderInfoSpacing,
    required this.avatarNameSpacing,
    required this.timestampSpacing,
    required this.protocolOuterPadding,
    required this.protocolPadding,
    required this.protocolBorderRadius,
    required this.blockedIconSize,
    required this.blockedTextFontSize,
    required this.blockedIconSpacing,
    required this.bottomSheetPadding,
    required this.bottomSheetHeaderPadding,
    required this.bottomSheetHeaderFontSize,
    required this.bottomSheetItemSpacing,
    required this.senderNameColor,
    required this.timestampColor,
    required this.protocolBgColor,
    required this.protocolTextColor,
    required this.blockedBgColor,
    required this.blockedTextColor,
    required this.blockedBorderColor,
    required this.imagePlaceholderColor,
  });

  static final defaults = ChatBubbleTheme(
    messagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    textPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    bubbleBorderRadius: 18.0,
    bubbleTailRadius: 4.0,
    maxWidthFraction: 0.8,
    senderNameFontSize: 14.0,
    senderNameFontWeight: FontWeight.w600,
    messageFontSize: 16.0,
    timestampFontSize: 11.0,
    protocolFontSize: 13.0,
    imageWidth: 200.0,
    imageHeight: 150.0,
    imageBorderRadius: 8.0,
    imageSpacing: 8.0,
    senderInfoSpacing: 4.0,
    avatarNameSpacing: 8.0,
    timestampSpacing: 4.0,
    protocolOuterPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    protocolPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    protocolBorderRadius: 12.0,
    blockedIconSize: 16.0,
    blockedTextFontSize: 14.0,
    blockedIconSpacing: 6.0,
    bottomSheetPadding:
        const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    bottomSheetHeaderPadding:
        const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    bottomSheetHeaderFontSize: 18.0,
    bottomSheetItemSpacing: 8.0,
    senderNameColor: Colors.grey[700]!,
    timestampColor: Colors.grey[500]!,
    protocolBgColor: Colors.grey[100]!,
    protocolTextColor: Colors.grey[600]!,
    blockedBgColor: Colors.grey[300]!,
    blockedTextColor: Colors.grey[600]!,
    blockedBorderColor: Colors.grey[400]!,
    imagePlaceholderColor: Colors.grey[300]!,
  );
}

// ============================================================================
// ChatInputTheme
// ============================================================================

class ChatInputTheme {
  final double inputBorderRadius;
  final double inputFocusBorderWidth;
  final double sendButtonSize;
  final double sendIconSize;
  final EdgeInsets inputContentPadding;
  final EdgeInsets inputAreaPadding;
  final double sendButtonSpacing;
  final double topBorderWidth;
  final double filePreviewHeight;
  final double filePreviewWidth;
  final double filePreviewBorderRadius;
  final double filePreviewSpacing;
  final double filePreviewMarginTop;
  final double deleteButtonSize;
  final double deleteButtonPadding;
  final double deleteIconSize;
  final double fileBadgeFontSize;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final double loadingSpacing;
  final double uploadProgressFontSize;

  const ChatInputTheme({
    required this.inputBorderRadius,
    required this.inputFocusBorderWidth,
    required this.sendButtonSize,
    required this.sendIconSize,
    required this.inputContentPadding,
    required this.inputAreaPadding,
    required this.sendButtonSpacing,
    required this.topBorderWidth,
    required this.filePreviewHeight,
    required this.filePreviewWidth,
    required this.filePreviewBorderRadius,
    required this.filePreviewSpacing,
    required this.filePreviewMarginTop,
    required this.deleteButtonSize,
    required this.deleteButtonPadding,
    required this.deleteIconSize,
    required this.fileBadgeFontSize,
    required this.loadingIndicatorSize,
    required this.loadingStrokeWidth,
    required this.loadingSpacing,
    required this.uploadProgressFontSize,
  });

  static const defaults = ChatInputTheme(
    inputBorderRadius: 24.0,
    inputFocusBorderWidth: 1.5,
    sendButtonSize: 48.0,
    sendIconSize: 20.0,
    inputContentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    inputAreaPadding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
    sendButtonSpacing: 8.0,
    topBorderWidth: 1.0,
    filePreviewHeight: 120.0,
    filePreviewWidth: 100.0,
    filePreviewBorderRadius: 12.0,
    filePreviewSpacing: 8.0,
    filePreviewMarginTop: 16.0,
    deleteButtonSize: 16.0,
    deleteButtonPadding: 4.0,
    deleteIconSize: 16.0,
    fileBadgeFontSize: 10.0,
    loadingIndicatorSize: 16.0,
    loadingStrokeWidth: 2.0,
    loadingSpacing: 12.0,
    uploadProgressFontSize: 12.0,
  );
}

// ============================================================================
// ChatDialogTheme
// ============================================================================

class ChatDialogTheme {
  final double borderRadius;
  final double borderWidth;
  final double elevation;
  final double maxWidth;
  final double headerIconSize;
  final EdgeInsets headerPadding;
  final double headerBorderRadius;
  final double headerBorderWidth;
  final double closeButtonBorderRadius;
  final double closeButtonBorderWidth;
  final double closeIconSize;
  final EdgeInsets contentPadding;
  final double contentSpacing;
  final double itemBorderRadius;
  final double itemBorderWidth;
  final EdgeInsets itemPadding;
  final double itemSpacing;
  final double avatarSize;
  final double avatarBorderRadius;
  final double avatarBorderWidth;
  final double avatarSpacing;
  final double searchFieldBorderRadius;
  final double searchFieldBorderWidth;
  final double searchIconSize;
  final double searchIconPadding;
  final EdgeInsets searchContentPadding;
  final double emptyIconSize;
  final double emptySpacing;
  final EdgeInsets emptyPadding;
  final EdgeInsets emptyContainerPadding;
  final double folderIconSize;
  final double folderIconSpacing;
  final EdgeInsets folderItemPadding;
  final EdgeInsets countBadgePadding;
  final double countBadgeBorderRadius;
  final double countBadgeBorderWidth;
  final double countBadgeSpacing;
  final EdgeInsets titlePadding;
  final EdgeInsets bodyPadding;
  final EdgeInsets actionsPadding;
  final double actionButtonBorderRadius;
  final double actionButtonBorderWidth;
  final EdgeInsets actionButtonPadding;
  final double dividerThickness;
  final double dividerHeight;
  final double maxHeight;
  final double listMaxHeight;
  final EdgeInsets reportChipPadding;
  final double reportChipSpacing;
  final double reportChipRunSpacing;
  final EdgeInsets chatButtonPadding;
  final double chatButtonBorderRadius;
  final double chatButtonBorderWidth;
  final EdgeInsets dialogUnreadBadgePadding;
  final double dialogUnreadBadgeBorderRadius;
  final double dialogUnreadBadgeBorderWidth;

  const ChatDialogTheme({
    required this.borderRadius,
    required this.borderWidth,
    required this.elevation,
    required this.maxWidth,
    required this.headerIconSize,
    required this.headerPadding,
    required this.headerBorderRadius,
    required this.headerBorderWidth,
    required this.closeButtonBorderRadius,
    required this.closeButtonBorderWidth,
    required this.closeIconSize,
    required this.contentPadding,
    required this.contentSpacing,
    required this.itemBorderRadius,
    required this.itemBorderWidth,
    required this.itemPadding,
    required this.itemSpacing,
    required this.avatarSize,
    required this.avatarBorderRadius,
    required this.avatarBorderWidth,
    required this.avatarSpacing,
    required this.searchFieldBorderRadius,
    required this.searchFieldBorderWidth,
    required this.searchIconSize,
    required this.searchIconPadding,
    required this.searchContentPadding,
    required this.emptyIconSize,
    required this.emptySpacing,
    required this.emptyPadding,
    required this.emptyContainerPadding,
    required this.folderIconSize,
    required this.folderIconSpacing,
    required this.folderItemPadding,
    required this.countBadgePadding,
    required this.countBadgeBorderRadius,
    required this.countBadgeBorderWidth,
    required this.countBadgeSpacing,
    required this.titlePadding,
    required this.bodyPadding,
    required this.actionsPadding,
    required this.actionButtonBorderRadius,
    required this.actionButtonBorderWidth,
    required this.actionButtonPadding,
    required this.dividerThickness,
    required this.dividerHeight,
    required this.maxHeight,
    required this.listMaxHeight,
    required this.reportChipPadding,
    required this.reportChipSpacing,
    required this.reportChipRunSpacing,
    required this.chatButtonPadding,
    required this.chatButtonBorderRadius,
    required this.chatButtonBorderWidth,
    required this.dialogUnreadBadgePadding,
    required this.dialogUnreadBadgeBorderRadius,
    required this.dialogUnreadBadgeBorderWidth,
  });

  static const defaults = ChatDialogTheme(
    borderRadius: 12.0,
    borderWidth: 2.0,
    elevation: 0.0,
    maxWidth: 400.0,
    headerIconSize: 20.0,
    headerPadding: EdgeInsets.all(16),
    headerBorderRadius: 10.0,
    headerBorderWidth: 2.0,
    closeButtonBorderRadius: 8.0,
    closeButtonBorderWidth: 2.0,
    closeIconSize: 16.0,
    contentPadding: EdgeInsets.all(16),
    contentSpacing: 16.0,
    itemBorderRadius: 8.0,
    itemBorderWidth: 2.0,
    itemPadding: EdgeInsets.all(12),
    itemSpacing: 8.0,
    avatarSize: 40.0,
    avatarBorderRadius: 20.0,
    avatarBorderWidth: 2.0,
    avatarSpacing: 12.0,
    searchFieldBorderRadius: 8.0,
    searchFieldBorderWidth: 2.0,
    searchIconSize: 20.0,
    searchIconPadding: 12.0,
    searchContentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    emptyIconSize: 48.0,
    emptySpacing: 16.0,
    emptyPadding: EdgeInsets.all(32),
    emptyContainerPadding: EdgeInsets.all(24),
    folderIconSize: 20.0,
    folderIconSpacing: 16.0,
    folderItemPadding: EdgeInsets.all(16),
    countBadgePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    countBadgeBorderRadius: 8.0,
    countBadgeBorderWidth: 2.0,
    countBadgeSpacing: 8.0,
    titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 16),
    bodyPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    actionsPadding: EdgeInsets.fromLTRB(24, 16, 24, 24),
    actionButtonBorderRadius: 8.0,
    actionButtonBorderWidth: 2.0,
    actionButtonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    dividerThickness: 2.0,
    dividerHeight: 24.0,
    maxHeight: 500.0,
    listMaxHeight: 400.0,
    reportChipPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    reportChipSpacing: 8.0,
    reportChipRunSpacing: 8.0,
    chatButtonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    chatButtonBorderRadius: 8.0,
    chatButtonBorderWidth: 2.0,
    dialogUnreadBadgePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    dialogUnreadBadgeBorderRadius: 8.0,
    dialogUnreadBadgeBorderWidth: 2.0,
  );

  BoxDecoration containerDecoration(ColorScheme scheme) => BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: scheme.outline, width: borderWidth),
      );

  ButtonStyle actionButtonStyle(ColorScheme scheme,
          {bool destructive = false}) =>
      ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(actionButtonBorderRadius),
          side: BorderSide(
            color: destructive ? scheme.error : scheme.outline,
            width: actionButtonBorderWidth,
          ),
        ),
        padding: actionButtonPadding,
      );
}

// ============================================================================
// ChatPinnedTheme
// ============================================================================

class ChatPinnedTheme {
  final double sectionBorderWidth;
  final EdgeInsets headerPadding;
  final double iconSize;
  final double iconSpacing;
  final double listHeight;
  final EdgeInsets listPadding;
  final double dividerSpacing;
  final double itemWidth;
  final EdgeInsets itemPadding;
  final EdgeInsets itemHPadding;
  final double avatarSize;
  final double closeButtonSize;
  final double closeButtonBorderWidth;
  final double closeIconSize;
  final EdgeInsets countBadgePadding;
  final double countBadgeBorderRadius;
  final double countBadgeBorderWidth;
  final EdgeInsets unreadBadgePadding;
  final double unreadBadgeBorderRadius;
  final double unreadBadgeBorderWidth;
  final double unreadBadgeFontSize;
  final double nameSpacing;
  final double unpinDialogBorderRadius;
  final double unpinDialogBorderWidth;
  final EdgeInsets unpinTitlePadding;
  final EdgeInsets unpinBodyPadding;
  final EdgeInsets unpinActionsPadding;
  final double unpinButtonBorderRadius;
  final double unpinButtonBorderWidth;
  final EdgeInsets unpinButtonPadding;
  final double unpinButtonSpacing;

  const ChatPinnedTheme({
    required this.sectionBorderWidth,
    required this.headerPadding,
    required this.iconSize,
    required this.iconSpacing,
    required this.listHeight,
    required this.listPadding,
    required this.dividerSpacing,
    required this.itemWidth,
    required this.itemPadding,
    required this.itemHPadding,
    required this.avatarSize,
    required this.closeButtonSize,
    required this.closeButtonBorderWidth,
    required this.closeIconSize,
    required this.countBadgePadding,
    required this.countBadgeBorderRadius,
    required this.countBadgeBorderWidth,
    required this.unreadBadgePadding,
    required this.unreadBadgeBorderRadius,
    required this.unreadBadgeBorderWidth,
    required this.unreadBadgeFontSize,
    required this.nameSpacing,
    required this.unpinDialogBorderRadius,
    required this.unpinDialogBorderWidth,
    required this.unpinTitlePadding,
    required this.unpinBodyPadding,
    required this.unpinActionsPadding,
    required this.unpinButtonBorderRadius,
    required this.unpinButtonBorderWidth,
    required this.unpinButtonPadding,
    required this.unpinButtonSpacing,
  });

  static const defaults = ChatPinnedTheme(
    sectionBorderWidth: 2.0,
    headerPadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
    iconSize: 16.0,
    iconSpacing: 8.0,
    listHeight: 80.0,
    listPadding: EdgeInsets.symmetric(horizontal: 12),
    dividerSpacing: 8.0,
    itemWidth: 64.0,
    itemPadding: EdgeInsets.all(4),
    itemHPadding: EdgeInsets.symmetric(horizontal: 4),
    avatarSize: 44.0,
    closeButtonSize: 18.0,
    closeButtonBorderWidth: 1.5,
    closeIconSize: 9.0,
    countBadgePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    countBadgeBorderRadius: 8.0,
    countBadgeBorderWidth: 2.0,
    unreadBadgePadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    unreadBadgeBorderRadius: 32.0,
    unreadBadgeBorderWidth: 1.5,
    unreadBadgeFontSize: 8.0,
    nameSpacing: 6.0,
    unpinDialogBorderRadius: 12.0,
    unpinDialogBorderWidth: 2.0,
    unpinTitlePadding: EdgeInsets.fromLTRB(24, 24, 24, 16),
    unpinBodyPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    unpinActionsPadding: EdgeInsets.fromLTRB(24, 16, 24, 24),
    unpinButtonBorderRadius: 8.0,
    unpinButtonBorderWidth: 2.0,
    unpinButtonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    unpinButtonSpacing: 8.0,
  );
}

// ============================================================================
// ChatBadgeTheme
// ============================================================================

class ChatBadgeTheme {
  final EdgeInsets padding;
  final double borderRadius;
  final double borderWidth;
  final double fontSize;

  const ChatBadgeTheme({
    required this.padding,
    required this.borderRadius,
    required this.borderWidth,
    required this.fontSize,
  });

  static const defaults = ChatBadgeTheme(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    borderRadius: 50.0,
    borderWidth: 2.0,
    fontSize: 10.0,
  );
}
