import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/chat/report/chat.report.dart';
import 'package:philgo/chat/widgets/search_friends_dialog.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/widgets/block_user_dialog.dart';
import 'package:philgo/util/common.functions.dart';

// Chat Join Path
String chatJoinPath(String uid) {
  return 'chat/joins/$uid';
}

// Chat Message Path
String chatMessagePath(String roomId) {
  return 'chat/messages/$roomId';
}

// Returns a ref of the chat join path for a specific user
DatabaseReference chatJoinRef(String uid) {
  return FirebaseDatabase.instance.ref(chatJoinPath(uid));
}

// Returns a ref of the chat message path from specific room
DatabaseReference chatMessageRef(String roomId) {
  return FirebaseDatabase.instance.ref(chatMessagePath(roomId));
}

Query messageQuery(String roomId) {
  return chatMessageRef(roomId).orderByChild(CREATED_AT);
}

// Short alias for [chatJoinRef]
DatabaseReference joinRef(String uid) {
  return chatJoinRef(uid);
}

DatabaseReference myJoinRoomRef(String roomId) {
  return joinRef(myUid()).child(roomId);
}

Query singleChatRoomListQuery() {
  return chatJoinRef(myUid()).orderByChild(SINGLE_ORDER).startAt(0);
}

DatabaseReference chatFavoritesFolderListRef(String uid) {
  return FirebaseDatabase.instance.ref('chat/favorites-folder-list/$uid');
}

String get reportPath {
  return 'reports';
}

DatabaseReference myReportRef() {
  return FirebaseDatabase.instance.ref(reportPath).child(myUid());
}

String get reportListPath {
  return 'reports-list';
}

DatabaseReference reportsListRef() {
  return FirebaseDatabase.instance.ref(reportListPath);
}

String getReportMessagesPath(String roomId) {
  return '${chatMessagePath(roomId)}/$roomId';
}

String getReportMessagePath(String messageId, String roomId) {
  return '${chatMessagePath(roomId)}/$messageId';
}

/// Checks if the provided roomId is a single chat room id.
///
/// @param roomId - The chat room id to check
/// @return True if the roomId is a single chat room id, otherwise false.
bool isSingleChatRoomId(String roomId) {
  return roomId.contains(SINGLE_CHATROOM_JOIN_SEPARATOR);
}

/// UID 가 입력되면, 나의 UID 와 합쳐서 1:1 채팅 방 ID 를 리턴한다.
///
/// [otherUid] - 채팅방 ID 일 수 있고, Firebase UID 일 수 있다.
/// [loginUid] - purefunction 을 위해서, loginUid 를 입력 받는다.
/// returns 1:1 채팅방 ID 또는 입력된 chat room ID
///
/// Firebase UID 가 입력되면, 나의 UID 와 함께 정렬하여 1:1 채팅방 ID 를 리턴한다.
/// 그룹 채팅방 ID 가 입력되면, 그대로 리턴한다.
String convertUidToSingleChatRoomId(String otherUid) {
  if (isSingleChatRoomId(otherUid)) {
    return otherUid;
  } else if (isFirebaseUid(otherUid)) {
    return makeSingleChatRoomId(otherUid, myUid());
  } else {
    return otherUid;
  }
}

/// Use this function to check if the uid is a valid firebase uid.
///
/// Usage:
/// - To see if the chat room id is not a group chat id.
/// [uid] - The firebase auth uid to check
/// return {bool} - True if the uid is a valid firebase uid,
/// - false otherwise, especially if it is
///   - a group chat room id (return false)
///   - a single chat room id (return false)
///   - a node key (return false)
///
/// 참고:
/// 현재 firebase uid는 28자 이상이다. 하지만, 앞으로 28자 이상이 될 가능성이 있다.
bool isFirebaseUid(String uid) {
  // 테스트 용 UID 이면, true 를 리턴
  if (["apple", "banana", "cherry", "durian"].contains(uid)) {
    return true;
  }

  if (uid.length == 28) {
    return true;
  }

  // 기타 사항에서 false 를 리턴한다.
  return false;
}

String makeSingleChatRoomId(String uid1, String uid2) {
  // sort the UIDs to ensure consistent room ID creation
  // then join them with the separator
  final sortedUids = [uid1, uid2]..sort();
  return sortedUids.join(SINGLE_CHATROOM_JOIN_SEPARATOR);
}

