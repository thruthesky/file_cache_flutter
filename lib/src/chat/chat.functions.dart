import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

String get chatRoomsPath {
  return 'chat/rooms/';
}

// Chat Join Path
String chatJoinPath(String uid) {
  return 'chat/joins/$uid';
}

// Chat Message Path
String chatMessagePath(String roomId) {
  return 'chat/messages/$roomId';
}

String roomUserPath(String roomId, String uid) {
  return '${chatRoomPath(roomId)}/users/$uid';
}

DatabaseReference roomUserRef(String roomId, String uid) {
  return FirebaseDatabase.instance.ref(roomUserPath(roomId, uid));
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
  return chatMessageRef(roomId).orderByChild('created_at');
}

// Short alias for [chatJoinRef]
DatabaseReference joinRef(String uid) {
  return chatJoinRef(uid);
}

DatabaseReference myJoinRoomRef(String roomId) {
  return joinRef(myUid()).child(roomId);
}

DatabaseReference chatRoomsRef() {
  return FirebaseDatabase.instance.ref(chatRoomsPath);
}

String chatRoomPath(String roomId) {
  // log('--> $chatRoomsPath$roomId');
  return '$chatRoomsPath$roomId';
}

DatabaseReference chatRoomRef(String roomId) {
  return FirebaseDatabase.instance.ref(chatRoomPath(roomId));
}

// Short alias for [chatRoomRef]
DatabaseReference roomRef(String roomId) {
  return chatRoomRef(roomId);
}

Query singleChatRoomListQuery(String uid) {
  return chatJoinRef(uid).orderByChild(RoomOrder.singleOrder).startAt(0);
}

Query groupChatRoomListQuery(String uid) {
  return chatJoinRef(uid).orderByChild(RoomOrder.groupOrder).startAt(0);
}

DatabaseReference roomInvitedUserRef(String roomId, String uid) {
  return chatRoomRef(roomId).child(ROOM_INVITED_USERS).child(uid);
}

DatabaseReference chatFavoritesFolderListRef(String uid) {
  return FirebaseDatabase.instance.ref('chat/favorites-folder-list/$uid');
}

// Returns a query for the chat rooms based on the room order and user ID
// singleOrder - returns a list of single chat rooms for the user
// groupOrder - returns a list of group chat rooms for the user
// openOrder - returns a list of open chat rooms
// order - returns a list of chat rooms based on the user's order
Query roomQuery(String roomOrder, String uid) {
  switch (roomOrder) {
    case RoomOrder.singleOrder:
      return singleChatRoomListQuery(uid);
    case RoomOrder.groupOrder:
      return groupChatRoomListQuery(uid);
    case RoomOrder.openOrder:
      return chatRoomsRef().orderByChild(RoomOrder.openOrder).startAt(0);
    case RoomOrder.order:
      return chatJoinRef(uid).orderByChild(RoomOrder.order).startAt(0);
    default:
      throw ArgumentError('Invalid room order: $roomOrder');
  }
}

/// Checks if the provided roomId is a single chat room id.
///
/// @param roomId - The chat room id to check
/// @return True if the roomId is a single chat room id, otherwise false.
bool isSingleChatRoomId(String roomId) {
  return roomId.contains(SINGLE_CHATROOM_JOIN_SEPARATOR);
}

bool isOpenChatSnapshot(DataSnapshot snapshot) {
  // Assuming that an open chat room has a specific property or structure
  // You can modify this logic based on your actual data structure
  return snapshot.value != null &&
      snapshot.value is Map &&
      (snapshot.value as Map)[OPEN_ORDER] != null;
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
  if (UserService.instance.adminUserUid.isEmpty) {
    // If contactUserUid is not set, assume it's not an admin chat
    return false;
  }

  if (UserService.instance.adminUserUid.contains(uid)) {
    // If other user is the contact user, it's an admin chat
    return true;
  }

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
  if (urls != null && urls.isNotEmpty) {
    messageData['urls'] = urls;
  }

  await messageRef.set(messageData);
  return messageRef.key!; // Return the message ID
}

Future<void> leaveChatRoom({
  required String roomId,
  Function()? success,
  Function(String error)? error,
}) async {
  try {
    await sendChatProtocolMessage(roomId: roomId, protocol: ChatProtocol.left);

    await myJoinRoomRef(roomId).set(null);

    roomUserRef(roomId, myUid()).set(null).catchError((error) {
      error?.call(error.toString());
    });
    success?.call();
  } catch (e) {
    error?.call(e.toString());
  }
}

