import 'package:flutter/material.dart';
import 'package:philgo/theme.dart';

ThemeData chatThemeData(BuildContext context) {
  return philgoThemeData(context).copyWith();
}

// ============================================================================
// Header
// ============================================================================
const headerIconSize = 18.0;
const headerMenuIconSize = 16.0;
const headerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const headerBottomBorderWidth = 1.0;

// ============================================================================
// Room List
// ============================================================================
const tileMargin = EdgeInsets.only(top: 16, left: 8, right: 8);
const tileBorderRadius = 12.0;
const tileBorderWidth = 2.0;
const tilePadding = EdgeInsets.all(12);
const avatarSpacing = 12.0;
const avatarBorderRadius = 28.0;
const avatarBorderWidth = 2.0;
const pinnedIconSize = 16.0;
const pinnedIconPadding = 8.0;
const pinnedIconTiltAngle = 0.4;
const pinnedIconBorderWidth = 2.0;
const onlineIndicatorSize = 14.0;
const onlineIndicatorBorderWidth = 2.0;
const onlineIndicatorBorderRadius = 7.0;
const favoriteIndicatorSize = 16.0;
const favoriteIconSize = 8.0;
const favoriteIndicatorBorderWidth = 2.0;
const roomListMenuIconSize = 20.0;
const titleSubtitleSpacing = 4.0;
const rowElementSpacing = 4.0;
const emptyStatePadding = EdgeInsets.all(32);
const emptyStateContainerPadding = EdgeInsets.all(24);
const emptyStateIconSize = 64.0;
const emptyStateBorderRadius = 12.0;
const emptyStateBorderWidth = 2.0;
const emptyStateSpacing = 24.0;
const roomListPadding = EdgeInsets.all(8);
const roomListLoadingPadding = EdgeInsets.all(16);

// ============================================================================
// Bubble
// ============================================================================
const messagePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);
const textPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
const bubbleBorderRadius = 18.0;
const bubbleTailRadius = 4.0;
const maxWidthFraction = 0.8;
const senderNameFontSize = 14.0;
const senderNameFontWeight = FontWeight.w600;
const messageFontSize = 16.0;
const timestampFontSize = 11.0;
const protocolFontSize = 13.0;
const bubbleImageWidth = 200.0;
const bubbleImageHeight = 150.0;
const bubbleImageBorderRadius = 8.0;
const imageSpacing = 8.0;
const senderInfoSpacing = 4.0;
const avatarNameSpacing = 8.0;
const timestampSpacing = 4.0;
const protocolOuterPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const protocolPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
const protocolBorderRadius = 12.0;
const blockedIconSize = 16.0;
const blockedTextFontSize = 14.0;
const blockedIconSpacing = 6.0;
const bottomSheetPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);
const bottomSheetHeaderPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 10);
const bottomSheetHeaderFontSize = 18.0;
const bottomSheetItemSpacing = 8.0;
final senderNameColor = Colors.grey[700]!;
final timestampColor = Colors.grey[500]!;
final protocolBgColor = Colors.grey[100]!;
final protocolTextColor = Colors.grey[600]!;
final blockedBgColor = Colors.grey[300]!;
final blockedTextColor = Colors.grey[600]!;
final blockedBorderColor = Colors.grey[400]!;
final imagePlaceholderColor = Colors.grey[300]!;

// ============================================================================
// Input
// ============================================================================
const inputBorderRadius = 24.0;
const inputFocusBorderWidth = 1.5;
const sendButtonSize = 48.0;
const sendIconSize = 20.0;
const inputContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const inputAreaPadding = EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16);
const sendButtonSpacing = 8.0;
const inputTopBorderWidth = 1.0;
const filePreviewHeight = 120.0;
const filePreviewWidth = 100.0;
const filePreviewBorderRadius = 12.0;
const filePreviewSpacing = 8.0;
const filePreviewMarginTop = 16.0;
const deleteButtonSize = 16.0;
const deleteButtonPadding = 4.0;
const deleteIconSize = 16.0;
const fileBadgeFontSize = 10.0;
const loadingIndicatorSize = 16.0;
const loadingStrokeWidth = 2.0;
const loadingSpacing = 12.0;
const uploadProgressFontSize = 12.0;