/// Checks if the provided string is a single chat room ID
bool isSingleChatRoom(String id) {
  return isSingleChatRoomId(id);
}

/// Gets the other user's UID from a chat room ID
String? getOtherUserUidFromChatRoomId(String roomId) {
  return getOtherUserUidFromRoomId(roomId);
}

/// Returns the other user's uid from the 1:1 chat room ID.
///
/// If it is a group chat room ID, it returns null.
/// If the user didn't login, it returns null.
/// If the user chat him self, return his id.
///
String? getOtherUserUidFromRoomId(String roomId) {
  if (loginUid() == null) return null;

  final splits = roomId.split(SINGLE_CHATROOM_JOIN_SEPARATOR);
  if (splits.length != 2) {
    return null;
  }

  for (final userUid in splits) {
    if (userUid != myUid()) {
      return userUid;
    }
  }

  // If user is chatting with himself
  if (splits[0] == myUid() && splits[1] == myUid()) {
    return myUid();
  }

  return null;
}

bool startWith20(int number) {
  String str = number.toString();
  return str.startsWith("20");
}

/// Check if this is a chat with admin user
bool isAdminChatRoom({required String roomId, String? otherUserUid}) {
  if (!isSingleChatRoom(roomId)) return false;
  if (otherUserUid == null || otherUserUid.isEmpty) {
    return false;
  }

  return isAdminChatUser(otherUserUid);
}

// Check if this user is an admin chat user
bool isAdminChatUser(String uid) {
  // if (UserService.instance.adminUserUid.isEmpty) {
  //   // If contactUserUid is not set, assume it's not an admin chat
  //   return false;
  // }

  // if (UserService.instance.adminUserUid.contains(uid)) {
  //   // If other user is the contact user, it's an admin chat
  //   return true;
  // }

  return false; // Placeholder, replace with actual admin chat ID check
}

// Get Chat Join
Future<ChatJoin?> getChatJoin(String roomId) async {
  DatabaseReference ref = myJoinRoomRef(roomId);
  final snapshot = await ref.get();
  if (snapshot.exists) {
    return ChatJoin.fromSnapshot(snapshot);
  }
  return null;
}

/// Resets the unread message counter for a user in a specific room to 0
///
/// [roomId] - The chat room ID
/// When user is inside the room and new messages arrive, this function
/// should be called to reset the unread message counter.
Future<void> resetUnreadMessageCounter(String roomId) async {
  if (loginUid() == null) return;

  final joinRef = myJoinRoomRef(roomId);

  await joinRef.update({UNREAD: 0, LAST_READ_AT: ServerValue.timestamp});
}

Future<void> resetChatJoin(String otherUserUid) async {
  final Dio dio = Dio();
  // API 호출하여 즐겨찾기 추가/제거
  final response = await dio.post(
    'https://us-central1-philgo-64b1a.cloudfunctions.net/onResetChatJoin',
    data: {'myUid': loginUid(), 'otherUid': otherUserUid},
    options: Options(headers: {'Content-Type': 'application/json'}),
  );

  if (response.statusCode == 200) {
    log(
      'Success to resetChatJoin',
      name: "resetUnreadMessageCounter::${response.statusCode}",
    );
  } else {
    log(
      'faild to resetChatJoin',
      name: "resetUnreadMessageCounter::${response.statusCode}",
    );
  }
}

/// Sends a message to a chat room
/// 채팅방에 메시지를 전송하는 함수
///
/// [roomId] - 채팅방 ID
/// [text] - 메시지 내용 (최대 2048자)
/// [urls] - 첨부 파일 URL 목록 (선택)
/// [protocol] - 프로토콜 메시지 타입 (선택)
///
/// Returns the message ID after successful send.
/// 전송 성공 시 메시지 ID를 반환합니다.
Future<String> sendMessage({
  required String roomId,
  required String text,
  List<String>? urls,
  String? protocol,
}) async {
  final messageRef = FirebaseDatabase.instance
      .ref('chat/messages/$roomId')
      .push();

  final messageData = {
    'text': cut(text, 2048, defaultValue: ""),
    'senderUid': myUid(),
    'sentAt': ServerValue.timestamp,
    'protocol': protocol,
  };

  // Add urls array if provided and not empty
  // URL 배열이 제공되고 비어있지 않으면 추가
  if (urls != null && urls.isNotEmpty) {
    messageData['urls'] = urls;
  }

  await messageRef.set(messageData);

  // Call onMessageSent callback if set (e.g., for playing send sound)
  // 콜백이 설정되어 있으면 호출 (예: 전송음 재생)
  ChatConfig.onMessageSent?.call();

  return messageRef.key!; // Return the message ID
}

