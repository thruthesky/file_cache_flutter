import 'dart:ui';

import 'package:flutter/material.dart';

/// 채팅 모듈의 모든 디자인 토큰을 중앙 관리하는 테마 데이터
///
/// Flutter ThemeExtension을 사용하여 Theme.of(context)로 접근 가능
/// 사용법: `final chatTheme = ChatThemeData.of(context);`
class ChatThemeData extends ThemeExtension<ChatThemeData> {
  // ── Comic 디자인 시스템 공통 상수 ──
  final double comicBorderWidth;
  final double comicBorderWidthThin;
  final double comicBorderRadiusLarge;
  final double comicBorderRadiusSmall;

  // ── 서브 테마 ──
  final ChatHeaderTheme header;
  final ChatRoomListTheme roomList;
  final ChatBubbleTheme bubble;
  final ChatInputTheme input;
  final ChatDialogTheme dialog;
  final ChatPinnedTheme pinned;
  final ChatBadgeTheme badge;

  const ChatThemeData({
    required this.comicBorderWidth,
    required this.comicBorderWidthThin,
    required this.comicBorderRadiusLarge,
    required this.comicBorderRadiusSmall,
    required this.header,
    required this.roomList,
    required this.bubble,
    required this.input,
    required this.dialog,
    required this.pinned,
    required this.badge,
  });

  /// 기본값 팩토리 - 현재 하드코딩된 값과 동일
  factory ChatThemeData.defaults() {
    return ChatThemeData(
      comicBorderWidth: 2.0,
      comicBorderWidthThin: 1.0,
      comicBorderRadiusLarge: 12.0,
      comicBorderRadiusSmall: 8.0,
      header: ChatHeaderTheme.defaults(),
      roomList: ChatRoomListTheme.defaults(),
      bubble: ChatBubbleTheme.defaults(),
      input: ChatInputTheme.defaults(),
      dialog: ChatDialogTheme.defaults(),
      pinned: ChatPinnedTheme.defaults(),
      badge: ChatBadgeTheme.defaults(),
    );
  }

  /// 편의 접근자 - context로 ChatThemeData 가져오기
  static ChatThemeData of(BuildContext context) {
    return Theme.of(context).extension<ChatThemeData>() ??
        ChatThemeData.defaults();
  }

  @override
  ChatThemeData copyWith({
    double? comicBorderWidth,
    double? comicBorderWidthThin,
    double? comicBorderRadiusLarge,
    double? comicBorderRadiusSmall,
    ChatHeaderTheme? header,
    ChatRoomListTheme? roomList,
    ChatBubbleTheme? bubble,
    ChatInputTheme? input,
    ChatDialogTheme? dialog,
    ChatPinnedTheme? pinned,
    ChatBadgeTheme? badge,
  }) {
    return ChatThemeData(
      comicBorderWidth: comicBorderWidth ?? this.comicBorderWidth,
      comicBorderWidthThin: comicBorderWidthThin ?? this.comicBorderWidthThin,
      comicBorderRadiusLarge:
          comicBorderRadiusLarge ?? this.comicBorderRadiusLarge,
      comicBorderRadiusSmall:
          comicBorderRadiusSmall ?? this.comicBorderRadiusSmall,
      header: header ?? this.header,
      roomList: roomList ?? this.roomList,
      bubble: bubble ?? this.bubble,
      input: input ?? this.input,
      dialog: dialog ?? this.dialog,
      pinned: pinned ?? this.pinned,
      badge: badge ?? this.badge,
    );
  }

  @override
  ChatThemeData lerp(covariant ChatThemeData? other, double t) {
    if (other == null) return this;
    return ChatThemeData(
      comicBorderWidth:
          lerpDouble(comicBorderWidth, other.comicBorderWidth, t)!,
      comicBorderWidthThin:
          lerpDouble(comicBorderWidthThin, other.comicBorderWidthThin, t)!,
      comicBorderRadiusLarge:
          lerpDouble(comicBorderRadiusLarge, other.comicBorderRadiusLarge, t)!,
      comicBorderRadiusSmall:
          lerpDouble(comicBorderRadiusSmall, other.comicBorderRadiusSmall, t)!,
      header: header.lerp(other.header, t),
      roomList: roomList.lerp(other.roomList, t),
      bubble: bubble.lerp(other.bubble, t),
      input: input.lerp(other.input, t),
      dialog: dialog.lerp(other.dialog, t),
      pinned: pinned.lerp(other.pinned, t),
      badge: badge.lerp(other.badge, t),
    );
  }
}