// ============================================================================
// Dialog
// ============================================================================
const dialogBorderRadius = 12.0;
const dialogBorderWidth = 2.0;
const dialogElevation = 0.0;
const dialogMaxWidth = 400.0;
const dialogHeaderIconSize = 20.0;
const dialogHeaderPadding = EdgeInsets.all(16);
const dialogHeaderBorderRadius = 10.0;
const dialogHeaderBorderWidth = 2.0;
const closeButtonBorderRadius = 8.0;
const closeButtonBorderWidth = 2.0;
const closeIconSize = 16.0;
const dialogContentPadding = EdgeInsets.all(16);
const dialogContentSpacing = 16.0;
const dialogItemBorderRadius = 8.0;
const dialogItemBorderWidth = 2.0;
const dialogItemPadding = EdgeInsets.all(12);
const dialogItemSpacing = 8.0;
const dialogAvatarSize = 40.0;
const dialogAvatarBorderRadius = 20.0;
const dialogAvatarBorderWidth = 2.0;
const dialogAvatarSpacing = 12.0;
const searchIconSize = 20.0;
const searchIconPadding = 12.0;
const searchContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const dialogEmptyIconSize = 48.0;
const dialogEmptySpacing = 16.0;
const dialogEmptyPadding = EdgeInsets.all(32);
const dialogEmptyContainerPadding = EdgeInsets.all(24);
const folderIconSize = 20.0;
const folderIconSpacing = 16.0;
const folderItemPadding = EdgeInsets.all(16);
const countBadgePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
const countBadgeBorderRadius = 8.0;
const countBadgeBorderWidth = 2.0;
const countBadgeSpacing = 8.0;
const dialogTitlePadding = EdgeInsets.fromLTRB(24, 24, 24, 16);
const dialogBodyPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 8);
const dialogActionsPadding = EdgeInsets.fromLTRB(24, 16, 24, 24);
const actionButtonBorderRadius = 8.0;
const actionButtonBorderWidth = 2.0;
const actionButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const dialogDividerThickness = 2.0;
const dialogDividerHeight = 24.0;
const dialogMaxHeight = 500.0;
const dialogListMaxHeight = 400.0;
const reportChipPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const reportChipSpacing = 8.0;
const reportChipRunSpacing = 8.0;
const chatButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const chatButtonBorderRadius = 8.0;
const chatButtonBorderWidth = 2.0;
const dialogUnreadBadgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
const dialogUnreadBadgeBorderRadius = 8.0;
const dialogUnreadBadgeBorderWidth = 2.0;
const dialogCloseButtonPadding = EdgeInsets.all(8);
const dialogButtonSpacing = 8.0;
const subtitleSpacing = 4.0;
const menuItemIconSize = 16.0;
const menuItemSpacing = 12.0;

// ============================================================================
// Pinned
// ============================================================================
const pinnedSectionBorderWidth = 2.0;
const pinnedHeaderPadding = EdgeInsets.fromLTRB(16, 16, 16, 8);
const pinnedSectionIconSize = 16.0;
const pinnedSectionIconSpacing = 8.0;
const pinnedListHeight = 80.0;
const pinnedListPadding = EdgeInsets.symmetric(horizontal: 12);
const pinnedDividerSpacing = 8.0;
const pinnedItemWidth = 64.0;
const pinnedItemPadding = EdgeInsets.all(4);
const pinnedItemHPadding = EdgeInsets.symmetric(horizontal: 4);
const pinnedAvatarSize = 44.0;
const pinnedCloseButtonSize = 18.0;
const pinnedCloseButtonBorderWidth = 1.5;
const pinnedCloseIconSize = 9.0;
const pinnedCountBadgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);
const pinnedCountBadgeBorderRadius = 8.0;
const pinnedCountBadgeBorderWidth = 2.0;
const pinnedUnreadBadgePadding = EdgeInsets.symmetric(horizontal: 5, vertical: 1);
const pinnedUnreadBadgeBorderRadius = 32.0;
const pinnedUnreadBadgeBorderWidth = 1.5;
const pinnedUnreadBadgeFontSize = 8.0;
const pinnedNameSpacing = 6.0;
const unpinDialogBorderRadius = 12.0;
const unpinDialogBorderWidth = 2.0;
const unpinTitlePadding = EdgeInsets.fromLTRB(24, 24, 24, 16);
const unpinBodyPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 8);
const unpinActionsPadding = EdgeInsets.fromLTRB(24, 16, 24, 24);
const unpinButtonBorderRadius = 8.0;
const unpinButtonBorderWidth = 2.0;
const unpinButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const unpinButtonSpacing = 8.0;

// ============================================================================
// Badge
// ============================================================================
const badgePadding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
const badgeBorderRadius = 50.0;
const badgeBorderWidth = 2.0;
const badgeFontSize = 10.0;

// ============================================================================
// Message List
// ============================================================================
const msgListEmptyIconSize = 80.0;
final msgListEmptyIconColor = Colors.grey[400]!;
const msgListEmptyTextFontSize = 16.0;
final msgListEmptyTextColor = Colors.grey[600]!;
const msgListEmptySpacing = 16.0;
const msgListLoadingStrokeWidth = 3.0;
const msgListTopBorderWidth = 1.0;
const msgListLoadingPadding = EdgeInsets.all(16);
