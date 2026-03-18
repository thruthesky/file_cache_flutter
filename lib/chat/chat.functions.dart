import 'package:firebase_database/firebase_database.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/router.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:philgo/user/user.functions.dart';

// ===================== Configuration =====================

const String _chatCloudFunctionBaseUrl =
    'https://us-central1-philgo-64b1a.cloudfunctions.net';

/// Returns the full URL for a chat cloud function endpoint.
String chatCloudFunctionUrl(String functionName) {
  return '$_chatCloudFunctionBaseUrl/$functionName';
}

// ===================== Firebase Path / Ref Helpers =====================

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

// ===================== Room ID Helpers =====================

/// Checks if the provided roomId is a single chat room id.
bool isSingleChatRoomId(String roomId) {
  return roomId.contains(SINGLE_CHATROOM_JOIN_SEPARATOR);
}

/// UID 가 입력되면, 나의 UID 와 합쳐서 1:1 채팅 방 ID 를 리턴한다.
///
/// [otherUid] - 채팅방 ID 일 수 있고, Firebase UID 일 수 있다.
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
/// 참고:
/// 현재 firebase uid는 28자 이상이다. 하지만, 앞으로 28자 이상이 될 가능성이 있다.
bool isFirebaseUid(String uid) {
  if (["apple", "banana", "cherry", "durian"].contains(uid)) {
    return true;
  }

  if (uid.length == 28) {
    return true;
  }

  return false;
}

String makeSingleChatRoomId(String uid1, String uid2) {
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

// ===================== Other Utilities =====================

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
  if (uid.isEmpty) {
    return false;
  }

  if (uid == SettingsState.of(globalContext).adminChatUid) {
    return true;
  }
  return false;
}

@Deprecated('Use moderateChatMessage instead')
Future<void> moderateChat(String roomId, String messageId) async {}