Future<void> leaveChatRoom({
  required String roomId,
  Function()? success,
  Function(String error)? error,
}) async {
  try {
    // await sendChatProtocolMessage(roomId: roomId, protocol: ChatProtocol.left);
    await myJoinRoomRef(roomId).set(null);
    success?.call();
  } catch (e) {
    error?.call(e.toString());
  }
}

/// Show block/unblock dialog
/// [displayName] - the target user's display name to show in the dialog
void showBlockDialog({
  required BuildContext context,
  required String otherUserUid,
  String? displayName,
  bool popOnBlocked = true,
  VoidCallback? onBlocked,
}) {
  showDialog(
    context: context,
    builder: (ctx) => BlockUserDialog(
      otherUserUid: otherUserUid,
      displayName: displayName,
      onBlocked: () {
        if (popOnBlocked) {
          Navigator.of(context).pop();
        }
        onBlocked?.call();
      },
    ),
  );
}

/// Show block/unblock dialog
void showUnblockDialog({
  required BuildContext context,
  required String otherUserUid,
  bool popOnUnblocked = false,
  VoidCallback? onUnblocked,
}) {
  showDialog(
    context: context,
    builder: (ctx) => UnblockUserDialog(
      otherUserUid: otherUserUid,
      onUnblocked: () {
        if (popOnUnblocked) {
          Navigator.of(context).pop();
        }
        onUnblocked?.call();
      },
    ),
  );
}

Future<void> createReport({
  required String path,
  required String reason,
  String? reportee,
  required Function() success,
  required Function(String error) error,
}) async {
  try {
    DataSnapshot snapshot = await myReportRef()
        .orderByChild('path')
        .equalTo(path)
        .get();

    if (snapshot.exists) {
      throw ('You already have reported this.');
    }

    final data = {
      REPORT_PATH: path,
      REPORT_REPORTER: myUid(),
      REPORT_REPORTEE: reportee,
      REPORT_REASON: reason,
      REPORT_CREATED_AT: ServerValue.timestamp,
    };

    DatabaseReference ref = myReportRef().push();
    await ref.set(data);

    await reportsListRef().child(ref.key!).set(data);

    success();
  } catch (e) {
    error(e.toString());
  }
}

/// Show report dialog for the message
void showChatMessageReportDialog({
  required BuildContext context,
  required ChatMessage message,
  required String? roomId,
}) {
  showDialog(
    context: context,
    builder: (context) => ReportChatMessage(
      message: message,
      roomId: roomId!,
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}

Future<String> sendChatProtocolMessage({
  required String roomId,
  required String protocol,
}) async {
  DatabaseReference ref = chatMessageRef(roomId).push();
  await ref.set({
    SENDER_UID: myUid(),
    PROTOCOL: protocol,
    SENT_AT: ServerValue.timestamp,
  });
  return ref.key!;
}

Future<String?> showUserSearchDialog(BuildContext context) async {
  final uid = await showDialog<String?>(
    context: context,
    builder: (context) => SearchFriendsDialog(),
  );
  return uid;
}

Future<void> updateJoinRoomNickname(ChatJoin join, String nickname) async {
  if (nickname.isEmpty) return;
  if (nickname == join.customName) return;
  await FirebaseDatabase.instance.ref().update({
    'chat/joins/${myUid()}/${join.id}/userDisplayName': nickname,
  });
}

Future<void> updateJoinRoomPhotoUrl(ChatJoin join, String? imageUrl) async {
  if (imageUrl == null) return;
  if (imageUrl.isEmpty) return;
  if (imageUrl == join.userPhotoUrl) return;
  await FirebaseDatabase.instance.ref().update({
    'chat/joins/${myUid()}/${join.id}/userPhotoUrl': imageUrl,
  });
}

// ============================ DOUBLE CHECK BEFORE USE ============================

@Deprecated('Use moderateChatMessage instead')
Future<void> moderateChat(String roomId, String messageId) async {
  // await func(
  //   ChatRoomApi.moderate,
  //   data: {'room_id': roomId, 'message_id': messageId},
  // );
}