// ============================================================================
// ChatHeaderTheme - 채팅 화면 상단 헤더
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

  factory ChatHeaderTheme.defaults() {
    return const ChatHeaderTheme(
      iconSize: 18.0,
      menuIconSize: 16.0,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      bottomBorderWidth: 1.0,
    );
  }

  ChatHeaderTheme lerp(ChatHeaderTheme other, double t) {
    return ChatHeaderTheme(
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      menuIconSize: lerpDouble(menuIconSize, other.menuIconSize, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      bottomBorderWidth:
          lerpDouble(bottomBorderWidth, other.bottomBorderWidth, t)!,
    );
  }
}

// ============================================================================
// ChatRoomListTheme - 채팅방 목록 타일
// ============================================================================

class ChatRoomListTheme {
  // 타일 레이아웃
  final EdgeInsets tileMargin;
  final double tileBorderRadius;
  final double tileBorderWidth;
  final EdgeInsets tilePadding;
  final double avatarSpacing;

  // 아바타
  final double avatarBorderRadius;
  final double avatarBorderWidth;

  // 핀/즐겨찾기 아이콘
  final double pinnedIconSize;
  final double pinnedIconPadding;
  final double pinnedIconTiltAngle;
  final double pinnedIconBorderWidth;

  // 온라인/즐겨찾기 표시
  final double onlineIndicatorSize;
  final double onlineIndicatorBorderWidth;
  final double onlineIndicatorBorderRadius;
  final double favoriteIndicatorSize;
  final double favoriteIconSize;
  final double favoriteIndicatorBorderWidth;

  // 메뉴
  final double menuIconSize;

  // 타일 내 간격
  final double titleSubtitleSpacing;
  final double rowElementSpacing;

  // 빈 상태
  final EdgeInsets emptyStatePadding;
  final EdgeInsets emptyStateContainerPadding;
  final double emptyStateIconSize;
  final double emptyStateBorderRadius;
  final double emptyStateBorderWidth;
  final double emptyStateSpacing;

  // 리스트
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

