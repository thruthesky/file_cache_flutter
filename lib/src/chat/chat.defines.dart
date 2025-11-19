// ignore_for_file: constant_identifier_names

const String ROOM = 'room';
const String MESSAGE = 'message';

const String ORDER = 'order';
const String SINGLE_ORDER = 'singleOrder';
const String GROUP_ORDER = 'groupOrder';
const String OPEN_ORDER = 'openOrder';

const String JOIN_NICKNAME = 'nickname';
const String JOIN_PHOTO_URL = 'photoUrl';

const String ROOM_USERS = 'users';
const String ROOM_MASTER_USERS = 'masterUsers';
const String ROOM_INVITED_USERS = 'invitedUsers';
const String ROOM_NAME = 'name';
const String ROOM_DESCRIPTION = 'description';
const String ROOM_IMAGE_URL = 'imageUrl';
const String ROOM_OPEN = 'open';
const String ROOM_TEST = 'test';
const String ROOM_BLOCK_ADVERTISEMENT = 'block_advertisement';

const String SENDER_UID = 'senderUid';
const String PROTOCOL = 'protocol';

const String SENT_AT = 'sentAt';

class RoomOrder {
  static const order = ORDER;
  static const singleOrder = SINGLE_ORDER;
  static const groupOrder = GROUP_ORDER;
  static const openOrder = OPEN_ORDER;
}

const String UNREAD = 'unread';

const String SINGLE_CHATROOM_JOIN_SEPARATOR = '---';

class ChatRoomApi {
  static String moderate = "moderate.chat";
}

/// Chat protocol constants for different message types
class ChatProtocol {
  static const String create = "protocol.create";
  static const String join = "protocol.join";
  static const String invitationNotSent = "protocol.invitationNotSent";
  static const String left = "protocol.left";
  static const String removed = "protocol.removed";

  /// Check if a protocol is a system protocol message
  static bool isProtocolMessage(String? protocol) {
    if (protocol == null) return false;
    return protocol.startsWith('protocol.');
  }

  /// Get all protocol constants
  static List<String> get allProtocols => [
    create,
    join,
    invitationNotSent,
    left,
    removed,
  ];
}

/// Available report reasons
const List<String> reportReasons = [
  'spam',
  'abusive',
  'violence',
  'hate_speech',
  'inappropriate_content',
];