/// Show block/unblock dialog
void showBlockDialog({
  required BuildContext context,
  required String otherUserUid,
  bool popOnBlocked = true,
}) {
  showDialog(
    context: context,
    builder: (ctx) => BlockUserDialog(
      otherUserUid: otherUserUid,
      onBlocked: () {
        if (popOnBlocked) {
          Navigator.of(context).pop();
        }
      },
    ),
  );
}

/// Show block/unblock dialog
void showUnblockDialog({
  required BuildContext context,
  required String otherUserUid,
  bool popOnUnblocked = false,
}) {
  showDialog(
    context: context,
    builder: (ctx) => UnblockUserDialog(
      otherUserUid: otherUserUid,
      onUnblocked: () {
        if (popOnUnblocked) {
          Navigator.of(context).pop();
        }
      },
    ),
  );
}

void showReportDialog(BuildContext context, String type, {String? reportee}) {
  showDialog(
    context: context,
    builder: (context) =>
        ReportDialog(type: type, onClose: () => Navigator.of(context).pop()),
  );
}

/// ====================================================================================
/// TO BE DELETED IF NOT NEEDED FUNCTION BELOW
/// ===================================================================================

///
/// This create the chatRoom
///
/// return room id if success, otherwise return null.
Future<String?> createChatRoom({
  String? otherUserUid,
  String? name,
  String? description,
  bool? open,
  bool? test,
  bool? blockAdvertisement,
  Function(String roomId)? onCreate,
  Function(String error)? onError,
}) async {
  bool isSingle = otherUserUid != null;

  log('--> createChatRoom');
  log('--> isSingle: $isSingle');
  log('--> otherUserUid: $otherUserUid');
  log('--> name: $name');
  log('--> description: $description');
  log('--> open: $open');
  log('--> test: $test');
  log('--> blockAdvertisement: $blockAdvertisement');
  log('--> myUid: ${myUid()}');

  try {
    String? id = '';
    if (isSingle) {
      id = makeSingleChatRoomId(otherUserUid, myUid());
      // set room data
      await FirebaseDatabase.instance.ref().update({
        "chat/rooms/$id/$ROOM_USERS/${myUid()}": true,
        "chat/rooms/$id/$ROOM_MASTER_USERS/${myUid()}": true,
        "chat/rooms/$id/$ROOM_INVITED_USERS/$otherUserUid": true,
      });
      // update join with room id
      await chatJoinRef(myUid()).child(id).update({
        ORDER: ServerValue.timestamp,
        SINGLE_ORDER: ServerValue.timestamp,
      });
      onCreate?.call(id);
      return id;
    } else {
      DatabaseReference ref = chatRoomsRef().push();
      id = ref.key;
      final data = {
        "chat/rooms/$id/$ROOM_USERS/${myUid()}": true,
        "chat/rooms/$id/$ROOM_MASTER_USERS/${myUid()}": true,
        if (name != null) "chat/rooms/$id/$ROOM_NAME": name,
        if (description != null)
          "chat/rooms/$id/$ROOM_DESCRIPTION": description,
        if (open == true) "chat/rooms/$id/$ROOM_OPEN": true,
        if (test == true) "chat/rooms/$id/$ROOM_TEST": true,
        if (blockAdvertisement == true)
          "chat/rooms/$id/$ROOM_BLOCK_ADVERTISEMENT": true,
        "chat/rooms/$id/$OPEN_ORDER": open == true
            ? ServerValue.timestamp
            : null,
      };
      log('--> $data');
      await FirebaseDatabase.instance.ref().update(data);

      await chatJoinRef(myUid()).child(ref.key!).set({
        ORDER: ServerValue.timestamp,
        GROUP_ORDER: ServerValue.timestamp,
        ROOM_NAME: name,
        if (open == true) OPEN_ORDER: ServerValue.timestamp,
      });
    }
    await sendChatProtocolMessage(roomId: id!, protocol: ChatProtocol.create);
    onCreate?.call(id);
    return id;
  } catch (e) {
    log('--> Error creating single chat room: $e');
    onError?.call(e.toString());
    return null;
  }
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

/// Join chat room
///
/// Return room Id
Future<void> joinChatRoom(ChatRoom room) async {
  try {
    //
    if (room.users[myUid()] == null || room.invitedUsers[myUid()] != null) {
      await removeMyUidFromInvitedUser(room.id);
      await addMyUidToRoomUsers(room.id);

      if (isSingleChatRoom(room.id)) {
        await myJoinRoomRef(room.id).update({
          ORDER: ServerValue.timestamp,
          SINGLE_ORDER: ServerValue.timestamp,
        });
      } else {
        await myJoinRoomRef(room.id).update({
          ORDER: ServerValue.timestamp,
          GROUP_ORDER: ServerValue.timestamp,
          ROOM_NAME: room.name,
          ROOM_IMAGE_URL: room.imageUrl,
          if (room.open) OPEN_ORDER: ServerValue.timestamp,
        });
        await sendChatProtocolMessage(
          roomId: room.id,
          protocol: ChatProtocol.join,
        );
      }
    } else {
      final snapshot = await myJoinRoomRef(room.id).get();

      Map<String, dynamic> data = {
        UNREAD: 0,
        ROOM_NAME: room.name,
        ROOM_IMAGE_URL: room.imageUrl,
      };
      if (snapshot.exists) {
        Map value = snapshot.value as Map;
        const orderFields = [ORDER, GROUP_ORDER, SINGLE_ORDER, OPEN_ORDER];
        for (final field in value.keys) {
          if (orderFields.contains(field)) {
            final joinValue = value[field]?.toString() ?? '';
            if (joinValue.startsWith('20')) {
              data[field] = ServerValue.timestamp;
            }
          }
        }
      } else {
        data[ORDER] = ServerValue.timestamp;
        if (isSingleChatRoom(room.id)) {
          data[SINGLE_ORDER] = ServerValue.timestamp;
        } else {
          data[GROUP_ORDER] = ServerValue.timestamp;
          if (room.open) {
            data[OPEN_ORDER] = ServerValue.timestamp;
          }
        }
      }

      await myJoinRoomRef(room.id).update(data);
    }

    /// Update chat room extra information without waiting
    joinChatRoomExtra(room);
  } catch (e) {
    log('--> Error joining room: $e');
  }
}

/// 1) If user is not in the room, invite them
/// 2) Update my join information about other user's nickname and photo URL
Future<void> joinChatRoomExtra(ChatRoom room) async {
  if (isSingleChatRoom(room.id)) {
    String? otherUserUid = getOtherUserUidFromChatRoomId(room.id);

    if (otherUserUid != null) {
      if (room.users[otherUserUid] == null &&
          room.invitedUsers[otherUserUid] == null) {
        await inviteUser(room.id, otherUserUid);
      }

      final other = await getUser(otherUserUid);
      if (other != null) {
        await myJoinRoomRef(room.id).update({
          JOIN_NICKNAME: other.nickname,
          JOIN_PHOTO_URL: other.photoUrl,
        });
      }
    }
  }
}

Future inviteUser(String roomId, String uid) async {
  return roomInvitedUserRef(roomId, uid).set(true);
}

Future removeMyUidFromInvitedUser(String roomId) async {
  return roomInvitedUserRef(roomId, myUid()).set(null);
}

Future addMyUidToRoomUsers(String roomId) async {
  await chatRoomRef(roomId).child(ROOM_USERS).child(myUid()).set(true);
}

/// This gets the chat room information from the database.  /// If the room is not created yet, null will be returned.
/// If permission error, Firebase exception will be thrown.
///
/// [roomId] - The chat room id.
/// - The chat room information as ChatRoomModel.
/// - If the room is not found, null will be returned.
Future<ChatRoom?> getChatRoom(String roomId) async {
  DatabaseReference ref = roomRef(
    roomId,
  ); // FirebaseDatabase.instance.ref('$chatRooms$roomId');

  //
  final snapshot = await ref.get();

  if (snapshot.exists) {
    return ChatRoom.fromSnapshot(snapshot);
  }

  return null;
}

Future<void> editChatRoom({
  required String roomId,
  String name = '',
  String description = '',
  bool? open,
  bool? blockAdvertisement,
  Function(ChatRoom? room)? success,
  Function(String error)? error,
}) async {
  try {
    final room = await getChatRoom(roomId);
    if (room == null) {
      throw ('room_not_found');
    }

    if (isSingleChatRoom(roomId)) {
      throw ("single_chat_room_edit_not_allowed");
    }

    if (room.masterUsers[myUid()] == null) {
      throw ('user_not_master');
    }

    Map<String, dynamic> data = {};
    if (name.trim().isNotEmpty) {
      data["chat/rooms/$roomId/$ROOM_NAME"] = name.trim();
    }

    if (description.trim().isNotEmpty) {
      data["chat/rooms/$roomId/$ROOM_DESCRIPTION"] = description.trim();
    }

    if (open != null && open != room.open) {
      if (open) {
        data["chat/rooms/$roomId/$ROOM_OPEN"] = true;
        data["chat/rooms/$roomId/$OPEN_ORDER"] = ServerValue.timestamp;
      } else {
        // If open is false, remove the open property
        data["chat/rooms/$roomId/$ROOM_OPEN"] = null;
        data["chat/rooms/$roomId/$OPEN_ORDER"] = null;
      }
    }

    if (blockAdvertisement != null) {
      data["chat/rooms/$roomId/$ROOM_BLOCK_ADVERTISEMENT"] = blockAdvertisement
          ? true
          : null;
    }

    await FirebaseDatabase.instance.ref().update(data);

    if (room.name != name.trim()) {
      for (final userUid in room.users.keys) {
        await joinRef(userUid).child(roomId).update({ROOM_NAME: name.trim()});
      }
    }

    final updatedRoom = await getChatRoom(roomId);
    success?.call(updatedRoom);
  } catch (e) {
    error?.call(e.toString());
  }
}

/// Edit chat room photo URL
///
/// @param roomId room ID to update
/// @param imageUrl new image URL
/// @returns ChatRoomInterface object
Future<ChatRoom?> editChatRoomPhotoUrl(String roomId, String imageUrl) async {
  if (isSingleChatRoom(roomId)) {
    throw ("single_chat_room_edit_not_allowed");
  }

  final room = await getChatRoom(roomId);
  if (room == null) {
    throw ('room_not_found');
  }

  if (room.masterUsers[myUid()] == null) {
    throw ('user_not_master');
  }

  if (imageUrl.isNotEmpty && imageUrl != room.imageUrl) {
    await FirebaseDatabase.instance.ref().update({
      "chat/rooms/$roomId/image_url": imageUrl,
    });

    /// update join image url
    for (final userUid in room.users.keys) {
      await joinRef(userUid).child(roomId).update({ROOM_IMAGE_URL: imageUrl});
    }

    if (room.imageUrl != null && room.imageUrl!.isNotEmpty) {
      // Delete old image if it exists
      await FirebaseStorage.instance
          .refFromURL(room.imageUrl!)
          .delete()
          .catchError((e) {
            log('--> Error deleting old image: $e');
          });
    }
    return await getChatRoom(roomId);
  }

  return room;
}

/// Delete chat room photo URL
///
/// @param roomId room ID to update
/// @returns ChatRoomInterface object
Future<ChatRoom?> deleteChatRoomPhotoUrl(String roomId) async {
  if (isSingleChatRoom(roomId)) {
    throw ("single_chat_room_edit_not_allowed");
  }

  final room = await getChatRoom(roomId);

  if (room == null) {
    throw ('room_not_found');
  }

  if (room.imageUrl != null && room.imageUrl!.isNotEmpty) {
    return room;
  }

  if (room.masterUsers[myUid()] == null) {
    throw ('user_not_master');
  }

  await FirebaseDatabase.instance.ref().update({
    "chat/rooms/$roomId/image_url": null,
  });

  await FirebaseStorage.instance.refFromURL(room.imageUrl!).delete().catchError(
    (e) {
      log('--> Error deleting image: $e');
    },
  );

  for (final userUid in room.users.keys) {
    await joinRef(userUid).child(roomId).update({ROOM_IMAGE_URL: null});
  }

  final updatedRoom = await getChatRoom(roomId);
  return updatedRoom;
}

@Deprecated('Use moderateChatMessage instead')
Future<void> moderateChat(String roomId, String messageId) async {
  await func(
    ChatRoomApi.moderate,
    data: {'room_id': roomId, 'message_id': messageId},
  );
}

Future<String?> showUserSearchDialog(BuildContext context) async {
  final uid = await showDialog<String?>(
    context: context,
    builder: (context) => SearchFriendsDialog(),
  );
  return uid;
}

Future<void> updateJoinRoomNickname(ChatRoom room, String nickname) async {
  if (nickname.isEmpty) return;
  if (nickname == room.nickname) return;
  await FirebaseDatabase.instance.ref().update({
    'chat/joins/${myUid()}/${room.id}/userDisplayName': nickname,
  });
}

Future<void> updateJoinRoomPhotoUrl(ChatRoom room, String? imageUrl) async {
  if (imageUrl == null) return;
  if (imageUrl.isEmpty) return;
  if (imageUrl == room.imageUrl) return;
  await FirebaseDatabase.instance.ref().update({
    'chat/joins/${myUid()}/${room.id}/userPhotoUrl': imageUrl,
  });
}