  factory ChatRoomListTheme.defaults() {
    return const ChatRoomListTheme(
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

  ChatRoomListTheme lerp(ChatRoomListTheme other, double t) {
    return ChatRoomListTheme(
      tileMargin: EdgeInsets.lerp(tileMargin, other.tileMargin, t)!,
      tileBorderRadius:
          lerpDouble(tileBorderRadius, other.tileBorderRadius, t)!,
      tileBorderWidth:
          lerpDouble(tileBorderWidth, other.tileBorderWidth, t)!,
      tilePadding: EdgeInsets.lerp(tilePadding, other.tilePadding, t)!,
      avatarSpacing: lerpDouble(avatarSpacing, other.avatarSpacing, t)!,
      avatarBorderRadius:
          lerpDouble(avatarBorderRadius, other.avatarBorderRadius, t)!,
      avatarBorderWidth:
          lerpDouble(avatarBorderWidth, other.avatarBorderWidth, t)!,
      pinnedIconSize: lerpDouble(pinnedIconSize, other.pinnedIconSize, t)!,
      pinnedIconPadding:
          lerpDouble(pinnedIconPadding, other.pinnedIconPadding, t)!,
      pinnedIconTiltAngle:
          lerpDouble(pinnedIconTiltAngle, other.pinnedIconTiltAngle, t)!,
      pinnedIconBorderWidth:
          lerpDouble(pinnedIconBorderWidth, other.pinnedIconBorderWidth, t)!,
      onlineIndicatorSize:
          lerpDouble(onlineIndicatorSize, other.onlineIndicatorSize, t)!,
      onlineIndicatorBorderWidth: lerpDouble(
          onlineIndicatorBorderWidth, other.onlineIndicatorBorderWidth, t)!,
      onlineIndicatorBorderRadius: lerpDouble(
          onlineIndicatorBorderRadius, other.onlineIndicatorBorderRadius, t)!,
      favoriteIndicatorSize:
          lerpDouble(favoriteIndicatorSize, other.favoriteIndicatorSize, t)!,
      favoriteIconSize:
          lerpDouble(favoriteIconSize, other.favoriteIconSize, t)!,
      favoriteIndicatorBorderWidth: lerpDouble(
          favoriteIndicatorBorderWidth, other.favoriteIndicatorBorderWidth, t)!,
      menuIconSize: lerpDouble(menuIconSize, other.menuIconSize, t)!,
      titleSubtitleSpacing:
          lerpDouble(titleSubtitleSpacing, other.titleSubtitleSpacing, t)!,
      rowElementSpacing:
          lerpDouble(rowElementSpacing, other.rowElementSpacing, t)!,
      emptyStatePadding:
          EdgeInsets.lerp(emptyStatePadding, other.emptyStatePadding, t)!,
      emptyStateContainerPadding: EdgeInsets.lerp(
          emptyStateContainerPadding, other.emptyStateContainerPadding, t)!,
      emptyStateIconSize:
          lerpDouble(emptyStateIconSize, other.emptyStateIconSize, t)!,
      emptyStateBorderRadius:
          lerpDouble(emptyStateBorderRadius, other.emptyStateBorderRadius, t)!,
      emptyStateBorderWidth:
          lerpDouble(emptyStateBorderWidth, other.emptyStateBorderWidth, t)!,
      emptyStateSpacing:
          lerpDouble(emptyStateSpacing, other.emptyStateSpacing, t)!,
      listPadding: EdgeInsets.lerp(listPadding, other.listPadding, t)!,
      loadingPadding: EdgeInsets.lerp(loadingPadding, other.loadingPadding, t)!,
    );
  }
}

// ============================================================================
// ChatBubbleTheme - 메시지 버블
// ============================================================================

class ChatBubbleTheme {
  // 메시지 레이아웃
  final EdgeInsets messagePadding;
  final EdgeInsets textPadding;
  final double bubbleBorderRadius;
  final double bubbleTailRadius;
  final double maxWidthFraction;

  // 폰트 크기
  final double senderNameFontSize;
  final FontWeight senderNameFontWeight;
  final double messageFontSize;
  final double timestampFontSize;
  final double protocolFontSize;

  // 이미지
  final double imageWidth;
  final double imageHeight;
  final double imageBorderRadius;
  final double imageSpacing;

  // 간격
  final double senderInfoSpacing;
  final double avatarNameSpacing;
  final double timestampSpacing;

  // 프로토콜 메시지
  final EdgeInsets protocolOuterPadding;
  final EdgeInsets protocolPadding;
  final double protocolBorderRadius;

  // 차단/블라인드 메시지
  final double blockedIconSize;
  final double blockedTextFontSize;
  final double blockedIconSpacing;

  // 하단 시트 (메시지 옵션)
  final EdgeInsets bottomSheetPadding;
  final EdgeInsets bottomSheetHeaderPadding;
  final double bottomSheetHeaderFontSize;
  final double bottomSheetItemSpacing;

  // 채팅 고유 시맨틱 색상
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

  factory ChatBubbleTheme.defaults() {
    return ChatBubbleTheme(
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

  ChatBubbleTheme lerp(ChatBubbleTheme other, double t) {
    return ChatBubbleTheme(
      messagePadding:
          EdgeInsets.lerp(messagePadding, other.messagePadding, t)!,
      textPadding: EdgeInsets.lerp(textPadding, other.textPadding, t)!,
      bubbleBorderRadius:
          lerpDouble(bubbleBorderRadius, other.bubbleBorderRadius, t)!,
      bubbleTailRadius:
          lerpDouble(bubbleTailRadius, other.bubbleTailRadius, t)!,
      maxWidthFraction:
          lerpDouble(maxWidthFraction, other.maxWidthFraction, t)!,
      senderNameFontSize:
          lerpDouble(senderNameFontSize, other.senderNameFontSize, t)!,
      senderNameFontWeight:
          FontWeight.lerp(senderNameFontWeight, other.senderNameFontWeight, t)!,
      messageFontSize:
          lerpDouble(messageFontSize, other.messageFontSize, t)!,
      timestampFontSize:
          lerpDouble(timestampFontSize, other.timestampFontSize, t)!,
      protocolFontSize:
          lerpDouble(protocolFontSize, other.protocolFontSize, t)!,
      imageWidth: lerpDouble(imageWidth, other.imageWidth, t)!,
      imageHeight: lerpDouble(imageHeight, other.imageHeight, t)!,
      imageBorderRadius:
          lerpDouble(imageBorderRadius, other.imageBorderRadius, t)!,
      imageSpacing: lerpDouble(imageSpacing, other.imageSpacing, t)!,
      senderInfoSpacing:
          lerpDouble(senderInfoSpacing, other.senderInfoSpacing, t)!,
      avatarNameSpacing:
          lerpDouble(avatarNameSpacing, other.avatarNameSpacing, t)!,
      timestampSpacing:
          lerpDouble(timestampSpacing, other.timestampSpacing, t)!,
      protocolOuterPadding:
          EdgeInsets.lerp(protocolOuterPadding, other.protocolOuterPadding, t)!,
      protocolPadding:
          EdgeInsets.lerp(protocolPadding, other.protocolPadding, t)!,
      protocolBorderRadius:
          lerpDouble(protocolBorderRadius, other.protocolBorderRadius, t)!,
      blockedIconSize:
          lerpDouble(blockedIconSize, other.blockedIconSize, t)!,
      blockedTextFontSize:
          lerpDouble(blockedTextFontSize, other.blockedTextFontSize, t)!,
      blockedIconSpacing:
          lerpDouble(blockedIconSpacing, other.blockedIconSpacing, t)!,
      bottomSheetPadding:
          EdgeInsets.lerp(bottomSheetPadding, other.bottomSheetPadding, t)!,
      bottomSheetHeaderPadding: EdgeInsets.lerp(
          bottomSheetHeaderPadding, other.bottomSheetHeaderPadding, t)!,
      bottomSheetHeaderFontSize: lerpDouble(
          bottomSheetHeaderFontSize, other.bottomSheetHeaderFontSize, t)!,
      bottomSheetItemSpacing:
          lerpDouble(bottomSheetItemSpacing, other.bottomSheetItemSpacing, t)!,
      senderNameColor: Color.lerp(senderNameColor, other.senderNameColor, t)!,
      timestampColor: Color.lerp(timestampColor, other.timestampColor, t)!,
      protocolBgColor:
          Color.lerp(protocolBgColor, other.protocolBgColor, t)!,
      protocolTextColor:
          Color.lerp(protocolTextColor, other.protocolTextColor, t)!,
      blockedBgColor: Color.lerp(blockedBgColor, other.blockedBgColor, t)!,
      blockedTextColor:
          Color.lerp(blockedTextColor, other.blockedTextColor, t)!,
      blockedBorderColor:
          Color.lerp(blockedBorderColor, other.blockedBorderColor, t)!,
      imagePlaceholderColor:
          Color.lerp(imagePlaceholderColor, other.imagePlaceholderColor, t)!,
    );
  }
}

// ============================================================================
// ChatInputTheme - 메시지 입력 영역
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

  // 파일 미리보기
  final double filePreviewHeight;
  final double filePreviewWidth;
  final double filePreviewBorderRadius;
  final double filePreviewSpacing;
  final double filePreviewMarginTop;
  final double deleteButtonSize;
  final double deleteButtonPadding;
  final double deleteIconSize;

  // 뱃지
  final double fileBadgeFontSize;

  // 로딩
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final double loadingSpacing;

  // 업로드 진행
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

  factory ChatInputTheme.defaults() {
    return const ChatInputTheme(
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

  ChatInputTheme lerp(ChatInputTheme other, double t) {
    return ChatInputTheme(
      inputBorderRadius:
          lerpDouble(inputBorderRadius, other.inputBorderRadius, t)!,
      inputFocusBorderWidth:
          lerpDouble(inputFocusBorderWidth, other.inputFocusBorderWidth, t)!,
      sendButtonSize: lerpDouble(sendButtonSize, other.sendButtonSize, t)!,
      sendIconSize: lerpDouble(sendIconSize, other.sendIconSize, t)!,
      inputContentPadding:
          EdgeInsets.lerp(inputContentPadding, other.inputContentPadding, t)!,
      inputAreaPadding:
          EdgeInsets.lerp(inputAreaPadding, other.inputAreaPadding, t)!,
      sendButtonSpacing:
          lerpDouble(sendButtonSpacing, other.sendButtonSpacing, t)!,
      topBorderWidth: lerpDouble(topBorderWidth, other.topBorderWidth, t)!,
      filePreviewHeight:
          lerpDouble(filePreviewHeight, other.filePreviewHeight, t)!,
      filePreviewWidth:
          lerpDouble(filePreviewWidth, other.filePreviewWidth, t)!,
      filePreviewBorderRadius: lerpDouble(
          filePreviewBorderRadius, other.filePreviewBorderRadius, t)!,
      filePreviewSpacing:
          lerpDouble(filePreviewSpacing, other.filePreviewSpacing, t)!,
      filePreviewMarginTop:
          lerpDouble(filePreviewMarginTop, other.filePreviewMarginTop, t)!,
      deleteButtonSize:
          lerpDouble(deleteButtonSize, other.deleteButtonSize, t)!,
      deleteButtonPadding:
          lerpDouble(deleteButtonPadding, other.deleteButtonPadding, t)!,
      deleteIconSize: lerpDouble(deleteIconSize, other.deleteIconSize, t)!,
      fileBadgeFontSize:
          lerpDouble(fileBadgeFontSize, other.fileBadgeFontSize, t)!,
      loadingIndicatorSize:
          lerpDouble(loadingIndicatorSize, other.loadingIndicatorSize, t)!,
      loadingStrokeWidth:
          lerpDouble(loadingStrokeWidth, other.loadingStrokeWidth, t)!,
      loadingSpacing: lerpDouble(loadingSpacing, other.loadingSpacing, t)!,
      uploadProgressFontSize: lerpDouble(
          uploadProgressFontSize, other.uploadProgressFontSize, t)!,
    );
  }
}

// ============================================================================
// ChatDialogTheme - 다이얼로그 공통 (검색, 즐겨찾기, 신고 등)
// ============================================================================

class ChatDialogTheme {
  // 다이얼로그 컨테이너
  final double borderRadius;
  final double borderWidth;
  final double elevation;
  final double maxWidth;

  // 헤더
  final double headerIconSize;
  final EdgeInsets headerPadding;
  final double headerBorderRadius;
  final double headerBorderWidth;

  // 닫기 버튼
  final double closeButtonBorderRadius;
  final double closeButtonBorderWidth;
  final double closeIconSize;

  // 콘텐츠
  final EdgeInsets contentPadding;
  final double contentSpacing;

  // 리스트 아이템
  final double itemBorderRadius;
  final double itemBorderWidth;
  final EdgeInsets itemPadding;
  final double itemSpacing;

  // 아바타
  final double avatarSize;
  final double avatarBorderRadius;
  final double avatarBorderWidth;
  final double avatarSpacing;

  // 검색 필드
  final double searchFieldBorderRadius;
  final double searchFieldBorderWidth;
  final double searchIconSize;
  final double searchIconPadding;
  final EdgeInsets searchContentPadding;

  // 빈 상태
  final double emptyIconSize;
  final double emptySpacing;
  final EdgeInsets emptyPadding;
  final EdgeInsets emptyContainerPadding;

  // 폴더 아이템 (즐겨찾기 폴더)
  final double folderIconSize;
  final double folderIconSpacing;
  final EdgeInsets folderItemPadding;

  // 카운트 뱃지
  final EdgeInsets countBadgePadding;
  final double countBadgeBorderRadius;
  final double countBadgeBorderWidth;
  final double countBadgeSpacing;

  // 액션 버튼 (Comic 확인 다이얼로그용)
  final EdgeInsets titlePadding;
  final EdgeInsets bodyPadding;
  final EdgeInsets actionsPadding;
  final double actionButtonBorderRadius;
  final double actionButtonBorderWidth;
  final EdgeInsets actionButtonPadding;

  // 구분선
  final double dividerThickness;
  final double dividerHeight;

  // 제약 조건
  final double maxHeight;
  final double listMaxHeight;

  // 리포트 다이얼로그
  final EdgeInsets reportChipPadding;
  final double reportChipSpacing;
  final double reportChipRunSpacing;

  // 챗 버튼 (검색 결과)
  final EdgeInsets chatButtonPadding;
  final double chatButtonBorderRadius;
  final double chatButtonBorderWidth;

  // 언읽 뱃지 (즐겨찾기 다이얼로그)
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

  factory ChatDialogTheme.defaults() {
    return const ChatDialogTheme(
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
  }

  /// Comic 스타일 컨테이너 데코레이션 헬퍼
  BoxDecoration containerDecoration(ColorScheme scheme) => BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: scheme.outline, width: borderWidth),
      );

  /// Comic 스타일 액션 버튼 스타일 헬퍼
  ButtonStyle actionButtonStyle(ColorScheme scheme, {bool destructive = false}) =>
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

  ChatDialogTheme lerp(ChatDialogTheme other, double t) {
    return ChatDialogTheme(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      maxWidth: lerpDouble(maxWidth, other.maxWidth, t)!,
      headerIconSize: lerpDouble(headerIconSize, other.headerIconSize, t)!,
      headerPadding:
          EdgeInsets.lerp(headerPadding, other.headerPadding, t)!,
      headerBorderRadius:
          lerpDouble(headerBorderRadius, other.headerBorderRadius, t)!,
      headerBorderWidth:
          lerpDouble(headerBorderWidth, other.headerBorderWidth, t)!,
      closeButtonBorderRadius: lerpDouble(
          closeButtonBorderRadius, other.closeButtonBorderRadius, t)!,
      closeButtonBorderWidth: lerpDouble(
          closeButtonBorderWidth, other.closeButtonBorderWidth, t)!,
      closeIconSize: lerpDouble(closeIconSize, other.closeIconSize, t)!,
      contentPadding:
          EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
      contentSpacing: lerpDouble(contentSpacing, other.contentSpacing, t)!,
      itemBorderRadius:
          lerpDouble(itemBorderRadius, other.itemBorderRadius, t)!,
      itemBorderWidth:
          lerpDouble(itemBorderWidth, other.itemBorderWidth, t)!,
      itemPadding: EdgeInsets.lerp(itemPadding, other.itemPadding, t)!,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t)!,
      avatarSize: lerpDouble(avatarSize, other.avatarSize, t)!,
      avatarBorderRadius:
          lerpDouble(avatarBorderRadius, other.avatarBorderRadius, t)!,
      avatarBorderWidth:
          lerpDouble(avatarBorderWidth, other.avatarBorderWidth, t)!,
      avatarSpacing: lerpDouble(avatarSpacing, other.avatarSpacing, t)!,
      searchFieldBorderRadius: lerpDouble(
          searchFieldBorderRadius, other.searchFieldBorderRadius, t)!,
      searchFieldBorderWidth: lerpDouble(
          searchFieldBorderWidth, other.searchFieldBorderWidth, t)!,
      searchIconSize: lerpDouble(searchIconSize, other.searchIconSize, t)!,
      searchIconPadding:
          lerpDouble(searchIconPadding, other.searchIconPadding, t)!,
      searchContentPadding: EdgeInsets.lerp(
          searchContentPadding, other.searchContentPadding, t)!,
      emptyIconSize: lerpDouble(emptyIconSize, other.emptyIconSize, t)!,
      emptySpacing: lerpDouble(emptySpacing, other.emptySpacing, t)!,
      emptyPadding: EdgeInsets.lerp(emptyPadding, other.emptyPadding, t)!,
      emptyContainerPadding: EdgeInsets.lerp(
          emptyContainerPadding, other.emptyContainerPadding, t)!,
      folderIconSize: lerpDouble(folderIconSize, other.folderIconSize, t)!,
      folderIconSpacing:
          lerpDouble(folderIconSpacing, other.folderIconSpacing, t)!,
      folderItemPadding:
          EdgeInsets.lerp(folderItemPadding, other.folderItemPadding, t)!,
      countBadgePadding:
          EdgeInsets.lerp(countBadgePadding, other.countBadgePadding, t)!,
      countBadgeBorderRadius: lerpDouble(
          countBadgeBorderRadius, other.countBadgeBorderRadius, t)!,
      countBadgeBorderWidth: lerpDouble(
          countBadgeBorderWidth, other.countBadgeBorderWidth, t)!,
      countBadgeSpacing:
          lerpDouble(countBadgeSpacing, other.countBadgeSpacing, t)!,
      titlePadding: EdgeInsets.lerp(titlePadding, other.titlePadding, t)!,
      bodyPadding: EdgeInsets.lerp(bodyPadding, other.bodyPadding, t)!,
      actionsPadding:
          EdgeInsets.lerp(actionsPadding, other.actionsPadding, t)!,
      actionButtonBorderRadius: lerpDouble(
          actionButtonBorderRadius, other.actionButtonBorderRadius, t)!,
      actionButtonBorderWidth: lerpDouble(
          actionButtonBorderWidth, other.actionButtonBorderWidth, t)!,
      actionButtonPadding: EdgeInsets.lerp(
          actionButtonPadding, other.actionButtonPadding, t)!,
      dividerThickness:
          lerpDouble(dividerThickness, other.dividerThickness, t)!,
      dividerHeight: lerpDouble(dividerHeight, other.dividerHeight, t)!,
      maxHeight: lerpDouble(maxHeight, other.maxHeight, t)!,
      listMaxHeight: lerpDouble(listMaxHeight, other.listMaxHeight, t)!,
      reportChipPadding:
          EdgeInsets.lerp(reportChipPadding, other.reportChipPadding, t)!,
      reportChipSpacing:
          lerpDouble(reportChipSpacing, other.reportChipSpacing, t)!,
      reportChipRunSpacing:
          lerpDouble(reportChipRunSpacing, other.reportChipRunSpacing, t)!,
      chatButtonPadding:
          EdgeInsets.lerp(chatButtonPadding, other.chatButtonPadding, t)!,
      chatButtonBorderRadius: lerpDouble(
          chatButtonBorderRadius, other.chatButtonBorderRadius, t)!,
      chatButtonBorderWidth: lerpDouble(
          chatButtonBorderWidth, other.chatButtonBorderWidth, t)!,
      dialogUnreadBadgePadding: EdgeInsets.lerp(
          dialogUnreadBadgePadding, other.dialogUnreadBadgePadding, t)!,
      dialogUnreadBadgeBorderRadius: lerpDouble(
          dialogUnreadBadgeBorderRadius,
          other.dialogUnreadBadgeBorderRadius,
          t)!,
      dialogUnreadBadgeBorderWidth: lerpDouble(
          dialogUnreadBadgeBorderWidth,
          other.dialogUnreadBadgeBorderWidth,
          t)!,
    );
  }
}

// ============================================================================
// ChatPinnedTheme - 고정된 채팅방 목록
// ============================================================================

class ChatPinnedTheme {
  // 섹션
  final double sectionBorderWidth;
  final EdgeInsets headerPadding;
  final double iconSize;
  final double iconSpacing;

  // 리스트
  final double listHeight;
  final EdgeInsets listPadding;
  final double dividerSpacing;

  // 아이템
  final double itemWidth;
  final EdgeInsets itemPadding;
  final EdgeInsets itemHPadding;

  // 아바타
  final double avatarSize;

  // 닫기 버튼
  final double closeButtonSize;
  final double closeButtonBorderWidth;
  final double closeIconSize;

  // 카운트 뱃지
  final EdgeInsets countBadgePadding;
  final double countBadgeBorderRadius;
  final double countBadgeBorderWidth;

  // 언읽 뱃지
  final EdgeInsets unreadBadgePadding;
  final double unreadBadgeBorderRadius;
  final double unreadBadgeBorderWidth;
  final double unreadBadgeFontSize;

  // 이름 간격
  final double nameSpacing;

  // 다이얼로그 (언핀 확인)
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

  factory ChatPinnedTheme.defaults() {
    return const ChatPinnedTheme(
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

  ChatPinnedTheme lerp(ChatPinnedTheme other, double t) {
    return ChatPinnedTheme(
      sectionBorderWidth:
          lerpDouble(sectionBorderWidth, other.sectionBorderWidth, t)!,
      headerPadding:
          EdgeInsets.lerp(headerPadding, other.headerPadding, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t)!,
      listHeight: lerpDouble(listHeight, other.listHeight, t)!,
      listPadding: EdgeInsets.lerp(listPadding, other.listPadding, t)!,
      dividerSpacing: lerpDouble(dividerSpacing, other.dividerSpacing, t)!,
      itemWidth: lerpDouble(itemWidth, other.itemWidth, t)!,
      itemPadding: EdgeInsets.lerp(itemPadding, other.itemPadding, t)!,
      itemHPadding: EdgeInsets.lerp(itemHPadding, other.itemHPadding, t)!,
      avatarSize: lerpDouble(avatarSize, other.avatarSize, t)!,
      closeButtonSize:
          lerpDouble(closeButtonSize, other.closeButtonSize, t)!,
      closeButtonBorderWidth: lerpDouble(
          closeButtonBorderWidth, other.closeButtonBorderWidth, t)!,
      closeIconSize: lerpDouble(closeIconSize, other.closeIconSize, t)!,
      countBadgePadding:
          EdgeInsets.lerp(countBadgePadding, other.countBadgePadding, t)!,
      countBadgeBorderRadius: lerpDouble(
          countBadgeBorderRadius, other.countBadgeBorderRadius, t)!,
      countBadgeBorderWidth: lerpDouble(
          countBadgeBorderWidth, other.countBadgeBorderWidth, t)!,
      unreadBadgePadding:
          EdgeInsets.lerp(unreadBadgePadding, other.unreadBadgePadding, t)!,
      unreadBadgeBorderRadius: lerpDouble(
          unreadBadgeBorderRadius, other.unreadBadgeBorderRadius, t)!,
      unreadBadgeBorderWidth: lerpDouble(
          unreadBadgeBorderWidth, other.unreadBadgeBorderWidth, t)!,
      unreadBadgeFontSize:
          lerpDouble(unreadBadgeFontSize, other.unreadBadgeFontSize, t)!,
      nameSpacing: lerpDouble(nameSpacing, other.nameSpacing, t)!,
      unpinDialogBorderRadius: lerpDouble(
          unpinDialogBorderRadius, other.unpinDialogBorderRadius, t)!,
      unpinDialogBorderWidth: lerpDouble(
          unpinDialogBorderWidth, other.unpinDialogBorderWidth, t)!,
      unpinTitlePadding:
          EdgeInsets.lerp(unpinTitlePadding, other.unpinTitlePadding, t)!,
      unpinBodyPadding:
          EdgeInsets.lerp(unpinBodyPadding, other.unpinBodyPadding, t)!,
      unpinActionsPadding:
          EdgeInsets.lerp(unpinActionsPadding, other.unpinActionsPadding, t)!,
      unpinButtonBorderRadius: lerpDouble(
          unpinButtonBorderRadius, other.unpinButtonBorderRadius, t)!,
      unpinButtonBorderWidth: lerpDouble(
          unpinButtonBorderWidth, other.unpinButtonBorderWidth, t)!,
      unpinButtonPadding:
          EdgeInsets.lerp(unpinButtonPadding, other.unpinButtonPadding, t)!,
      unpinButtonSpacing:
          lerpDouble(unpinButtonSpacing, other.unpinButtonSpacing, t)!,
    );
  }
}

// ============================================================================
// ChatBadgeTheme - 언읽 뱃지 (채팅방 목록 타일용)
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

  factory ChatBadgeTheme.defaults() {
    return const ChatBadgeTheme(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      borderRadius: 50.0,
      borderWidth: 2.0,
      fontSize: 10.0,
    );
  }

  ChatBadgeTheme lerp(ChatBadgeTheme other, double t) {
    return ChatBadgeTheme(
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      fontSize: lerpDouble(fontSize, other.fontSize, t)!,
    );
  }
}
